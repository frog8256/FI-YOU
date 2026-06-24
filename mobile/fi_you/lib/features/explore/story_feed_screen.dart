import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/data/fi_you_repository.dart';
import 'package:flutter/material.dart';

const _storyBg = FiYouGlass.background;
const _storySurface = FiYouGlass.surface;
const _storyText = FiYouGlass.text;
const _storySoft = FiYouGlass.textSoft;
const _storyMuted = FiYouGlass.textMuted;
const _storyGold = FiYouGlass.gold;
const _storyCyan = FiYouGlass.cyan;

class StoryFeedScreen extends StatefulWidget {
  const StoryFeedScreen({super.key});

  @override
  State<StoryFeedScreen> createState() => _StoryFeedScreenState();
}

class _StoryFeedScreenState extends State<StoryFeedScreen> {
  StoryFeedResponse? _feed;
  bool _loading = true;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    final repository = FiYouRepositoryScope.of(context);
    final feed = await repository.getStoryFeed();
    if (!mounted) {
      return;
    }
    setState(() {
      _feed = feed;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final feed = _feed;
    return Scaffold(
      backgroundColor: _storyBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _storyText,
        title: const Text('나의 이야기'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          children: [
            const _StoryHeader(),
            const SizedBox(height: 18),
            if (_loading)
              const _StoryStatus(
                icon: Icons.menu_book_rounded,
                title: '탐험의 조각을 이야기로 엮고 있어요...',
                body: '최근에 이어진 흐름을 차분한 장면으로 정리하고 있어요.',
              )
            else if (feed?.hasError == true)
              _StoryStatus(
                icon: Icons.refresh_rounded,
                title: '잠시 이야기를 불러오지 못했어요.',
                body: '다시 시도하면 이어지던 장면을 불러올 수 있어요.',
                actionLabel: '다시 시도',
                onAction: _load,
              )
            else if (feed == null || feed.isEmpty)
              const _StoryStatus(
                icon: Icons.auto_stories_rounded,
                title: '조금 더 탐험하면 이야기가 모습을 갖출 거예요.',
                body: '카드가 더 쌓이면 흩어진 선택들이 하나의 장처럼 읽히기 시작합니다.',
              )
            else ...[
              for (final story in feed.stories) ...[
                _StoryCard(story: story),
                const SizedBox(height: 14),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StoryHeader extends StatelessWidget {
  const _StoryHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '나의 이야기',
          style: TextStyle(
            color: _storyText,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '이미 지나온 탐험에서 이어진 조용한 장들이에요.',
          style: TextStyle(color: _storySoft, fontSize: 14, height: 1.45),
        ),
      ],
    );
  }
}

class _StoryStatus extends StatelessWidget {
  const _StoryStatus({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StoryPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _storyGold, size: 28),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: _storyText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: _storySoft,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final UserStory story;

  @override
  Widget build(BuildContext context) {
    final supportingTitles = story.supportingInsights
        .map((insight) => insight.title.trim())
        .where((title) => title.isNotEmpty && !title.startsWith('insight-'))
        .toSet()
        .toList();
    return _StoryPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _sectionLabel(story.type),
            style: const TextStyle(
              color: _storyGold,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            story.title,
            style: const TextStyle(
              color: _storyText,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            story.description,
            style: const TextStyle(
              color: _storySoft,
              fontSize: 14,
              height: 1.58,
            ),
          ),
          if (supportingTitles.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final title in supportingTitles.take(3)) ...[
              _InsightReference(title: title),
              const SizedBox(height: 8),
            ],
          ],
          if (story.updatedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              _dateLabel(story.updatedAt!),
              style: const TextStyle(color: _storyMuted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  static String _sectionLabel(String type) {
    switch (type) {
      case 'current_chapter':
        return '현재의 장';
      case 'emerging_direction':
        return '선명해지는 방향';
      case 'internal_tension':
        return '함께 나타나는 두 흐름';
      case 'hidden_territory':
        return '아직 조용한 영역';
      case 'change_over_time':
        return '변화의 흔적';
      default:
        return '이어지는 이야기';
    }
  }

  static String _dateLabel(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _InsightReference extends StatelessWidget {
  const _InsightReference({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _storyCyan.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _storyCyan.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            const Icon(Icons.notes_rounded, color: _storyCyan, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _storyText,
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _storySurface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    );
  }
}
