import 'package:fi_you/data/fi_you_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Insight feed repository contract', () {
    test('mock insight feed returns discovery-oriented insights', () async {
      final repository = MockFiYouRepository();

      final feed = await repository.getInsightFeed();

      expect(feed.hasError, isFalse);
      expect(feed.insights, isNotEmpty);
      expect(feed.feedTitle, '최근 탐험');
      expect(feed.insights.first.supportingNodes, isNotEmpty);
    });

    test('empty insight feed parses safely', () {
      final feed = InsightFeedResponse.fromJson({
        'feed_title': '최근 탐험',
        'insights': <Object?>[],
      });

      expect(feed.hasError, isFalse);
      expect(feed.isEmpty, isTrue);
      expect(feed.feedTitle, '최근 탐험');
    });

    test('malformed insight feed does not throw', () {
      final feed = InsightFeedResponse.fromJson('not-a-map');

      expect(feed.hasError, isTrue);
      expect(feed.isEmpty, isTrue);
    });

    test('supporting nodes parse without exposing raw ids as labels', () {
      final feed = InsightFeedResponse.fromJson({
        'insights': [
          {
            'insight_id': 'insight-1',
            'insight_type': 'emerging_pattern',
            'title': '작은 흐름이 나타나고 있어요',
            'description': '반복되는 방향이 최근 카드 사이에서 보입니다.',
            'confidence_level': 'forming',
            'supporting_nodes': [
              {
                'node_id': 'parent_01_child_01',
                'node_name': '스스로 고르는 방향',
                'parent_node': '탐험',
              },
            ],
          },
        ],
      });

      expect(
        feed.insights.single.supportingNodes.single.nodeId,
        'parent_01_child_01',
      );
      expect(
        feed.insights.single.supportingNodes.single.nodeName,
        '스스로 고르는 방향',
      );
    });

    test('mock insight copy avoids forbidden analysis language', () async {
      final feed = await MockFiYouRepository().getInsightFeed();
      final copy = feed.insights
          .map((insight) => '${insight.title} ${insight.description}')
          .join(' ')
          .toLowerCase();
      const forbidden = [
        'score',
        'diagnosis',
        'personality type',
        'analysis result',
        'you are',
        'highly',
      ];

      for (final word in forbidden) {
        expect(copy.contains(word), isFalse, reason: 'Forbidden copy: $word');
      }
    });
  });
}
