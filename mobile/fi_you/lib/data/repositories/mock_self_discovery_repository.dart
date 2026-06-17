import 'dart:async';
import 'dart:math';

import '../models/fiyou_models.dart';
import 'self_discovery_repository.dart';

class MockSelfDiscoveryRepository implements SelfDiscoveryRepository {
  FiyouProfile _profile = const FiyouProfile(
    id: 'local-user',
    displayName: '테스터',
    onboardingCompleted: false,
  );
  bool _signedIn = false;
  final List<AnswerDraft> _answers = [];
  final List<RelationItem> _relations = [];
  final List<DiaryEntry> _diaries = [
    DiaryEntry(
      id: 'diary-1',
      entryDate: DateTime.now().subtract(const Duration(days: 1)),
      title: '어제의 작은 발견',
      body: '혼자 정리할 시간이 있을 때 생각이 더 또렷해졌다.',
      moodScore: 7,
      tags: const ['정리', '휴식'],
    ),
  ];

  final List<Question> _questions = const [
    Question(
      id: 'q-energy-1',
      prompt: '요즘 나를 가장 많이 움직이게 하는 것은 무엇인가요?',
      category: 'energyRhythm',
      type: 'single_choice',
      subtitle: '가장 가까운 답을 골라주세요.',
      whyThisQuestion: '에너지 흐름을 더 선명하게 보기 위한 질문이에요.',
      choices: [
        QuestionChoice(id: 'curiosity', label: '궁금한 것을 파고들 때'),
        QuestionChoice(id: 'people', label: '사람들과 연결될 때'),
        QuestionChoice(id: 'finish', label: '하나를 끝냈을 때'),
        QuestionChoice(id: 'quiet', label: '혼자 조용히 정리할 때'),
      ],
    ),
    Question(
      id: 'q-values-1',
      prompt: '선택 앞에서 가장 놓치고 싶지 않은 기준은 무엇인가요?',
      category: 'valuesCompass',
      type: 'single_choice',
      subtitle: '정답보다 현재에 가까운 답이면 충분해요.',
      choices: [
        QuestionChoice(id: 'freedom', label: '내가 선택했다는 감각'),
        QuestionChoice(id: 'care', label: '중요한 사람을 지키는 일'),
        QuestionChoice(id: 'growth', label: '배우고 커지는 방향'),
        QuestionChoice(id: 'stability', label: '흔들리지 않는 안정감'),
      ],
    ),
  ];

  @override
  Future<FiyouProfile?> getCurrentProfile() async => _signedIn ? _profile : null;

  @override
  Future<FiyouProfile> signInWithEmail(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _profile = FiyouProfile(
      id: 'local-user',
      displayName: email.split('@').first,
      onboardingCompleted: false,
    );
    _signedIn = true;
    return _profile;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _signedIn = false;
  }

  @override
  Future<FiyouProfile> completeOnboarding({
    required String displayName,
    required String timezone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _profile = FiyouProfile(
      id: _profile.id,
      displayName: displayName,
      timezone: timezone,
      onboardingCompleted: true,
    );
    return _profile;
  }

  @override
  Future<TodaySummary> getTodaySummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return TodaySummary(
      question: await getNextQuestion(),
      diaries: await getDiaries(),
      uMap: await getUMap(),
      signature: await getSignature(),
      starBalance: await getStarBalance(),
      entitlements: await getEntitlements(),
      relations: await getRelations(),
      reports: await getReports(),
    );
  }

  @override
  Future<Question> getNextQuestion() async {
    final answered = _answers.map((answer) => answer.questionId).toSet();
    return _questions.firstWhere(
      (question) => !answered.contains(question.id),
      orElse: () => _questions[_answers.length % _questions.length],
    );
  }

  @override
  Future<void> submitAnswer(AnswerDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _answers.removeWhere((answer) => answer.questionId == draft.questionId);
    _answers.add(draft);
  }

