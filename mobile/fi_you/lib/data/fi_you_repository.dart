import 'package:fi_you/mock/fi_you_mock_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LaunchStatus { checking, signedOut, onboardingRequired, ready, error }

class LaunchSnapshot {
  const LaunchSnapshot({required this.status, this.message});

  final LaunchStatus status;
  final String? message;
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.onboardingComplete,
    required this.starBalance,
    required this.level,
    required this.profileLine,
  });

  final String name;
  final String email;
  final bool onboardingComplete;
  final int starBalance;
  final int level;
  final String profileLine;

  UserProfile copyWith({
    String? name,
    String? email,
    bool? onboardingComplete,
    int? starBalance,
    int? level,
    String? profileLine,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      starBalance: starBalance ?? this.starBalance,
      level: level ?? this.level,
      profileLine: profileLine ?? this.profileLine,
    );
  }
}

class ClueInsight {
  const ClueInsight({
    required this.id,
    required this.title,
    required this.body,
    required this.sourceCount,
    required this.diaryCount,
    required this.questionCount,
    required this.axes,
    required this.sources,
    this.hidden = false,
    this.disagreed = false,
    this.reported = false,
    this.userNote,
  });

  final String id;
  final String title;
  final String body;
  final int sourceCount;
  final int diaryCount;
  final int questionCount;
  final List<String> axes;
  final List<String> sources;
  final bool hidden;
  final bool disagreed;
  final bool reported;
  final String? userNote;

  ClueInsight copyWith({
    bool? hidden,
    bool? disagreed,
    bool? reported,
    String? userNote,
  }) {
    return ClueInsight(
      id: id,
      title: title,
      body: body,
      sourceCount: sourceCount,
      diaryCount: diaryCount,
      questionCount: questionCount,
      axes: axes,
      sources: sources,
      hidden: hidden ?? this.hidden,
      disagreed: disagreed ?? this.disagreed,
      reported: reported ?? this.reported,
      userNote: userNote ?? this.userNote,
    );
  }
}

abstract class FiYouRepository extends ChangeNotifier {
  UserProfile? get profile;
  List<DiaryEntry> get diaryEntries;
  List<AxisSummary> get axes;
  ClueInsight get todayInsight;
  bool get hasLowUMapData;
  bool get storeBillingConnected;

  Future<LaunchSnapshot> restoreLaunchState();
  Future<void> signIn();
  Future<void> completeOnboarding({required String name});
  Future<void> signOut();
  Future<DiaryEntry> saveDiary({
    required String title,
    required String body,
    String? people,
  });
  Future<DiaryEntry> updateDiary(DiaryEntry entry);
  Future<void> deleteDiary(String id);
  Future<ClueInsight> saveQuestionAnswers(List<String> answers);
  Future<void> updateInsightNote(String note);
  Future<void> hideInsight();
  Future<void> disagreeInsight();
  Future<void> reportInsight(String reason);
}

class MockFiYouRepository extends FiYouRepository {
  static const _signedInKey = 'fi_you.dev.signed_in';
  static const _onboardingCompleteKey = 'fi_you.dev.onboarding_complete';
  static const _nameKey = 'fi_you.dev.name';
  static const _emailKey = 'fi_you.dev.email';
  static const _starBalanceKey = 'fi_you.dev.star_balance';
  static const _levelKey = 'fi_you.dev.level';

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
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final prefs = await SharedPreferences.getInstance();
    final signedIn = prefs.getBool(_signedInKey) ?? true;
    if (!signedIn) {
      return const LaunchSnapshot(status: LaunchStatus.signedOut);
    }
    _profile = UserProfile(
      name: prefs.getString(_nameKey) ?? 'User',
      email: prefs.getString(_emailKey) ?? 'user@fi-you.local',
      onboardingComplete: prefs.getBool(_onboardingCompleteKey) ?? true,
      starBalance: prefs.getInt(_starBalanceKey) ?? 150,
      level: prefs.getInt(_levelKey) ?? 2,
      profileLine: '관찰과 탐구를 좋아하는',
    );
    notifyListeners();
    return LaunchSnapshot(
      status: _profile!.onboardingComplete
          ? LaunchStatus.ready
          : LaunchStatus.onboardingRequired,
    );
  }

  @override
  Future<void> signIn() async {
    _profile = const UserProfile(
      name: 'User',
      email: 'user@fi-you.local',
      onboardingComplete: false,
      starBalance: 150,
      level: 2,
      profileLine: '관찰과 탐구를 좋아하는',
    );
    await _persistProfile();
    notifyListeners();
  }

  @override
  Future<void> completeOnboarding({required String name}) async {
    _profile =
        (_profile ??
                const UserProfile(
                  name: 'User',
                  email: 'user@fi-you.local',
                  onboardingComplete: false,
                  starBalance: 150,
                  level: 2,
                  profileLine: '관찰과 탐구를 좋아하는',
                ))
            .copyWith(
      name: name.trim().isEmpty ? 'User' : name.trim(),
      onboardingComplete: true,
    );
    await _persistProfile();
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _profile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, false);
    notifyListeners();
  }

  Future<void> _persistProfile() async {
    final profile = _profile;
    if (profile == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, true);
    await prefs.setBool(_onboardingCompleteKey, profile.onboardingComplete);
    await prefs.setString(_nameKey, profile.name);
    await prefs.setString(_emailKey, profile.email);
    await prefs.setInt(_starBalanceKey, profile.starBalance);
    await prefs.setInt(_levelKey, profile.level);
  }

  @override
  Future<DiaryEntry> saveDiary({
    required String title,
    required String body,
    String? people,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
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
    notifyListeners();
    return entry;
  }

  @override
  Future<DiaryEntry> updateDiary(DiaryEntry entry) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final index = _diaryEntries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      _diaryEntries.insert(0, entry);
    } else {
      _diaryEntries[index] = entry;
    }
    notifyListeners();
    return entry;
  }

  @override
  Future<void> deleteDiary(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    _diaryEntries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  @override
  Future<ClueInsight> saveQuestionAnswers(List<String> answers) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
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
    notifyListeners();
    return _todayInsight;
  }

  @override
  Future<void> updateInsightNote(String note) async {
    _todayInsight = _todayInsight.copyWith(userNote: note.trim());
    notifyListeners();
  }

  @override
  Future<void> hideInsight() async {
    _todayInsight = _todayInsight.copyWith(hidden: true);
    notifyListeners();
  }

  @override
  Future<void> disagreeInsight() async {
    _todayInsight = _todayInsight.copyWith(disagreed: true);
    notifyListeners();
  }

  @override
  Future<void> reportInsight(String reason) async {
    _todayInsight = _todayInsight.copyWith(
      reported: true,
      userNote: reason.trim().isEmpty ? '문제 신고가 접수되었어요.' : reason.trim(),
    );
    notifyListeners();
  }
}

class FiYouRepositoryScope extends InheritedNotifier<FiYouRepository> {
  const FiYouRepositoryScope({
    required FiYouRepository repository,
    required super.child,
    super.key,
  }) : super(notifier: repository);

  static FiYouRepository of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<FiYouRepositoryScope>();
    assert(scope != null, 'FiYouRepositoryScope is missing.');
    return scope!.notifier!;
  }
}
