import 'package:fi_you/core/config/app_config.dart';
import 'package:fi_you/core/user_level.dart';
import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/mock/fi_you_mock_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _LiveLaunchRoute { onboarding, appShell }

class _FlutterLaunchState {
  const _FlutterLaunchState({
    required this.route,
    required this.profileExists,
    required this.onboardingCompleted,
    required this.starBalance,
    this.profile,
    this.latestUMapSnapshotId,
  });

  final _LiveLaunchRoute route;
  final bool profileExists;
  final bool onboardingCompleted;
  final int starBalance;
  final Map<String, dynamic>? profile;
  final String? latestUMapSnapshotId;

  factory _FlutterLaunchState.fromJson(Map<String, dynamic> json) {
    return _FlutterLaunchState(
      route: json['route'] == 'app_shell'
          ? _LiveLaunchRoute.appShell
          : _LiveLaunchRoute.onboarding,
      profileExists: json['profileExists'] == true,
      onboardingCompleted: json['onboardingCompleted'] == true,
      starBalance: (json['starBalance'] as num?)?.toInt() ?? 0,
      profile: _mapOrNull(json['profile']),
      latestUMapSnapshotId: json['latestUMapSnapshotId'] as String?,
    );
  }

  factory _FlutterLaunchState.fromLaunchGateJson(Map<String, dynamic> json) {
    return _FlutterLaunchState(
      route: json['homeAllowed'] == true
          ? _LiveLaunchRoute.appShell
          : _LiveLaunchRoute.onboarding,
      profileExists: json['profileExists'] == true,
      onboardingCompleted: json['onboardingCompletedFlag'] == true,
      starBalance: 0,
      latestUMapSnapshotId: json['latestUMapSnapshotId'] as String?,
    );
  }

