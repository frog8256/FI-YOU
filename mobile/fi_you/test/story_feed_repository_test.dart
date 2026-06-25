import 'package:fi_you/data/fi_you_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Story feed repository contract', () {
    test('mock story feed returns reflective stories', () async {
      final repository = MockFiYouRepository();

      final feed = await repository.getStoryFeed();

      expect(feed.hasError, isFalse);
      expect(feed.feedTitle, '나의 이야기');
      expect(feed.stories, isNotEmpty);
      expect(
        feed.stories.first.supportingInsights.length,
        greaterThanOrEqualTo(3),
      );
    });

    test('empty story feed parses safely', () {
      final feed = StoryFeedResponse.fromJson({
        'feed_title': '나의 이야기',
        'stories': <Object?>[],
      });

      expect(feed.hasError, isFalse);
      expect(feed.isEmpty, isTrue);
      expect(feed.feedTitle, '나의 이야기');
    });

    test('malformed story feed does not throw', () {
      final feed = StoryFeedResponse.fromJson('not-a-map');

      expect(feed.hasError, isTrue);
      expect(feed.isEmpty, isTrue);
    });

    test('unknown story type is preserved safely', () {
      final feed = StoryFeedResponse.fromJson({
        'stories': [
          {
            'story_id': 'story-1',
            'story_type': 'unexpected_story_type',
            'title': '이야기가 이어지고 있어요',
            'description': '조용한 이야기는 계속 보여줄 수 있습니다.',
            'supporting_insights': [
              {
                'insight_id': 'insight-1',
                'insight_type': 'consistent_theme',
                'title': '이어지는 작은 흐름',
              },
            ],
          },
        ],
      });

      expect(feed.stories.single.type, 'unexpected_story_type');
      expect(feed.stories.single.title, '이야기가 이어지고 있어요');
    });

    test('supporting insights parse while raw ids stay separate', () {
      final story = UserStory.fromJson({
        'story_id': 'story-1',
        'story_type': 'current_chapter',
        'title': 'Current Chapter',
        'description': '최근 탐험이 몇 가지 흐름을 모읍니다.',
        'supporting_insights': [
          {
            'insight_id': 'insight-raw-id',
            'insight_type': 'emerging_pattern',
            'title': '보이는 작은 흐름',
          },
        ],
      });

      expect(story.supportingInsights.single.insightId, 'insight-raw-id');
      expect(story.supportingInsights.single.title, '보이는 작은 흐름');
    });

    test('mock story copy avoids forbidden analysis language', () async {
      final feed = await MockFiYouRepository().getStoryFeed();
      final copy = feed.stories
          .map((story) => '${story.title} ${story.description}')
          .join(' ')
          .toLowerCase();
      const forbidden = [
        'score',
        'diagnosis',
        'personality type',
        'analysis result',
        'assessment',
        'profile',
        'ranking',
        'you are',
        'highly',
      ];

      for (final word in forbidden) {
        expect(copy.contains(word), isFalse, reason: 'Forbidden copy: $word');
      }
    });
  });
}