  @override
  Future<List<DiaryEntry>> getDiaries() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<DiaryEntry>.from(_diaries)
      ..sort((a, b) => b.entryDate.compareTo(a.entryDate));
  }

  @override
  Future<DiaryEntry?> getDiary(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    for (final entry in _diaries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  @override
  Future<DiaryEntry> saveDiary(DiaryEntry entry) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final saved = entry.id == 'new'
        ? entry.copyWith(id: 'diary-${Random().nextInt(999999)}')
        : entry;
    _diaries.removeWhere((item) => item.id == saved.id);
    _diaries.add(saved);
    return saved;
  }

  @override
  Future<void> deleteDiary(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _diaries.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<UMapSnapshot> getUMap() async {
    final answerBoost = min(_answers.length * 8, 24).toDouble();
    return UMapSnapshot(
      overallClarity: 42 + answerBoost,
      clearAreas: const ['에너지 리듬', '가치 기준'],
      unclearAreas: const ['관계 패턴', '회복 방식'],
      nextQuestionFocus: const ['선택 기준', '스트레스 회복'],
      axes: [
        UMapAxis(
          code: 'energyRhythm',
          label: '에너지 리듬',
          summary: '혼자 정리하는 시간이 흐름을 되살리는 쪽으로 보여요.',
          score: 64 + answerBoost,
          clarity: 58 + answerBoost,
          flow: 'forming',
          signals: const ['정리', '몰입', '휴식'],
        ),
        const UMapAxis(
          code: 'valuesCompass',
          label: '가치 기준',
          summary: '스스로 선택했다는 감각을 중요하게 두고 있어요.',
          score: 68,
          clarity: 62,
          flow: 'forming',
          signals: ['자율', '성장'],
        ),
        const UMapAxis(
          code: 'relationshipPattern',
          label: '관계 패턴',
          summary: '관계 속 경계와 연결 방식을 더 살펴볼 차례예요.',
          score: 44,
          clarity: 36,
          flow: 'emerging',
          signals: ['거리', '기대'],
        ),
        const UMapAxis(
          code: 'stressRecovery',
          label: '회복 방식',
          summary: '회복 신호는 아직 조금 더 기록이 필요해요.',
          score: 38,
          clarity: 32,
          flow: 'emerging',
          signals: ['거리두기'],
        ),
      ],
    );
  }

  @override
  Future<SignatureFlow> getSignature() async {
    return const SignatureFlow(
      label: '조용히 방향을 맞추는 흐름',
      summary: '현재 기록에서는 혼자 생각을 정리한 뒤 움직일 때 더 안정적인 흐름이 보여요.',
      confidenceNote: '고정된 유형이 아니에요. 기록이 쌓이면 표현도 달라질 수 있어요.',
      evidence: ['정리할 시간이 필요하다는 기록', '선택의 이유를 찾는 답변'],
    );
  }

  @override
  Future<StarBalance> getStarBalance() async => const StarBalance(balance: 120);

  @override
  Future<List<Entitlement>> getEntitlements() async => const [
        Entitlement(id: 'entitlement-1', productId: 'fiyou_report_umap_deep_1', status: 'active'),
      ];

  @override
  Future<List<StoreProduct>> getStoreProducts() async => const [
        StoreProduct(
          id: 'fiyou_star_100',
          title: 'Star 100',
          description: '확장된 탐험 보기에 사용할 수 있어요.',
          priceLabel: 'Google Play',
          kind: 'consumable',
          starAmount: 100,
        ),
        StoreProduct(
          id: 'fiyou_star_300',
          title: 'Star 330',
          description: '기록을 더 깊게 정리할 때 사용할 수 있어요.',
          priceLabel: 'Google Play',
          kind: 'consumable',
          starAmount: 330,
        ),
        StoreProduct(
          id: 'fiyou_star_700',
          title: 'Star 800',
          description: '여러 확장 보기를 이어서 살펴볼 수 있어요.',
          priceLabel: 'Google Play',
          kind: 'consumable',
          starAmount: 800,
        ),
        StoreProduct(
          id: 'fiyou_star_1500',
          title: 'Star 1800',
          description: '긴 흐름의 탐험을 위한 Star 묶음이에요.',
          priceLabel: 'Google Play',
          kind: 'consumable',
          starAmount: 1800,
        ),
        StoreProduct(
          id: 'fiyou_report_umap_deep_1',
          title: 'U-Map 확장 리포트',
          description: '기존 기록을 바탕으로 U-Map 흐름을 더 넓게 정리해요.',
          priceLabel: 'Google Play',
          kind: 'consumable',
        ),
        StoreProduct(
          id: 'fiyou_report_signature_deep_1',
          title: 'Signature 확장 리포트',
          description: '현재 흐름을 더 긴 문맥으로 정리해요.',
          priceLabel: 'Google Play',
          kind: 'consumable',
        ),
        StoreProduct(
          id: 'fiyou_report_relation_1',
          title: '관계 흐름 리포트',
          description: '내 기록에서 보이는 관계 흐름을 정리해요.',
          priceLabel: 'Google Play',
          kind: 'consumable',
        ),
        StoreProduct(
          id: 'fiyou_report_past_self_1',
          title: '지난 나와 비교',
          description: '이전 기록과 현재 흐름을 나란히 살펴봐요.',
          priceLabel: 'Google Play',
          kind: 'consumable',
        ),
        StoreProduct(
          id: 'fiyou_plus',
          title: 'FI-YOU Plus',
          description: '월간 Star와 확장 보기를 묶어서 사용할 수 있어요.',
          priceLabel: 'Google Play',
          kind: 'subscription',
        ),
      ];

  @override
  Future<void> submitPurchaseToken({
    required String productId,
    required String purchaseToken,
    required String source,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<List<RelationItem>> getRelations() async => List<RelationItem>.from(_relations);

  @override
  Future<RelationItem> createRelation({
    required String label,
    String? note,
  }) async {
    final relation = RelationItem(
      id: 'relation-${Random().nextInt(999999)}',
      label: label,
      status: 'draft',
      note: note,
    );
    _relations.add(relation);
    return relation;
  }

  @override
  Future<List<PaidReport>> getReports() async => const [
        PaidReport(
          id: 'report-1',
          title: '현재 흐름 리포트',
          status: 'ready',
          summary: '기록에서 반복되는 흐름을 더 자세히 볼 수 있어요.',
          requiredProductId: 'fiyou_report_umap_deep_1',
        ),
      ];

  @override
  Future<void> requestAccountDeletion({String? reason}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
