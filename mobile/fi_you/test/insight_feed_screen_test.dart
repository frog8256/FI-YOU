import 'dart:async';

import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/features/explore/insight_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('InsightFeedScreen shows loading state', (tester) async {
    final completer = Completer<InsightFeedResponse>();
    final repository = _InsightFeedRepository(loader: () => completer.future);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    expect(find.text('탐험의 흐름을 정리하고 있어요...'), findsOneWidget);

    completer.complete(InsightFeedResponse.empty());
    await tester.pumpAndSettle();
  });

  testWidgets('InsightFeedScreen shows empty state', (tester) async {
    await tester.pumpWidget(
      _testApp(_InsightFeedRepository(loader: InsightFeedResponse.empty)),
    );
    await tester.pumpAndSettle();

    expect(find.text('조금 더 탐험하면 흐름이 보이기 시작할 거예요.'), findsOneWidget);
  });

  testWidgets('InsightFeedScreen renders insight cards', (tester) async {
    await tester.pumpWidget(
      _testApp(_InsightFeedRepository(loader: _successFeed)),
    );
    await tester.pumpAndSettle();

    expect(find.text('반복해서 나타나는 방향'), findsOneWidget);
    expect(find.text('스스로 고르는 방향'), findsOneWidget);
    expect(find.text('parent_01_child_01'), findsNothing);
    expect(find.text('forming'), findsNothing);
  });

  testWidgets('InsightFeedScreen shows retry state and recovers', (
    tester,
  ) async {
    var calls = 0;
    final repository = _InsightFeedRepository(
      loader: () {
        calls += 1;
        if (calls == 1) {
          return InsightFeedResponse.empty(errorMessage: 'network');
        }
        return _successFeed();
      },
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('잠시 흐름을 불러오지 못했어요.'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('반복해서 나타나는 방향'), findsOneWidget);
  });

  testWidgets('InsightFeedScreen avoids forbidden visible copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(_InsightFeedRepository(loader: _successFeed)),
    );
    await tester.pumpAndSettle();

    for (final forbidden in [
      'score',
      'diagnosis',
      'personality type',
      'analysis result',
      'parent_',
    ]) {
      expect(find.textContaining(forbidden), findsNothing);
    }
  });
}

Widget _testApp(FiYouRepository repository) {
  return FiYouRepositoryScope(
    repository: repository,
    child: const MaterialApp(home: InsightFeedScreen()),
  );
}

InsightFeedResponse _successFeed() {
  return const InsightFeedResponse(
    feedTitle: '최근 탐험',
    insights: [
      UserInsight(
        id: 'insight-1',
        type: 'emerging_pattern',
        title: '반복해서 나타나는 방향',
        description: '최근 탐험에서는 하나의 방향이 여러 순간에 걸쳐 보입니다.',
        confidenceLevel: 'forming',
        supportingNodes: [
          InsightSupportingNode(
            nodeId: 'parent_01_child_01',
            nodeName: '스스로 고르는 방향',
            parentNode: '탐험',
          ),
        ],
      ),
    ],
  );
}

class _InsightFeedRepository extends MockFiYouRepository {
  _InsightFeedRepository({required this.loader});

  final FutureOr<InsightFeedResponse> Function() loader;

  @override
  Future<InsightFeedResponse> getInsightFeed() async => loader();
}
