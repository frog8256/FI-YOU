import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/features/explore/explore_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExplorationExperienceScreen', () {
    testWidgets('Explore entry loads the first card in mock mode', (
      tester,
    ) async {
      final repository = _QaExplorationRepository(
        cards: [_scenarioCard()],
        loadDelay: const Duration(seconds: 1),
      );

      await tester.pumpWidget(_testApp(repository, const ExploreScreen()));
      expect(find.text('자유 탐험'), findsOneWidget);

      await tester.tap(find.text('자유 탐험'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('무엇을 물어볼지 고민하고 있어요...'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text(_scenarioCard().question), findsOneWidget);
    });

    testWidgets(
      'all single-select card types enable Continue after selection',
      (tester) async {
        for (final card in [_binaryCard(), _multipleCard(), _scenarioCard()]) {
          final repository = _QaExplorationRepository(cards: [card]);
          await tester.pumpWidget(_testApp(repository));
          await tester.pumpAndSettle();

          expect(find.text(card.question), findsOneWidget);
          expect(_continueButton(tester).onPressed, isNull);

          await tester.tap(find.text(card.options.first.label));
          await tester.pumpAndSettle();

          expect(_continueButton(tester).onPressed, isNotNull);

          _continueButton(tester).onPressed!();
          await tester.pumpAndSettle();

          expect(repository.submissions.single.selectedOptionIds, [
            card.options.first.id,
          ]);
          await tester.pumpWidget(const SizedBox.shrink());
        }
      },
    );

    testWidgets('priority_selection enforces the required selection count', (
      tester,
    ) async {
      final card = _priorityCard(requiredSelections: 2);
      final repository = _QaExplorationRepository(cards: [card]);
      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('Selected 0/2'), findsOneWidget);
      expect(_continueButton(tester).onPressed, isNull);

      await tester.tap(find.text(card.options[0].label));
      await tester.pumpAndSettle();
      expect(find.text('Selected 1/2'), findsOneWidget);
      expect(_continueButton(tester).onPressed, isNull);

      await tester.tap(find.text(card.options[1].label));
      await tester.pumpAndSettle();
      expect(find.text('Selected 2/2'), findsOneWidget);
      expect(_continueButton(tester).onPressed, isNotNull);

      await tester.tap(find.text(card.options[2].label));
      await tester.pumpAndSettle();
      expect(find.text('Selected 2/2'), findsOneWidget);

      _continueButton(tester).onPressed!();
      await tester.pumpAndSettle();

      expect(repository.submissions.single.selectedOptionIds, [
        card.options[0].id,
        card.options[1].id,
      ]);
    });

    testWidgets(
      'empty optional note submits and loads the next card naturally',
      (tester) async {
        final first = _binaryCard();
        final next = _multipleCard();
        final repository = _QaExplorationRepository(
          cards: [first, next],
          loadDelay: const Duration(seconds: 1),
        );

        await tester.pumpWidget(_testApp(repository));
        await tester.pumpAndSettle();

        await tester.tap(find.text(first.options.first.label));
        await tester.pumpAndSettle();
        _continueButton(tester).onPressed!();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 20));

        expect(find.text('무엇을 물어볼지 고민하고 있어요...'), findsOneWidget);

        await tester.pumpAndSettle();
        expect(repository.submissions.single.userNote, isNull);
        expect(find.text(next.question), findsOneWidget);
      },
    );

    testWidgets('optional note is limited to 300 characters', (tester) async {
      final card = _scenarioCard();
      final repository = _QaExplorationRepository(cards: [card]);
      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('생각 남기기'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '가' * 350);
      await tester.tap(find.text(card.options.first.label));
      await tester.pumpAndSettle();
      _continueButton(tester).onPressed!();
      await tester.pumpAndSettle();

      expect(repository.submissions.single.userNote?.length, 300);
    });

    testWidgets('load failure shows retry UI and retry recovers', (
      tester,
    ) async {
      final repository = _QaExplorationRepository(
        cards: [_binaryCard()],
        failLoads: 1,
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('질문을 불러오지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);

      await tester.tap(find.text('다시 시도'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text(_binaryCard().question), findsOneWidget);
    });

    testWidgets('submit failure keeps the answer and allows retry', (
      tester,
    ) async {
      final card = _binaryCard();
      final repository = _QaExplorationRepository(
        cards: [card],
        failSubmits: 1,
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();
      await tester.tap(find.text(card.options.first.label));
      await tester.pumpAndSettle();

      _continueButton(tester).onPressed!();
      await tester.pumpAndSettle();

      expect(find.text('응답을 기록하지 못했어요. 선택은 그대로 남겨둘게요.'), findsOneWidget);
      expect(_continueButton(tester).onPressed, isNotNull);

      _continueButton(tester).onPressed!();
      await tester.pumpAndSettle();

      expect(repository.submissions.length, 1);
    });

    testWidgets(
      'node names, categories, and analysis metadata are not exposed',
      (tester) async {
        final repository = _QaExplorationRepository(cards: [_scenarioCard()]);
        await tester.pumpWidget(_testApp(repository));
        await tester.pumpAndSettle();

        for (final forbidden in [
          'parent_node',
          'child_node',
          'depth',
          'score',
          '자아상',
          '성격',
          '관계',
          '분석',
          'U-Map',
        ]) {
          expect(find.textContaining(forbidden), findsNothing);
        }
      },
    );
  });
}

Widget _testApp(
  FiYouRepository repository, [
  Widget child = const ExplorationExperienceScreen(),
]) {
  return FiYouRepositoryScope(
    repository: repository,
    child: MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: FiYouGlass.background),
          child,
        ],
      ),
    ),
  );
}

