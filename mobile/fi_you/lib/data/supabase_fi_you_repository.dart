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
    title: '오늘 발견된 단서',
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
      redirectTo: 'com.fiyou.app://login-callback/',
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
      _profile = _profileFromLaunchState(state).copyWith(
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
      userNote: trimmed.isEmpty ? '臾몄젣 ?좉퀬媛 ?묒닔?섏뿀?듬땲??' : trimmed,
    );
    notifyListeners();
  }

  Future<_FlutterLaunchState> _loadFlutterLaunchState() async {
    final data = await client.rpc('get_flutter_launch_state');
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
    return _profileFromMap(
      profileMap,
      starBalance: starBalance,
      onboardingComplete: state.onboardingCompleted,
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
    final data = await client
        .from('diaries')
        .select('id, entry_date, title, body, metadata, created_at, updated_at')
        .isFilter('deleted_at', null)
        .order('entry_date', ascending: false);
    return _mapList(data).map(_diaryEntryFromMap).toList();
  }

  Future<int> _loadStarBalance({required int fallback}) async {
    final data = await client.rpc('get_star_balance');
    return (data as num?)?.toInt() ?? fallback;
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
    final data = await client.rpc('get_latest_u_map');
    final snapshot = _requiredMap(data, 'get_latest_u_map');
    final axes = _mapList(snapshot['axes']);
    _hasLowUMapData = snapshot['lowData'] == true;
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

  UserProfile _profileFromLaunchState(_FlutterLaunchState state) {
    return _profileFromMap(
      state.profile,
      starBalance: state.starBalance,
      onboardingComplete: state.onboardingCompleted,
    );
  }

  UserProfile _profileFromMap(
    Map<String, dynamic>? data, {
    required int starBalance,
    required bool onboardingComplete,
  }) {
    final user = client.auth.currentUser;
    final nickname = (data?['nickname'] as String?)?.trim();
    final focusArea = (data?['focus_area'] as String?)?.trim();
    final email = user?.email?.trim();
    return UserProfile(
      name: nickname?.isNotEmpty == true ? nickname! : 'User',
      email: email?.isNotEmpty == true ? email! : 'user@fi-you.app',
      onboardingComplete:
          (data?['onboarding_completed'] as bool?) ?? onboardingComplete,
      starBalance: starBalance,
      level: (starBalance ~/ 100) + 1,
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
      yearLabel: entryDate == null ? '' : '4{entryDate.year}년',
      dateLabel: entryDate == null
          ? ''
          : '4{entryDate.month}월 4{entryDate.day}일',
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
      id: 'insight-4{DateTime.now().microsecondsSinceEpoch}',
      title: '새로 발견된 단서',
      body: _hasLowUMapData
          ? '아직 기록이 적어 낮은 확신도로 U-Map을 보여주고 있어요.'
          : '최근 기록과 답변에서 반복되는 흐름이 U-Map에 반영되었어요.',
      sourceCount: _axes.fold<int>(
        _diaryEntries.length,
        (total, axis) => total + axis.recordCount,
      ),
      diaryCount: _diaryEntries.length,
      questionCount: questionCount ?? 0,
      axes: visibleAxes.isEmpty ? const ['U-Map'] : visibleAxes,
      sources: [
        if (_diaryEntries.isNotEmpty) _diaryEntries.first.title,
        if (questionCount != null) '오늘 질문 답변 4questionCount개',
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