  static Map<String, dynamic>? _mapOrNull(Object? data) {
    if (data == null) {
      return null;
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}

class _ResolvedQuestionAnswer {
  const _ResolvedQuestionAnswer({
    required this.questionId,
    required this.selectedOptionId,
    required this.optionalText,
  });

  final String questionId;
  final String selectedOptionId;
  final String? optionalText;
}

class SupabaseFiYouRepository extends FiYouRepository {
  SupabaseFiYouRepository(this.client);

  static const _questionSetOnboardingRequired = 'onboarding_required';
  static const _questionSetBasicFree = 'basic_free';
  static const _insightTargetType = 'daily_insight';

  final SupabaseClient client;

  UserProfile? _profile;
  List<DiaryEntry> _diaryEntries = <DiaryEntry>[];
  List<AxisSummary> _axes = List.of(axisSummaries);
  ClueInsight _todayInsight = const ClueInsight(
    id: 'insight-today',
    title: '오늘 발견한 단서',
    body: '아직 충분한 기록이 없어 확정된 해석은 아니에요. 새로운 기록이 쌓이면 U-Map에 반영됩니다.',
    sourceCount: 0,
    diaryCount: 0,
    questionCount: 0,
    axes: ['관계 흐름', '감정 인식'],
    sources: [],
  );
  bool _hasLowUMapData = true;

  @override
  UserProfile? get profile => _profile;

  @override
  List<DiaryEntry> get diaryEntries => List.unmodifiable(_diaryEntries);

  @override
  List<AxisSummary> get axes => List.unmodifiable(_axes);

  @override
  ClueInsight get todayInsight => _todayInsight;

  @override
  bool get hasLowUMapData => _hasLowUMapData;

  @override
  bool get storeBillingConnected => false;

  @override
  Future<LaunchSnapshot> restoreLaunchState() async {
    if (client.auth.currentSession == null || client.auth.currentUser == null) {
      _clearSessionState();
      notifyListeners();
      return const LaunchSnapshot(status: LaunchStatus.signedOut);
    }

    final state = await _loadFlutterLaunchState();
    await _hydrateHomeData(state);
    notifyListeners();

    if (state.route == _LiveLaunchRoute.onboarding) {
      return const LaunchSnapshot(status: LaunchStatus.onboardingRequired);
    }

    return const LaunchSnapshot(status: LaunchStatus.ready);
  }

  @override
  Future<void> signIn() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.authRedirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  @override
  Future<UserProfile> saveProfileBasics({
    required String name,
    DateTime? birthday,
  }) async {
    final displayName = name.trim().isEmpty ? 'User' : name.trim();
    final data = await client.rpc(
      'upsert_profile',
      params: {
        'p_nickname': displayName,
        'p_preferred_language': 'ko',
        'p_birthday': _dateParam(birthday),
        'p_focus_area': null,
      },
    );
    final saved = _profileFromMap(
      _requiredMap(data, 'upsert_profile'),
      starBalance: _profile?.starBalance ?? await _loadStarBalance(fallback: 0),
      onboardingComplete: _profile?.onboardingComplete ?? false,
    );
    _profile = saved;
    notifyListeners();
    return saved;
  }

  @override
  Future<List<OnboardingQuestion>> loadOnboardingQuestions({
    String questionSet = _questionSetOnboardingRequired,
  }) async {
    await client.rpc(
      'get_question_loop_state',
      params: {'p_question_set': questionSet},
    );

    final questions = await client
        .from('questions')
        .select('id, question_set, sequence, prompt, helper_text, axis_keys')
        .eq('question_set', questionSet)
        .eq('active', true)
        .order('sequence', ascending: true);
    final questionRows = _mapList(questions);
    if (questionRows.isEmpty) {
      return const <OnboardingQuestion>[];
    }

    final questionIds = [
      for (final question in questionRows)
        if (question['id'] case final String id) id,
    ];
    final options = await client
        .from('question_options')
        .select('id, question_id, sequence, label')
        .inFilter('question_id', questionIds)
        .order('sequence', ascending: true);
    final optionRows = _mapList(options);

    return [
      for (final question in questionRows)
        _onboardingQuestionFromMap(
          question,
          optionRows
              .where((option) => option['question_id'] == question['id'])
              .toList(),
        ),
    ];
  }

  @override
  Future<void> saveOnboardingAnswer(QuestionAnswerInput input) async {
    await client.rpc(
      'submit_question_answer',
      params: {
        'p_question_set': input.questionSet,
        'p_question_id': input.questionId,
        'p_selected_option_id': input.selectedOptionId,
        'p_optional_text': input.optionalText,
        'p_skipped': input.skipped,
      },
    );
    await _refreshUMapSnapshot();
    notifyListeners();
  }

  @override
  Future<ExplorationCard> loadNextExplorationCard() async {
    final response = await client.functions.invoke(
      'deliver-exploration-card',
      body: {'userLanguage': 'ko'},
    );
    final data = _requiredMap(response.data, 'deliver-exploration-card');
    return _explorationCardFromMap(
      _requiredMap(data['card'], 'exploration.card'),
    );
  }

  @override
  Future<void> submitExplorationAnswer(ExplorationAnswerInput input) async {
    await client.functions.invoke(
      'answer-exploration-card',
      body: {
        'card_id': input.cardId,
        'selected_options': input.selectedOptionIds,
        'user_note': input.userNote?.trim() ?? '',
      },
    );
    await _refreshUMapSnapshot();
    _todayInsight = _insightFromCurrentState(questionCount: 1);
    notifyListeners();
  }

  @override
  Future<InsightFeedResponse> getInsightFeed() async {
    if (client.auth.currentSession == null || client.auth.currentUser == null) {
      return InsightFeedResponse.empty(errorMessage: 'auth_session_missing');
    }

    try {
      final response = await client.functions.invoke(
        'insight-feed',
        body: {'refresh': false},
      );
      final parsed = InsightFeedResponse.fromJson(response.data);
      if (parsed.hasError) {
        return parsed;
      }
      if (parsed.isEmpty) {
        final refreshedResponse = await client.functions.invoke(
          'insight-feed',
          body: {'refresh': true},
        );
        return InsightFeedResponse.fromJson(refreshedResponse.data);
      }
      return parsed;
    } on FunctionException {
      return InsightFeedResponse.empty(
        errorMessage: 'insight_feed_unavailable',
      );
    } on AuthException {
      return InsightFeedResponse.empty(errorMessage: 'auth_session_invalid');
    } on FormatException {
      return InsightFeedResponse.empty(errorMessage: 'insight_feed_malformed');
    } on StateError {
      return InsightFeedResponse.empty(errorMessage: 'insight_feed_malformed');
    } catch (_) {
      return InsightFeedResponse.empty(
        errorMessage: 'insight_feed_unavailable',
      );
    }
  }

  @override
  Future<StoryFeedResponse> getStoryFeed() async {
    if (client.auth.currentSession == null || client.auth.currentUser == null) {
      return StoryFeedResponse.empty(errorMessage: 'auth_session_missing');
    }

    try {
      final response = await client.functions.invoke(
        'story-feed',
        body: {'refresh': false},
      );
      return StoryFeedResponse.fromJson(response.data);
    } on FunctionException {
      return StoryFeedResponse.empty(errorMessage: 'story_feed_unavailable');
    } on AuthException {
      return StoryFeedResponse.empty(errorMessage: 'auth_session_invalid');
    } on FormatException {
      return StoryFeedResponse.empty(errorMessage: 'story_feed_malformed');
    } on StateError {
      return StoryFeedResponse.empty(errorMessage: 'story_feed_malformed');
    } catch (_) {
      return StoryFeedResponse.empty(errorMessage: 'story_feed_unavailable');
    }
  }

  @override
  Future<void> completeOnboarding({
    required String name,
    DateTime? birthday,
    String? focusArea,
  }) async {
    final displayName = name.trim().isEmpty ? 'User' : name.trim();
    final data = await client.rpc(
      'complete_onboarding',
      params: {
        'p_nickname': displayName,
        'p_preferred_language': 'ko',
        'p_birthday': _dateParam(birthday),
        'p_focus_area': focusArea?.trim(),
      },
    );
    final response = _requiredMap(data, 'complete_onboarding');
    final state = _FlutterLaunchState.fromJson(
      _requiredMap(response['flutterLaunchState'], 'flutterLaunchState'),
    );

    if (state.route == _LiveLaunchRoute.appShell) {
      await _hydrateHomeData(state);
    } else {
      _profile =
          _profileFromMap(
            state.profile,
            starBalance: state.starBalance,
            onboardingComplete: state.onboardingCompleted,
          ).copyWith(
            name: displayName,
            onboardingComplete: state.onboardingCompleted,
          );
    }
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
    _clearSessionState();
    notifyListeners();
  }

  @override
  Future<DiaryEntry> saveDiary({
    required String title,
    required String body,
    String? people,
  }) async {
    final data = await client.rpc(
      'upsert_diary',
      params: {
        'p_body': body.trim(),
        'p_mood_label': null,
        'p_title': title.trim().isEmpty ? 'Diary' : title.trim(),
        'p_entry_date': null,
        'p_diary_id': null,
        'p_metadata': {
          'people': people?.trim() ?? '',
          'emotionTags': <String>[],
        },
      },
    );

    final response = _requiredMap(data, 'upsert_diary');
    final entry = _diaryEntryFromMap(
      _requiredMap(response['diary'], 'upsert_diary.diary'),
    );
    _upsertLocalDiary(entry);
    _applyStarBalance(response['starBalance']);
    await _refreshUMapSnapshot();
    _todayInsight = _insightFromCurrentState(
      userNote: '최근 Diary 기록이 U-Map에 반영되었어요.',
    );
    notifyListeners();
    return entry;
  }

  @override
  Future<DiaryEntry> updateDiary(DiaryEntry entry) async {
    final data = await client.rpc(
      'upsert_diary',
      params: {
        'p_body': entry.preview.trim(),
        'p_mood_label': null,
        'p_title': entry.title.trim().isEmpty ? 'Diary' : entry.title.trim(),
        'p_entry_date': null,
        'p_diary_id': entry.id,
        'p_metadata': {
          'people': entry.people?.trim() ?? '',
          'emotionTags': <String>[],
        },
      },
    );

    final response = _requiredMap(data, 'upsert_diary');
    final saved = _diaryEntryFromMap(
      _requiredMap(response['diary'], 'upsert_diary.diary'),
    );
    _upsertLocalDiary(saved);
    _applyStarBalance(response['starBalance']);
    await _refreshUMapSnapshot();
    notifyListeners();
    return saved;
  }

  @override
  Future<void> deleteDiary(String id) async {
    await client.rpc(
      'delete_diary_with_star_revoke',
      params: {'p_diary_id': id},
    );
    _diaryEntries = _diaryEntries.where((entry) => entry.id != id).toList();
    await _refreshStarBalance();
    await _refreshUMapSnapshot();
    _todayInsight = _insightFromCurrentState();
    notifyListeners();
  }

  @override
  Future<UserProfile> spendStars({
    required String reason,
    required int amount,
  }) async {
    final profile = _profile;
    if (profile == null) {
      throw const StarSpendException('not_authenticated');
    }

    try {
      final data = await client.rpc(
        'spend_star',
        params: {
          'p_reason': reason,
          'p_amount': amount,
          'p_ref_type': reason,
          'p_ref_id': null,
        },
      );
      final balance = (data as num?)?.toInt() ?? profile.starBalance - amount;
      final next = profile.copyWith(starBalance: balance);
      _profile = next;
      notifyListeners();
      return next;
    } on PostgrestException catch (error) {
      throw StarSpendException(error.message);
    }
  }

  @override
  Future<JournyReport> generateJournyReport() async {
    final profile = _profile;
    if (profile == null) {
      throw const StarSpendException('not_authenticated');
    }

    if (journyReportStarCost == 0) {
      return _generateFallbackJournyReport();
    }

    try {
      final data = await client.rpc(
        'generate_journy_report',
        params: {'p_star_cost': journyReportStarCost},
      );
      final response = _requiredMap(data, 'generate_journy_report');
      _applyStarBalance(response['starBalance']);
      notifyListeners();
      return JournyReport.fromJson(response['report']);
    } on PostgrestException catch (error) {
      if (error.message.contains('insufficient_star')) {
        throw StarSpendException(error.message);
      }
      return _generateFallbackJournyReport();
    }
  }

  @override
  Future<UMapDetailReport> generateUMapDetailReport() async {
    final profile = _profile;
    if (profile == null) {
      throw const StarSpendException('not_authenticated');
    }

    try {
      final data = await client.rpc(
        'generate_u_map_detail_report',
        params: {'p_star_cost': uMapDetailReportStarCost},
      );
      final response = _requiredMap(data, 'generate_u_map_detail_report');
      _applyStarBalance(response['starBalance']);
      notifyListeners();
      return UMapDetailReport.fromJson(response['report']);
    } on PostgrestException catch (error) {
      if (error.message.contains('insufficient_star')) {
        throw StarSpendException(error.message);
      }
      return _generateFallbackUMapDetailReport();
    }
  }

  Future<JournyReport> _generateFallbackJournyReport() async {
    if (journyReportStarCost > 0) {
      await spendStars(reason: 'journy_report', amount: journyReportStarCost);
    }
    final now = DateTime.now();
    final recentDiaries = _diaryEntries.take(6).toList();
    final visibleAxes = _axes
        .where((axis) => !axis.locked)
        .take(3)
        .toList(growable: false);
    final axesForReport = visibleAxes.isEmpty
        ? _axes.take(3).toList(growable: false)
        : visibleAxes;

    return JournyReport(
      id: 'fallback-journy-${now.microsecondsSinceEpoch}',
      title: '지금의 흐름을 다시 읽는 시기',
      summary:
          '서버 리포트 생성기가 아직 연결되지 않아, 현재 앱에 로드된 Diary와 U-Map 신호로 임시 Journy를 구성했어요. 기록이 쌓일수록 이 흐름은 더 선명해집니다.',
      sourceWindowLabel: '자기탐구 기록',
      sourceCounts: {
        'diary': recentDiaries.length,
        'answers': 0,
        'uMapSignals': axesForReport.length,
      },
      timelineEvents: [
        for (final entry in recentDiaries)
          JournyTimelineEvent(
            dateLabel: entry.dateLabel,
            title: entry.title,
            body: entry.preview.trim().isEmpty
                ? '이 시점의 기록이 Journy 흐름에 포함되었어요.'
                : entry.preview.trim(),
          ),
        if (recentDiaries.isEmpty)
          const JournyTimelineEvent(
            dateLabel: 'Today',
            title: 'Journy 시작',
            body: '아직 Diary 기록이 적어 U-Map 신호를 중심으로 첫 흐름을 구성했어요.',
          ),
      ],
      patterns: [
        for (final axis in axesForReport)
          JournyInsightBlock(
            title: axis.label,
            body: axis.copy,
            confidenceLabel: axis.value >= 0.7 ? '반복 신호 강함' : '형성 중',
          ),
      ],
      turningPoints: const [
        JournyInsightBlock(
          title: '기록이 흐름으로 묶이기 시작한 지점',
          body: '최근 기록과 U-Map 신호가 단편적인 반응이 아니라 하나의 방향으로 이어지기 시작했어요.',
          confidenceLabel: '임시 분석',
        ),
      ],
      nextSteps: const [
        JournyInsightBlock(
          title: '다음 탐구 질문',
          body: '지금 내가 반복해서 돌아보는 선택 기준은 무엇이고, 그 기준은 나를 어디로 데려가고 있을까?',
          confidenceLabel: '추천',
        ),
      ],
      evidence: [
        for (final entry in recentDiaries.take(3))
          JournyEvidenceItem(
            label: entry.title,
            body: entry.preview,
            sourceType: 'Diary',
          ),
        for (final axis in axesForReport.take(2))
          JournyEvidenceItem(
            label: axis.label,
            body: axis.copy,
            sourceType: 'U-Map',
          ),
      ],
      createdAt: now,
    );
  }

  Future<UMapDetailReport> _generateFallbackUMapDetailReport() async {
    if (uMapDetailReportStarCost > 0) {
      await spendStars(
        reason: 'u_map_detail_report',
        amount: uMapDetailReportStarCost,
      );
    }

    final now = DateTime.now();
    final recentDiaries = _diaryEntries.take(6).toList();
    final visibleAxes = _axes
        .where((axis) => !axis.locked)
        .take(5)
        .toList(growable: false);
    final axesForReport = visibleAxes.isEmpty
        ? _axes.take(5).toList(growable: false)
        : visibleAxes;
    final sourceCount = axesForReport.fold<int>(
      recentDiaries.length,
      (total, axis) => total + axis.recordCount,
    );
    final sufficiencyScore = mathMinInt(
      94,
      38 + recentDiaries.length * 7 + axesForReport.length * 6,
    );

    notifyListeners();
    return UMapDetailReport(
      id: 'fallback-umap-report-${now.microsecondsSinceEpoch}',
      title: 'U-Map 상세 리포트',
      coreSentence:
          '현재 U-Map은 기록 속 반복 신호를 바탕으로, 생각의 중심과 아직 더 살펴볼 영역을 함께 보여주고 있습니다.',
      summary:
          '서버 리포트 생성기가 아직 연결되지 않아 앱 안의 U-Map 스냅샷과 Diary 기록으로 상세 리포트를 구성했습니다. 모든 해석은 기록 근거를 기반으로 하며, 의료적 진단이나 고정된 유형 판단이 아닙니다.',
      dataSufficiency: UMapDataSufficiency(
        score: sufficiencyScore,
        label: sufficiencyScore >= 75 ? '분석 충실도 높음' : '분석 충실도 보통',
        items: [
          UMapDataSufficiencyItem(
            label: 'U-Map 노드',
            value: '${axesForReport.length * 6}',
            status: axesForReport.length >= 4 ? '충분' : '보강 필요',
          ),
          UMapDataSufficiencyItem(
            label: '기록 근거',
            value: '$sourceCount',
            status: sourceCount >= 20 ? '충분' : '보통',
          ),
          UMapDataSufficiencyItem(
            label: '최근 기록',
            value: recentDiaries.isEmpty
                ? '기록 없음'
                : recentDiaries.first.dateLabel,
            status: recentDiaries.isEmpty ? '부족' : '반영됨',
          ),
        ],
      ),
      sourceCounts: {
        'nodes': axesForReport.length * 6,
        'records': sourceCount,
        'diary': recentDiaries.length,
      },
      keywords: [
        for (final axis in axesForReport.take(4)) axis.label,
        '반복 패턴',
        '다음 행동',
      ],
      sections: [
        UMapReportSection(
          type: 'structure',
          title: 'U-Map 구조 분석',
          body:
              '상위 노드들은 현재 사용자의 관심이 어디에 모여 있는지를 보여줍니다. 잠겨 있거나 근거가 적은 노드는 결론을 내리기보다 다음 기록에서 더 확인해야 할 영역으로 남겨두는 편이 안전합니다.',
          insights: [
            '높은 축은 최근 기록에서 반복적으로 강화된 신호입니다.',
            '근거가 적은 영역은 해석보다 질문으로 이어가는 것이 좋습니다.',
          ],
          evidenceLabels: axesForReport
              .take(3)
              .map((axis) => axis.label)
              .toList(),
        ),
        UMapReportSection(
          type: 'themes',
          title: '주요 주제군',
          body:
              '현재 리포트에서는 U-Map 축과 Diary 기록을 자기이해, 선택 기준, 감정 흐름, 실행 리듬으로 묶어 읽었습니다.',
          insights: [
            '생각을 구조화할수록 감정 부담이 낮아지는 흐름이 보입니다.',
            '목표 노드는 다음 행동과 함께 연결될 때 더 안정적으로 유지됩니다.',
          ],
          evidenceLabels: recentDiaries
              .take(2)
              .map((entry) => entry.title)
              .toList(),
        ),
        const UMapReportSection(
          type: 'patterns',
          title: '반복 패턴과 내적 충돌',
          body:
              '기록상 기대와 부담이 함께 나타나는 구간에서는 실행이 늦어질 수 있습니다. 이 흐름은 성향의 문제가 아니라, 선택 직후의 불확실성을 줄이는 장치가 필요한 신호로 볼 수 있습니다.',
          insights: [
            '선택 기준이 많아질수록 결정 피로가 커질 수 있습니다.',
            '감정 기록 이후에는 다음 행동을 더 명확히 하려는 경향이 있습니다.',
          ],
          evidenceLabels: ['최근 기록', '상위 U-Map 노드'],
        ),
        const UMapReportSection(
          type: 'strength',
          title: '강점과 자원',
          body:
              '사용자의 U-Map은 단순한 요약보다 연결을 통해 의미를 찾는 방식에 강점이 있습니다. 복잡한 생각을 구조로 바꾸는 힘은 앞으로의 기록과 실행 모두에 자원이 됩니다.',
          insights: ['자기성찰과 패턴 인식이 강점으로 보입니다.', '기록을 통해 방향을 회복하는 자원이 있습니다.'],
          evidenceLabels: ['연결 노드', 'Diary'],
        ),
        const UMapReportSection(
          type: 'risk',
          title: '주의 신호',
          body:
              '해야 할 일과 해석해야 할 일이 동시에 늘어나면 U-Map이 정리 도구보다 부담으로 느껴질 수 있습니다. 이때는 노드를 늘리기보다 하나의 노드에 다음 행동만 붙이는 편이 좋습니다.',
          insights: [
            '목표 과부하로 인한 결정 피로를 주의해야 합니다.',
            '회복 기록이 줄어든다면 새 목표 추가를 잠시 늦추는 것이 좋습니다.',
          ],
          evidenceLabels: ['목표 노드', '회복 기록'],
        ),
      ],
      actionPlans: const [
        UMapActionPlan(
          title: '오래 남은 노드 하나를 선택하기',
          body: '가장 오래 해결되지 않은 노드 하나만 고르고, 오늘 할 수 있는 행동을 하나 붙여보세요.',
          horizon: '오늘',
        ),
        UMapActionPlan(
          title: '기준을 세 개로 제한하기',
          body: '선택 관련 노드는 기준을 세 개만 남기고 나머지는 보류 노드로 이동하세요.',
          horizon: '이번 주',
        ),
        UMapActionPlan(
          title: '회복 노드 만들기',
          body: '목표와 고민 노드가 많다면 회복 루틴 노드를 따로 만들어 균형을 맞춰보세요.',
          horizon: '이번 달',
        ),
      ],
      recordingGuides: const [
        '오늘의 선택을 어렵게 만든 기준은 무엇이었나요?',
        '내가 반복해서 돌아온 감정은 무엇인가요?',
        '지금 추가 목표보다 유지해야 할 루틴은 무엇인가요?',
        '다음 리포트에서 더 확인하고 싶은 노드는 무엇인가요?',
      ],
      evidence: [
        for (final entry in recentDiaries.take(3))
          JournyEvidenceItem(
            label: entry.title,
            body: entry.preview,
            sourceType: 'Diary',
          ),
        for (final axis in axesForReport.take(3))
          JournyEvidenceItem(
            label: axis.label,
            body: axis.copy,
            sourceType: 'U-Map',
          ),
      ],
      createdAt: now,
    );
  }

  @override
  Future<ClueInsight> saveQuestionAnswers(List<String> answers) async {
    final resolved = await _resolveQuestionAnswers(answers);
    for (final answer in resolved) {
      await saveOnboardingAnswer(
        QuestionAnswerInput(
          questionSet: _questionSetBasicFree,
          questionId: answer.questionId,
          selectedOptionId: answer.selectedOptionId,
          optionalText: answer.optionalText,
        ),
      );
    }

    await _refreshUMapSnapshot();
    _todayInsight = _insightFromCurrentState(questionCount: resolved.length);
    notifyListeners();
    return _todayInsight;
  }

  @override
  Future<void> updateInsightNote(String note) async {
    await client.rpc(
      'save_insight_feedback',
      params: {
        'p_target_type': _insightTargetType,
        'p_target_id': _uuidOrNull(todayInsight.id),
        'p_action': note.trim().isEmpty ? 'clear_note' : 'revise_note',
        'p_note': note.trim(),
        'p_metadata': <String, dynamic>{},
      },
    );
    _todayInsight = _todayInsight.copyWith(userNote: note.trim());
    notifyListeners();
  }

  @override
  Future<void> hideInsight() async {
    await client.rpc(
      'save_insight_feedback',
      params: {
        'p_target_type': _insightTargetType,
        'p_target_id': _uuidOrNull(todayInsight.id),
        'p_action': 'hide',
        'p_note': null,
        'p_metadata': <String, dynamic>{},
      },
    );
    _todayInsight = _todayInsight.copyWith(hidden: true);
    notifyListeners();
  }

  @override
  Future<void> disagreeInsight() async {
    await client.rpc(
      'save_insight_feedback',
      params: {
        'p_target_type': _insightTargetType,
        'p_target_id': _uuidOrNull(todayInsight.id),
        'p_action': 'disagree',
        'p_note': null,
        'p_metadata': <String, dynamic>{},
      },
    );
    _todayInsight = _todayInsight.copyWith(disagreed: true);
    notifyListeners();
  }

  @override
  Future<void> reportInsight(String reason) async {
    final trimmed = reason.trim();
    await client.rpc(
      'report_ai_output',
      params: {
        'p_target_type': _insightTargetType,
        'p_target_id': _uuidOrNull(todayInsight.id),
        'p_reason': trimmed.isEmpty ? 'unspecified' : trimmed,
        'p_details': null,
        'p_metadata': <String, dynamic>{},
      },
    );
    _todayInsight = _todayInsight.copyWith(
      reported: true,
      userNote: trimmed.isEmpty ? '문제 신고가 접수되었어요.' : trimmed,
    );
    notifyListeners();
  }

  Future<_FlutterLaunchState> _loadFlutterLaunchState() async {
    Object? data;
    try {
      data = await client.rpc('get_flutter_launch_state');
    } on PostgrestException catch (error) {
      if (error.code != 'PGRST202') {
        rethrow;
      }
      final legacyData = await client.rpc('get_launch_gate_state');
      return _FlutterLaunchState.fromLaunchGateJson(
        _requiredMap(legacyData, 'get_launch_gate_state'),
      );
    }

    return _FlutterLaunchState.fromJson(
      _requiredMap(data, 'get_flutter_launch_state'),
    );
  }

  Future<void> _hydrateHomeData(_FlutterLaunchState state) async {
    _profile = await _loadProfile(state);
    _diaryEntries = await _loadDiaries();
    await _refreshUMapSnapshot();
    _todayInsight = _insightFromCurrentState();
  }

  Future<UserProfile> _loadProfile(_FlutterLaunchState state) async {
    final profileMap = state.profile ?? await _selectProfile();
    final starBalance = await _loadStarBalance(fallback: state.starBalance);
    final levelStats = await _loadLevelStats(profileMap);
    return _profileFromMap(
      profileMap,
      starBalance: starBalance,
      onboardingComplete: state.onboardingCompleted,
      levelStats: levelStats,
    );
  }

  Future<Map<String, dynamic>?> _selectProfile() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }
    final data = await client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return _optionalMap(data);
  }

