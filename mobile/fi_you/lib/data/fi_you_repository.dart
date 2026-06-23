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

class OnboardingQuestionOption {
  const OnboardingQuestionOption({
    required this.id,
    required this.label,
    required this.sequence,
  });

  final String id;
  final String label;
  final int sequence;
}

class OnboardingQuestion {
  const OnboardingQuestion({
    required this.id,
    required this.questionSet,
    required this.sequence,
    required this.prompt,
    required this.options,
    this.helperText,
    this.axisKeys = const [],
  });

  final String id;
  final String questionSet;
  final int sequence;
  final String prompt;
  final String? helperText;
  final List<String> axisKeys;
  final List<OnboardingQuestionOption> options;
}

class QuestionAnswerInput {
  const QuestionAnswerInput({
    required this.questionSet,
    required this.questionId,
    this.selectedOptionId,
    this.optionalText,
    this.skipped = false,
  });

  final String questionSet;
  final String questionId;
  final String? selectedOptionId;
  final String? optionalText;
  final bool skipped;
}

enum ExplorationCardType {
  binaryChoice,
  multipleChoice,
  prioritySelection,
  scenarioChoice,
}

class ExplorationCardOption {
  const ExplorationCardOption({required this.id, required this.label});

  final String id;
  final String label;
}

class ExplorationCard {
  const ExplorationCard({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    this.requiredSelections = 1,
  });

  final String id;
  final ExplorationCardType type;
  final String question;
  final List<ExplorationCardOption> options;
  final int requiredSelections;

  bool get allowsMultipleSelection =>
      type == ExplorationCardType.prioritySelection;
}

class ExplorationAnswerInput {
  const ExplorationAnswerInput({
    required this.cardId,
    required this.selectedOptionIds,
    this.userNote,
  });

