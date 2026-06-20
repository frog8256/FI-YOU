import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/mock/fi_you_mock_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFiYouRepository extends FiYouRepository {
  SupabaseFiYouRepository(this.client);

  final SupabaseClient client;

  UserProfile? _profile;
  final List<DiaryEntry> _diaryEntries = List.of(initialDiaryEntries);
  ClueInsight _todayInsight = const ClueInsight(
    id: 'insight-today',
    title: '오늘 발견한 단서',
    body: '혼자 생각을 정리하는 시간이 회복에 도움이 되는 흐름으로 보여요. 아직 확정된 해석은 아니에요.',
    sourceCount: 12,
    diaryCount: 2,
    questionCount: 3,
    axes: ['관계 흐름', '감정 인식'],
    sources: ['6월 18일 Diary', '오늘 질문 응답', '최근 감정 기록'],
  );

  @override
  UserProfile? get profile => _profile;

  @override
  List<DiaryEntry> get diaryEntries => List.unmodifiable(_diaryEntries);

  @override
  List<AxisSummary> get axes => List.unmodifiable(axisSummaries);

  @override
  ClueInsight get todayInsight => _todayInsight;

  @override
  bool get hasLowUMapData => _diaryEntries.length < 3;

  @override
  bool get storeBillingConnected => false;

  @override
  Future<LaunchSnapshot> restoreLaunchState() async {
    if (client.auth.currentSession == null) {
      _profile = null;
      notifyListeners();
      return const LaunchSnapshot(status: LaunchStatus.signedOut);
    }
    return _loadLaunchGateState();
  }

  @override
  Future<void> signIn() async {
    await client.auth.signInAnonymously();
    final gate = await _loadLaunchGateState();
    if (gate.status == LaunchStatus.error) {
      throw StateError(gate.message ?? '계정 상태를 확인하지 못했어요.');
    }
  }

  @override
  Future<void> completeOnboarding({required String name}) async {
    final displayName = name.trim().isEmpty ? 'User' : name.trim();
    await _callOptionalRpc(
      'complete_onboarding',
      params: {'display_name': displayName},
    );
    _profile = _baseProfile().copyWith(
      name: displayName,
      onboardingComplete: true,
    );
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
    _profile = null;
    notifyListeners();
  }

  @override
  Future<DiaryEntry> saveDiary({
    required String title,
    required String body,
    String? people,
  }) async {
    final now = DateTime.now();
    final entry = DiaryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      yearLabel: '${now.year}년',
      dateLabel: '${now.month}월 ${now.day}일',
      title: title.trim().isEmpty ? '오늘의 Diary' : title.trim(),
      preview: body.trim(),
      starReward: 12,
      people: people?.trim().isNotEmpty == true ? people!.trim() : null,
      editable: true,
      editWindowLabel: '내일 오전 9시까지 수정 가능',
    );
    _diaryEntries.insert(0, entry);
    _todayInsight = _todayInsight.copyWith(
      userNote: '최근 Diary 기록이 U-Map 단서에 반영될 준비가 되었어요.',
    );
    await _callOptionalRpc('record_diary_entry', params: _diaryParams(entry));
    notifyListeners();
    return entry;
  }

  @override
  Future<DiaryEntry> updateDiary(DiaryEntry entry) async {
    final index = _diaryEntries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      _diaryEntries.insert(0, entry);
    } else {
      _diaryEntries[index] = entry;
    }
    await _callOptionalRpc('update_diary_entry', params: _diaryParams(entry));
    notifyListeners();
    return entry;
  }

  @override
  Future<void> deleteDiary(String id) async {
    _diaryEntries.removeWhere((entry) => entry.id == id);
    await _callOptionalRpc('delete_diary_entry', params: {'entry_id': id});
    notifyListeners();
  }

  @override
  Future<ClueInsight> saveQuestionAnswers(List<String> answers) async {
    _todayInsight = ClueInsight(
      id: 'insight-${DateTime.now().microsecondsSinceEpoch}',
      title: '새로 발견한 단서',
      body: '갈등 장면에서 감정을 먼저 정리하려는 흐름이 기록되었어요.',
      sourceCount: answers.length + _diaryEntries.length,
      diaryCount: _diaryEntries.length,
      questionCount: answers.length,
      axes: const ['관계 흐름', '감정 인식'],
      sources: [
        '오늘 질문 응답 ${answers.length}개',
        if (_diaryEntries.isNotEmpty) _diaryEntries.first.title,
      ],
    );
    await _callOptionalRpc('record_question_answers', params: {'answers': answers});
    notifyListeners();
    return _todayInsight;
  }

  @override
  Future<void> updateInsightNote(String note) async {
    _todayInsight = _todayInsight.copyWith(userNote: note.trim());
    await _callOptionalRpc('update_insight_note', params: {'note': note.trim()});
    notifyListeners();
  }

  @override
  Future<void> hideInsight() async {
    _todayInsight = _todayInsight.copyWith(hidden: true);
    await _callOptionalRpc('hide_insight', params: {'insight_id': todayInsight.id});
    notifyListeners();
  }

  @override
  Future<void> disagreeInsight() async {
    _todayInsight = _todayInsight.copyWith(disagreed: true);
    await _callOptionalRpc('disagree_insight', params: {'insight_id': todayInsight.id});
    notifyListeners();
  }

  @override
  Future<void> reportInsight(String reason) async {
    final trimmed = reason.trim();
    _todayInsight = _todayInsight.copyWith(
      reported: true,
      userNote: trimmed.isEmpty ? '문제 신고가 접수되었어요.' : trimmed,
    );
    await _callOptionalRpc(
      'report_insight',
      params: {'insight_id': todayInsight.id, 'reason': trimmed},
    );
    notifyListeners();
  }

  Future<LaunchSnapshot> _loadLaunchGateState() async {
    try {
      final data = await client.rpc('get_launch_gate_state');
      final gate = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
      final onboardingComplete = gate['onboarding_complete'] == true;
      _profile = UserProfile(
        name: (gate['display_name'] as String?)?.trim().isNotEmpty == true
            ? gate['display_name'] as String
            : _baseProfile().name,
        email: (gate['email'] as String?) ?? _baseProfile().email,
        onboardingComplete: onboardingComplete,
        starBalance: (gate['star_balance'] as num?)?.toInt() ?? 150,
        level: (gate['level'] as num?)?.toInt() ?? 2,
        profileLine: (gate['profile_line'] as String?) ?? '관찰과 탐구를 좋아하는',
      );
      notifyListeners();
      return LaunchSnapshot(
        status: onboardingComplete ? LaunchStatus.ready : LaunchStatus.onboardingRequired,
      );
    } catch (_) {
      _profile = _baseProfile().copyWith(onboardingComplete: false);
      notifyListeners();
      return const LaunchSnapshot(status: LaunchStatus.onboardingRequired);
    }
  }

  UserProfile _baseProfile() {
    final user = client.auth.currentUser;
    final email = user?.email?.trim();
    return UserProfile(
      name: 'User',
      email: email?.isNotEmpty == true ? email! : 'user@fi-you.app',
      onboardingComplete: false,
      starBalance: 150,
      level: 2,
      profileLine: '관찰과 탐구를 좋아하는',
    );
  }

  Future<void> _callOptionalRpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    try {
      await client.rpc(functionName, params: params);
    } catch (_) {
      // Backend contract may roll out incrementally; local UI state remains intact.
    }
  }

  Map<String, dynamic> _diaryParams(DiaryEntry entry) {
    return {
      'entry_id': entry.id,
      'title': entry.title,
      'body': entry.preview,
      'people': entry.people,
      'year_label': entry.yearLabel,
      'date_label': entry.dateLabel,
    };
  }
}