  Future<List<DiaryEntry>> _loadDiaries() async {
    Object? data;
    try {
      data = await client
          .from('diaries')
          .select(
            'id, entry_date, title, body, metadata, created_at, updated_at',
          )
          .isFilter('deleted_at', null)
          .order('entry_date', ascending: false);
    } on PostgrestException catch (error) {
      if (error.code != '42703' ||
          !error.message.contains('diaries.metadata')) {
        rethrow;
      }
      data = await client
          .from('diaries')
          .select('id, entry_date, title, body, created_at, updated_at')
          .isFilter('deleted_at', null)
          .order('entry_date', ascending: false);
    }

    return _mapList(data).map(_diaryEntryFromMap).toList();
  }

  Future<int> _loadStarBalance({required int fallback}) async {
    final data = await client.rpc('get_star_balance');
    return (data as num?)?.toInt() ?? fallback;
  }

  Future<UserLevelStats> _loadLevelStats(
    Map<String, dynamic>? profileMap,
  ) async {
    final joinedAt = DateTime.tryParse(
      (profileMap?['created_at'] as String?) ?? '',
    );
    final joinedDays = joinedAt == null
        ? 0
        : DateTime.now().difference(joinedAt.toLocal()).inDays;

    final questionCount =
        await _countRows('onboarding_answers') +
        await _countRows('answers') +
        await _countRows('relation_answers') +
        await _countRows('user_card_answers');
    final diaryCount = await _countRows(
      'diaries',
      deletedAtColumn: 'deleted_at',
    );
    final attendanceDays = await _countRows(
      'star_ledger',
      equals: const {'reason': 'daily_attendance'},
    );

    return UserLevelStats(
      questionCount: questionCount,
      diaryCount: diaryCount,
      attendanceDays: attendanceDays,
      joinedDays: joinedDays,
    );
  }