  final String cardId;
  final List<String> selectedOptionIds;
  final String? userNote;
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
  Future<UserProfile> saveProfileBasics({
    required String name,
    DateTime? birthday,
  });
  Future<List<OnboardingQuestion>> loadOnboardingQuestions({
    String questionSet = 'onboarding_required',
  });
  Future<void> saveOnboardingAnswer(QuestionAnswerInput input);
  Future<ExplorationCard> loadNextExplorationCard();
  Future<void> submitExplorationAnswer(ExplorationAnswerInput input);
  Future<void> completeOnboarding({
    required String name,
    DateTime? birthday,
    String? focusArea,
  });
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
    title: '?ㅻ뒛 諛쒓껄???⑥꽌',
    body:
        '?쇱옄 ?앷컖???뺣━?섎뒗 ?쒓컙???뚮났???꾩????섎뒗 ?먮쫫?쇰줈 蹂댁뿬?? ?꾩쭅 ?뺤젙???댁꽍? ?꾨땲?먯슂.',
    sourceCount: 12,
    diaryCount: 2,
    questionCount: 3,
    axes: ['愿怨??먮쫫', '媛먯젙 ?몄떇'],
    sources: ['6??18??Diary', '?ㅻ뒛 吏덈Ц ?묐떟', '理쒓렐 媛먯젙 湲곕줉'],
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
      profileLine: '愿李곌낵 ?먭뎄瑜?醫뗭븘?섎뒗',
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
      profileLine: '愿李곌낵 ?먭뎄瑜?醫뗭븘?섎뒗',
    );
    await _persistProfile();
    notifyListeners();
  }

  @override
  Future<void> completeOnboarding({
    required String name,
    DateTime? birthday,
    String? focusArea,
  }) async {
    await saveProfileBasics(name: name);
    _profile = _profile!.copyWith(onboardingComplete: true);
    await _persistProfile();
    notifyListeners();
  }

  @override
  Future<UserProfile> saveProfileBasics({
    required String name,
    DateTime? birthday,
  }) async {
    _profile =
        (_profile ??
                const UserProfile(
                  name: 'User',
                  email: 'user@fi-you.local',
                  onboardingComplete: false,
                  starBalance: 150,
                  level: 2,
                  profileLine: '愿李곌낵 ?먭뎄瑜?醫뗭븘?섎뒗',
                ))
            .copyWith(name: name.trim().isEmpty ? 'User' : name.trim());
    await _persistProfile();
    notifyListeners();
    return _profile!;
  }

  @override
  Future<List<OnboardingQuestion>> loadOnboardingQuestions({
    String questionSet = 'onboarding_required',
  }) async {
    return [
      for (var index = 0; index < questionFlowSteps.length; index++)
        OnboardingQuestion(
          id: 'mock-question-$index',
          questionSet: questionSet,
          sequence: index + 1,
          prompt: questionFlowSteps[index].title,
          helperText: questionFlowSteps[index].description,
          options: [
            for (
              var optionIndex = 0;
              optionIndex < questionFlowSteps[index].options.length;
              optionIndex++
            )
              OnboardingQuestionOption(
                id: 'mock-question-$index-option-$optionIndex',
                label: questionFlowSteps[index].options[optionIndex],
                sequence: optionIndex + 1,
              ),
          ],
        ),
    ];
  }

  @override
  Future<void> saveOnboardingAnswer(QuestionAnswerInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  int _mockExplorationIndex = 0;

  @override
  Future<ExplorationCard> loadNextExplorationCard() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final cards = [
      const ExplorationCard(
        id: 'mock-exploration-1',
        type: ExplorationCardType.scenarioChoice,
        question: '요즘 마음이 자연스럽게 향하는 장면은 어디에 가까운가요?',
        options: [
          ExplorationCardOption(id: 'scene-alone', label: '혼자 조용히 정리하는 시간'),
          ExplorationCardOption(id: 'scene-people', label: '사람들과 나누며 선명해지는 시간'),
          ExplorationCardOption(id: 'scene-new', label: '새로운 것을 시도해보는 장면'),
          ExplorationCardOption(id: 'scene-steady', label: '익숙한 리듬을 지키는 하루'),
        ],
      ),
      const ExplorationCard(
        id: 'mock-exploration-2',
        type: ExplorationCardType.prioritySelection,
        question: '지금 더 살펴보고 싶은 흐름을 두 가지 골라본다면요?',
        requiredSelections: 2,
        options: [
          ExplorationCardOption(id: 'flow-choice', label: '내 선택의 기준'),
          ExplorationCardOption(id: 'flow-feeling', label: '반복되는 감정'),
          ExplorationCardOption(id: 'flow-relation', label: '관계 안의 거리감'),
          ExplorationCardOption(id: 'flow-action', label: '행동으로 옮기는 힘'),
        ],
      ),
      const ExplorationCard(
        id: 'mock-exploration-3',
        type: ExplorationCardType.binaryChoice,
        question: '요즘 나는 변화보다 안정 쪽에 조금 더 가까운가요?',
        options: [
          ExplorationCardOption(id: 'yes', label: '네, 안정에 더 끌려요'),
          ExplorationCardOption(id: 'no', label: '아니요, 변화가 더 가까워요'),
        ],
      ),
    ];
    final card = cards[_mockExplorationIndex % cards.length];
    _mockExplorationIndex += 1;
    return card;
  }

  @override
  Future<void> submitExplorationAnswer(ExplorationAnswerInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    _todayInsight = _todayInsight.copyWith(
      userNote: '방금 남긴 탐험 응답을 U-Map 단서에 더해두었어요.',
    );
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
      userNote: '최근 Diary 기록을 U-Map 단서에 반영할 준비가 되었어요.',
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
      body: '갈등 장면에서 감정을 먼저 정리하려는 흐름을 기록했어요.',
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
      userNote: reason.trim().isEmpty ? '臾몄젣 ?좉퀬媛 ?묒닔?섏뿀?댁슂.' : reason.trim(),
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
    final scope = context
        .dependOnInheritedWidgetOfExactType<FiYouRepositoryScope>();
    assert(scope != null, 'FiYouRepositoryScope is missing.');
    return scope!.notifier!;
  }
}
