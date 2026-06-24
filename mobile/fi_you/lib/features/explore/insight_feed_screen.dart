import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/data/fi_you_repository.dart';
import 'package:flutter/material.dart';

const _insightBg = FiYouGlass.background;
const _insightSurface = FiYouGlass.surface;
const _insightText = FiYouGlass.text;
const _insightSoft = FiYouGlass.textSoft;
const _insightMuted = FiYouGlass.textMuted;
const _insightCyan = FiYouGlass.cyan;

class InsightFeedScreen extends StatefulWidget {
  const InsightFeedScreen({super.key});

  @override
  State<InsightFeedScreen> createState() => _InsightFeedScreenState();
}

class _InsightFeedScreenState extends State<InsightFeedScreen> {
  InsightFeedResponse? _feed;
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
    final feed = await repository.getInsightFeed();
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
      backgroundColor: _insightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _insightText,
        title: const Text('탐험의 발견'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          children: [
            const _InsightFeedHeader(),
            const SizedBox(height: 18),
            if (_loading)
              const _InsightFeedStatus(
                icon: Icons.auto_awesome_rounded,
                title: '탐험의 흐름을 정리하고 있어요...',
                body: '최근 카드에서 이어진 발견을 차분히 모으고 있어요.',
              )
            else if (feed?.hasError == true)
              _InsightFeedStatus(
                icon: Icons.refresh_rounded,
                title: '잠시 흐름을 불러오지 못했어요.',
                body: '다시 시도하면 탐험의 흐름을 이어서 볼 수 있어요.',
                actionLabel: '다시 시도',
                onAction: _load,
              )
            else if (feed == null || feed.isEmpty)
              const _InsightFeedStatus(
                icon: Icons.travel_explore_rounded,
                title: '조금 더 탐험하면 흐름이 보이기 시작할 거예요.',
                body: '카드를 몇 장 더 지나면 반복해서 나타나는 방향이 이곳에 머물기 시작합니다.',
              )
            else ...[
              for (final insight in feed.insights) ...[
                _InsightCard(insight: insight),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightFeedHeader extends StatelessWidget {
  const _InsightFeedHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '조금씩 선명해지는 방향',
          style: TextStyle(
            color: _insightText,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '이미 지나온 탐험에서 조용히 떠오른 발견들이에요.',
          style: TextStyle(color: _insightSoft, fontSize: 14, height: 1.45),
        ),
      ],
    );
  }
}

class _InsightFeedStatus extends StatelessWidget {
  const _InsightFeedStatus({
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
    return _InsightPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _insightCyan, size: 28),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: _insightText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: _insightSoft,
              fontSize: 14,
              height: 1.45,
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

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final UserInsight insight;

  @override
  Widget build(BuildContext context) {
    final nodeNames = insight.supportingNodes
        .map((node) => node.nodeName.trim())
        .where((name) => name.isNotEmpty && !name.startsWith('parent_'))
        .toSet()
        .toList();
    return _InsightPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.title,
            style: const TextStyle(
              color: _insightText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            insight.description,
            style: const TextStyle(
              color: _insightSoft,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (nodeNames.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in nodeNames.take(4)) _NodeChip(label: name),
              ],
            ),
          ],
          if (insight.createdAt != null) ...[
            const SizedBox(height: 12),
            Text(
              _dateLabel(insight.createdAt!),
              style: const TextStyle(color: _insightMuted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  static String _dateLabel(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _NodeChip extends StatelessWidget {
  const _NodeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _insightCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _insightCyan.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: _insightText,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _insightSurface.withValues(alpha: 0.86),
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