  Future<int> _countRows(
    String table, {
    String? deletedAtColumn,
    Map<String, Object?> equals = const {},
  }) async {
    try {
      PostgrestFilterBuilder<List<Map<String, dynamic>>> query = client
          .from(table)
          .select('id');
      for (final entry in equals.entries) {
        query = query.eq(entry.key, entry.value as Object);
      }
      if (deletedAtColumn != null) {
        query = query.isFilter(deletedAtColumn, null);
      }
      final data = await query;
      return _mapList(data).length;
    } on PostgrestException {
      return 0;
    }
  }

  Future<void> _refreshStarBalance() async {
    final profile = _profile;
    if (profile == null) {
      return;
    }
    final balance = await _loadStarBalance(fallback: profile.starBalance);
    _profile = profile.copyWith(starBalance: balance);
  }

  Future<void> _refreshUMapSnapshot() async {
    Object? data;
    try {
      data = await client.rpc('get_latest_u_map');
    } on PostgrestException catch (error) {
      if (error.code != 'PGRST202') {
        rethrow;
      }
      data = await client.rpc('get_my_u_map');
    }

    final snapshot = _optionalMap(data);
    final axes = snapshot == null ? _mapList(data) : _mapList(snapshot['axes']);
    _hasLowUMapData = snapshot == null
        ? axes.isEmpty
        : snapshot['lowData'] == true;
    _axes = axes.isEmpty
        ? List.of(axisSummaries)
        : [
            for (var index = 0; index < axes.length; index++)
              _axisSummaryFromMap(axes[index], index),
          ];
  }