FiYouLiquidButton _continueButton(WidgetTester tester) {
  return tester.widget<FiYouLiquidButton>(
    find.widgetWithText(FiYouLiquidButton, '계속'),
  );
}

class _QaExplorationRepository extends MockFiYouRepository {
  _QaExplorationRepository({
    required this.cards,
    this.failLoads = 0,
    this.failSubmits = 0,
    this.loadDelay = const Duration(milliseconds: 1),
  });

  final List<ExplorationCard> cards;
  final List<ExplorationAnswerInput> submissions = [];
  final Duration loadDelay;
  int failLoads;
  int failSubmits;
  int _loadIndex = 0;

  @override
  Future<ExplorationCard> loadNextExplorationCard() async {
    await Future<void>.delayed(loadDelay);
    if (failLoads > 0) {
      failLoads -= 1;
      throw StateError('forced load failure');
    }
    final card = cards[_loadIndex.clamp(0, cards.length - 1)];
    _loadIndex += 1;
    return card;
  }

  @override
  Future<void> submitExplorationAnswer(ExplorationAnswerInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (failSubmits > 0) {
      failSubmits -= 1;
      throw StateError('forced submit failure');
    }
    submissions.add(input);
  }
}

ExplorationCard _binaryCard() {
  return const ExplorationCard(
    id: 'qa-binary',
    type: ExplorationCardType.binaryChoice,
    question: '요즘 나는 멈춤보다 움직임에 더 가까운가요?',
    options: [
      ExplorationCardOption(id: 'yes', label: '네, 움직이고 싶어요'),
      ExplorationCardOption(id: 'no', label: '아니요, 멈추고 싶어요'),
    ],
  );
}

ExplorationCard _multipleCard() {
  return const ExplorationCard(
    id: 'qa-multiple',
    type: ExplorationCardType.multipleChoice,
    question: '오늘 가장 먼저 살펴보고 싶은 방향은 무엇인가요?',
    options: [
      ExplorationCardOption(id: 'choice', label: '선택의 기준'),
      ExplorationCardOption(id: 'emotion', label: '반복되는 감정'),
      ExplorationCardOption(id: 'action', label: '행동으로 옮기는 힘'),
    ],
  );
}

ExplorationCard _priorityCard({required int requiredSelections}) {
  return ExplorationCard(
    id: 'qa-priority',
    type: ExplorationCardType.prioritySelection,
    question: '지금 더 살펴보고 싶은 흐름을 골라본다면요?',
    requiredSelections: requiredSelections,
    options: const [
      ExplorationCardOption(id: 'choice', label: '선택의 기준'),
      ExplorationCardOption(id: 'emotion', label: '반복되는 감정'),
      ExplorationCardOption(id: 'relation', label: '관계 안의 거리감'),
      ExplorationCardOption(id: 'action', label: '행동으로 옮기는 힘'),
    ],
  );
}

ExplorationCard _scenarioCard() {
  return const ExplorationCard(
    id: 'qa-scenario',
    type: ExplorationCardType.scenarioChoice,
    question: '요즘 마음이 자연스럽게 향하는 장면은 어디에 가까운가요?',
    options: [
      ExplorationCardOption(id: 'alone', label: '혼자 조용히 정리하는 시간'),
      ExplorationCardOption(id: 'people', label: '사람들과 나누며 선명해지는 시간'),
      ExplorationCardOption(id: 'new', label: '새로운 것을 시도해보는 장면'),
    ],
  );
}
