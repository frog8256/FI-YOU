import 'dart:async';

import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/features/explore/explore_screen.dart';
import 'package:fi_you/features/explore/story_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StoryFeedScreen shows loading state', (tester) async {
    final completer = Completer<StoryFeedResponse>();
    final repository = _StoryFeedRepository(loader: () => completer.future);

    await tester.pumpWidget(_testApp(repository));
    await tester.pump();

    expect(find.text('탐험의 조각을 이야기로 엮고 있어요...'), findsOneWidget);

    completer.complete(StoryFeedResponse.empty());
    await tester.pumpAndSettle();
  });

  testWidgets('StoryFeedScreen shows empty state', (tester) async {
    await tester.pumpWidget(
      _testApp(_StoryFeedRepository(loader: StoryFeedResponse.empty)),
    );
    await tester.pumpAndSettle();

    expect(find.text('조금 더 탐험하면 이야기가 모습을 갖출 거예요.'), findsOneWidget);
  });

  testWidgets('StoryFeedScreen renders story cards', (tester) async {
    await tester.pumpWidget(
      _testApp(_StoryFeedRepository(loader: _successFeed)),
    );
    await tester.pumpAndSettle();

    expect(find.text('모습을 갖추는 장'), findsOneWidget);
    expect(find.text('현재의 장'), findsWidgets);
    expect(find.text('이어지는 작은 흐름'), findsOneWidget);
    expect(find.text('story-raw-id'), findsNothing);
    expect(find.text('insight-raw-id'), findsNothing);
    expect(find.text('current_chapter'), findsNothing);
  });

  testWidgets('StoryFeedScreen shows retry state and recovers', (tester) async {
    var calls = 0;
    final repository = _StoryFeedRepository(
      loader: () {
        calls += 1;
        if (calls == 1) {
          return StoryFeedResponse.empty(errorMessage: 'network');
        }
        return _successFeed();
      },
    );

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('잠시 이야기를 불러오지 못했어요.'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('모습을 갖추는 장'), findsOneWidget);
  });

  testWidgets('StoryFeedScreen renders unknown story type safely', (tester) async {
    await tester.pumpWidget(
      _testApp(_StoryFeedRepository(loader: _unknownTypeFeed)),
    );
    await tester.pumpAndSettle();

    expect(find.text('이어지는 이야기'), findsOneWidget);
    expect(find.text('이야기가 이어지고 있어요'), findsOneWidget);
    expect(find.text('unexpected_story_type'), findsNothing);
  });

  testWidgets('StoryFeedScreen avoids forbidden visible copy', (tester) async {
    await tester.pumpWidget(
      _testApp(_StoryFeedRepository(loader: _successFeed)),
    );
    await tester.pumpAndSettle();

    for (final forbidden in [
      'score',
      'diagnosis',
      'personality type',
      'analysis result',
      'assessment',
      'profile',
      'parent_',
      'story-raw-id',
      'insight-raw-id',
    ]) {
      expect(find.textContaining(forbidden), findsNothing);
    }
  });

  testWidgets('Explore screen exposes Story Feed entry point', (tester) async {
    await tester.pumpWidget(
      FiYouRepositoryScope(
        repository: MockFiYouRepository(),
        child: const MaterialApp(home: ExploreScreen()),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('나의 이야기'), findsOneWidget);
    expect(find.text('탐험에서 이어지는 조용한 장을 읽어보세요.'), findsOneWidget);
  });
}

Widget _testApp(FiYouRepository repository) {
  return FiYouRepositoryScope(
    repository: repository,
    child: const MaterialApp(home: StoryFeedScreen()),
  );
}

StoryFeedResponse _successFeed() {
  return const StoryFeedResponse(
    feedTitle: '나의 이야기',
    stories: [
      UserStory(
        id: 'story-raw-id',
        type: 'current_chapter',
        title: '모습을 갖추는 장',
        description:
            '최근 탐험이 여러 흐름을 조용한 장으로 모으고 있어요.',
        supportingInsights: [
          StorySupportingInsight(
            insightId: 'insight-raw-id',
            insightType: 'consistent_theme',
            title: '이어지는 작은 흐름',
          ),
        ],
      ),
    ],
  );
}

StoryFeedResponse _unknownTypeFeed() {
  return const StoryFeedResponse(
    feedTitle: '나의 이야기',
    stories: [
      UserStory(
        id: 'story-2',
        type: 'unexpected_story_type',
        title: '이야기가 이어지고 있어요',
        description: '조용한 이야기는 계속 보여줄 수 있습니다.',
        supportingInsights: [
          StorySupportingInsight(
            insightId: 'insight-2',
            insightType: 'unknown',
            title: '조용한 흐름',
          ),
        ],
      ),
    ],
  );
}

class _StoryFeedRepository extends MockFiYouRepository {
  _StoryFeedRepository({required this.loader});

  final FutureOr<StoryFeedResponse> Function() loader;

  @override
  Future<StoryFeedResponse> getStoryFeed() async => loader();
}