  Future<List<_ResolvedQuestionAnswer>> _resolveQuestionAnswers(
    List<String> answers,
  ) async {
    final normalizedAnswers = answers
        .map((answer) => answer.trim())
        .where((answer) => answer.isNotEmpty)
        .toList();
    if (normalizedAnswers.isEmpty) {
      throw StateError('No question answers to submit.');
    }

    final questions = await client
        .from('questions')
        .select('id, sequence, prompt')
        .eq('question_set', _questionSetBasicFree)
        .eq('active', true)
        .order('sequence', ascending: true)
        .limit(normalizedAnswers.length);
    final questionRows = _mapList(questions);
    if (questionRows.length < normalizedAnswers.length) {
      throw StateError(
        'Active Supabase questions are not available for this answer flow.',
      );
    }

    final resolved = <_ResolvedQuestionAnswer>[];
    for (var index = 0; index < normalizedAnswers.length; index++) {
      final questionId = questionRows[index]['id'] as String?;
      if (questionId == null || questionId.isEmpty) {
        throw StateError('Supabase question id is missing.');
      }

      final options = await client
          .from('question_options')
          .select('id, label, sequence')
          .eq('question_id', questionId)
          .order('sequence', ascending: true);
      final optionRows = _mapList(options);
      final selectedOptionId = _matchOptionId(
        answer: normalizedAnswers[index],
        options: optionRows,
      );
      if (selectedOptionId == null) {
        throw StateError(
          'The current UI answer cannot be mapped to a stable Supabase option id.',
        );
      }

      resolved.add(
        _ResolvedQuestionAnswer(
          questionId: questionId,
          selectedOptionId: selectedOptionId,
          optionalText: normalizedAnswers[index],
        ),
      );
    }
    return resolved;
  }

  OnboardingQuestion _onboardingQuestionFromMap(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> options,
  ) {
    return OnboardingQuestion(
      id: data['id'] as String,
      questionSet: (data['question_set'] as String?) ?? _questionSetBasicFree,
      sequence: (data['sequence'] as num?)?.toInt() ?? 0,
      prompt: (data['prompt'] as String?) ?? '',
      helperText: data['helper_text'] as String?,
      axisKeys: _stringList(data['axis_keys']),
      options: [
        for (final option in options)
          OnboardingQuestionOption(
            id: option['id'] as String,
            label: (option['label'] as String?) ?? '',
            sequence: (option['sequence'] as num?)?.toInt() ?? 0,
          ),
      ],
    );
  }

  ExplorationCard _explorationCardFromMap(Map<String, dynamic> data) {
    final type = switch ((data['card_type'] as String?) ?? 'scenario_choice') {
      'binary_choice' => ExplorationCardType.binaryChoice,
      'multiple_choice' => ExplorationCardType.multipleChoice,
      'priority_selection' => ExplorationCardType.prioritySelection,
      _ => ExplorationCardType.scenarioChoice,
    };
    final options = _mapList(data['options'])
        .map(
          (option) => ExplorationCardOption(
            id: (option['id'] as String?) ?? '',
            label: (option['label'] as String?) ?? '',
          ),
        )
        .where((option) => option.id.isNotEmpty && option.label.isNotEmpty)
        .toList();
    return ExplorationCard(
      id: (data['card_id'] as String?) ?? '',
      type: type,
      question: (data['question'] as String?) ?? '',
      options: options,
      requiredSelections: (data['required_selections'] as num?)?.toInt() ?? 1,
    );
  }

  String? _matchOptionId({
    required String answer,
    required List<Map<String, dynamic>> options,
  }) {
    final normalizedAnswer = _normalizeAnswer(answer);
    for (final option in options) {
      final label = option['label'] as String?;
      final id = option['id'] as String?;
      if (label == null || id == null) {
        continue;
      }
      final normalizedLabel = _normalizeAnswer(label);
      if (normalizedAnswer == normalizedLabel ||
          normalizedAnswer.contains(normalizedLabel) ||
          normalizedLabel.contains(normalizedAnswer)) {
        return id;
      }
    }
    return null;
  }

  void _applyStarBalance(Object? value) {
    final profile = _profile;
    if (profile == null) {
      return;
    }
    final balance = (value as num?)?.toInt();
    if (balance != null) {
      _profile = profile.copyWith(starBalance: balance);
    }
  }

  void _upsertLocalDiary(DiaryEntry entry) {
    final index = _diaryEntries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      _diaryEntries = [entry, ..._diaryEntries];
    } else {
      final next = List<DiaryEntry>.of(_diaryEntries);
      next[index] = entry;
      _diaryEntries = next;
    }
  }

  UserProfile _profileFromMap(
    Map<String, dynamic>? data, {
    required int starBalance,
    required bool onboardingComplete,
    UserLevelStats? levelStats,
  }) {
    final nickname = (data?['nickname'] as String?)?.trim();
    final focusArea = (data?['focus_area'] as String?)?.trim();
    final email = client.auth.currentUser?.email?.trim();
    return UserProfile(
      name: nickname?.isNotEmpty == true ? nickname! : 'User',
      email: email?.isNotEmpty == true ? email! : 'user@fi-you.app',
      onboardingComplete: onboardingComplete,
      starBalance: starBalance,
      levelStats: levelStats ?? const UserLevelStats(),
      profileLine: focusArea?.isNotEmpty == true
          ? focusArea!
          : '기록을 통해 나를 알아가는 중',
    );
  }

  DiaryEntry _diaryEntryFromMap(Map<String, dynamic> data) {
    final entryDate = DateTime.tryParse((data['entry_date'] as String?) ?? '');
    final body = (data['body'] as String?) ?? '';
    final title = (data['title'] as String?)?.trim();
    final metadata = _optionalMap(data['metadata']);
    final people = (metadata?['people'] as String?)?.trim();
    return DiaryEntry(
      id: data['id'] as String,
      yearLabel: entryDate == null ? '' : '${entryDate.year}년',
      dateLabel: entryDate == null
          ? ''
          : '${entryDate.month}월 ${entryDate.day}일',
      title: title?.isNotEmpty == true ? title! : 'Diary',
      preview: body,
      starReward: body.trim().length >= 50 ? 12 : 0,
      people: people?.isNotEmpty == true ? people : null,
      editable: true,
      editWindowLabel: '저장된 Diary',
    );
  }

  AxisSummary _axisSummaryFromMap(Map<String, dynamic> data, int index) {
    final fallback = axisSummaries[index % axisSummaries.length];
    final score = (data['score'] as num?)?.toDouble() ?? 0;
    final sourceCount = (data['sourceCount'] as num?)?.toInt() ?? 0;
    final evidence = _mapList(data['evidence']);
    final recentSource = evidence.isEmpty
        ? '기록 대기'
        : ((evidence.first['sourceType'] as String?) ?? '기록');
    return AxisSummary(
      label: (data['labelKo'] as String?) ?? fallback.label,
      value: score.clamp(0, 100) / 100,
      copy: (data['descriptionKo'] as String?) ?? fallback.copy,
      icon: fallback.icon,
      color: fallback.color,
      recordCount: sourceCount,
      recentSource: recentSource,
      clue: sourceCount == 0
          ? '아직 이 축을 설명할 기록이 충분하지 않아요.'
          : '최근 기록에서 반복되는 단서가 반영되었어요.',
      locked: sourceCount == 0,
    );
  }

  ClueInsight _insightFromCurrentState({String? userNote, int? questionCount}) {
    final visibleAxes = _axes.take(2).map((axis) => axis.label).toList();
    return ClueInsight(
      id: 'insight-${DateTime.now().microsecondsSinceEpoch}',
      title: '새로 발견한 단서',
      body: _hasLowUMapData
          ? '아직 기록이 적어 낮은 확신도로 U-Map을 보여주고 있어요.'
          : '최근 기록과 응답에서 반복되는 흐름이 U-Map에 반영되었어요.',
      sourceCount: _axes.fold<int>(
        _diaryEntries.length,
        (total, axis) => total + axis.recordCount,
      ),
      diaryCount: _diaryEntries.length,
      questionCount: questionCount ?? 0,
      axes: visibleAxes.isEmpty ? const ['U-Map'] : visibleAxes,
      sources: [
        if (_diaryEntries.isNotEmpty) _diaryEntries.first.title,
        if (questionCount != null) '오늘 질문 응답 $questionCount개',
      ],
      userNote: userNote,
    );
  }

  void _clearSessionState() {
    _profile = null;
    _diaryEntries = <DiaryEntry>[];
    _axes = List.of(axisSummaries);
    _hasLowUMapData = true;
  }

  static Map<String, dynamic> _requiredMap(Object? data, String context) {
    final map = _optionalMap(data);
    if (map == null) {
      throw StateError('$context returned an invalid response.');
    }
    return map;
  }

  static Map<String, dynamic>? _optionalMap(Object? data) {
    if (data == null) {
      return null;
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static List<Map<String, dynamic>> _mapList(Object? data) {
    if (data is! List) {
      return <Map<String, dynamic>>[];
    }
    final maps = <Map<String, dynamic>>[];
    for (final item in data) {
      final map = _optionalMap(item);
      if (map != null) {
        maps.add(map);
      }
    }
    return maps;
  }

  static String _normalizeAnswer(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  static List<String> _stringList(Object? data) {
    if (data is! List) {
      return const <String>[];
    }
    return data.whereType<String>().toList();
  }

  static String? _dateParam(DateTime? value) {
    if (value == null) {
      return null;
    }
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static String? _uuidOrNull(String value) {
    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidPattern.hasMatch(value) ? value : null;
  }
}
