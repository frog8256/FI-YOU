import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/data/fi_you_repository.dart';
import 'package:flutter/material.dart';

const _text = FiYouGlass.text;
const _soft = FiYouGlass.textSoft;
const _muted = FiYouGlass.textMuted;
const _gold = FiYouGlass.gold;
const _cyan = FiYouGlass.cyan;
const _mint = Color(0xFF6EE7B7);

class JournyReportScreen extends StatelessWidget {
  const JournyReportScreen({required this.report, super.key});

  final JournyReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _text,
        title: const Text('Journy'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            _CountsStrip(counts: report.sourceCounts),
            const SizedBox(height: 16),
            _Header(report: report),
            const SizedBox(height: 16),
            _JourneyTimelinePanel(report: report),
            const SizedBox(height: 16),
            _ChapterPanel(report: report),
            const SizedBox(height: 18),
            _SectionTitle(
              icon: Icons.timeline_rounded,
              title: 'Journey Timeline',
              subtitle: '의미 있는 변화 이벤트',
            ),
            const SizedBox(height: 10),
            for (final event in report.timelineEvents.take(8)) ...[
              _TimelineTile(event: event),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            _InsightSection(
              icon: Icons.auto_awesome_rounded,
              title: 'Pattern Evolution',
              items: report.patterns,
              emptyLabel: '아직 충분히 반복된 패턴이 적어요.',
            ),
            const SizedBox(height: 14),
            _InsightSection(
              icon: Icons.flag_rounded,
              title: 'Turning Points',
              items: report.turningPoints,
              emptyLabel: '전환점은 다음 리포트에서 더 선명해질 수 있어요.',
            ),
            const SizedBox(height: 14),
            _InsightSection(
              icon: Icons.near_me_rounded,
              title: 'Next Journey Step',
              items: report.nextSteps,
              emptyLabel: '다음 스텝을 만들려면 기록을 조금 더 남겨주세요.',
            ),
            const SizedBox(height: 14),
            _EvidenceSection(items: report.evidence),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.report});

  final JournyReport report;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Journy Timeline',
          style: TextStyle(
            color: _text,
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${report.sourceWindowLabel} · ${report.starCost} Star',
          style: const TextStyle(
            color: _gold,
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _JourneyTimelinePanel extends StatelessWidget {
  const _JourneyTimelinePanel({required this.report});

  final JournyReport report;

  @override
  Widget build(BuildContext context) {
    final events = report.timelineEvents;
    final start = events.isEmpty ? null : events.last;
    final middle = events.length < 3 ? null : events[events.length ~/ 2];
    final current = events.isEmpty ? null : events.first;
    final next = report.nextSteps.isEmpty ? null : report.nextSteps.first;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Journy Timeline',
            style: TextStyle(
              color: _gold,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            report.sourceWindowLabel,
            style: const TextStyle(
              color: _soft,
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _FlowNode(
            label: 'Next Step',
            dateLabel: 'Next',
            title: next?.title ?? '다음 자기탐구',
            body: next?.body ?? '다음 기록이 쌓이면 Journy의 방향이 더 선명해져요.',
            first: true,
            accent: _mint,
          ),
          _FlowNode(
            label: 'Current',
            dateLabel: current?.dateLabel ?? 'Now',
            title: report.title,
            body: report.summary,
          ),
          _FlowNode(
            label: 'Shift',
            dateLabel: middle?.dateLabel ?? 'Between',
            title: middle?.title ?? '반복 신호가 보이기 시작',
            body: middle?.body ?? _firstPatternBody(report),
          ),
          _FlowNode(
            label: 'Journy Start',
            dateLabel: start?.dateLabel ?? 'Start',
            title: '자기탐구 시작',
            body: start?.body ?? '자기탐구의 첫 기록에서 Journy가 시작돼요.',
            last: true,
          ),
        ],
      ),
    );
  }

  static String _firstPatternBody(JournyReport report) {
    if (report.patterns.isEmpty) {
      return '아직 중간 변화는 희미하지만, 기록이 더 쌓이면 반복되는 방향을 잡을 수 있어요.';
    }
    return report.patterns.first.body;
  }
}

// ignore: unused_element
class _JourneyFlowPanel extends StatelessWidget {
  const _JourneyFlowPanel({required this.report});

  final JournyReport report;

  @override
  Widget build(BuildContext context) {
    final events = report.timelineEvents;
    final start = events.isEmpty ? null : events.last;
    final middle = events.length < 3 ? null : events[events.length ~/ 2];
    final current = events.isEmpty ? null : events.first;
    final next = report.nextSteps.isEmpty ? null : report.nextSteps.first;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Journy Timeline',
            style: TextStyle(
              color: _gold,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            report.sourceWindowLabel,
            style: const TextStyle(
              color: _soft,
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _FlowNode(
            label: 'Start Point',
            dateLabel: start?.dateLabel ?? 'Before',
            title: start?.title ?? '기록이 모이기 시작한 지점',
            body: start?.body ?? '아직 시작 기록이 적어 현재 신호를 기준으로 여정을 열었어요.',
            first: true,
          ),
          _FlowNode(
            label: 'Middle Shift',
            dateLabel: middle?.dateLabel ?? 'Between',
            title: middle?.title ?? '반복되는 신호가 보이기 시작',
            body: middle?.body ?? _firstPatternBody(report),
          ),
          _FlowNode(
            label: 'Current Chapter',
            dateLabel: current?.dateLabel ?? 'Now',
            title: report.title,
            body: report.summary,
          ),
          _FlowNode(
            label: 'Next Step',
            dateLabel: 'Next',
            title: next?.title ?? '다음 탐구로 이어가기',
            body: next?.body ?? '다음 기록이 쌓이면 이 여정의 방향이 더 선명해져요.',
            last: true,
            accent: _mint,
          ),
        ],
      ),
    );
  }

  static String _firstPatternBody(JournyReport report) {
    if (report.patterns.isEmpty) {
      return '아직 중간 변화는 희미하지만, 기록이 더 쌓이면 반복되는 방향을 잡을 수 있어요.';
    }
    return report.patterns.first.body;
  }
}

class _FlowNode extends StatelessWidget {
  const _FlowNode({
    required this.label,
    required this.dateLabel,
    required this.title,
    required this.body,
    this.first = false,
    this.last = false,
    this.accent = _gold,
  });

  final String label;
  final String dateLabel;
  final String title;
  final String body;
  final bool first;
  final bool last;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: first
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: last
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 14.5,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _soft,
                      fontSize: 12.5,
                      height: 1.42,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterPanel extends StatelessWidget {
  const _ChapterPanel({required this.report});

  final JournyReport report;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Chapter',
            style: TextStyle(
              color: _gold,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            report.title,
            style: const TextStyle(
              color: _text,
              fontSize: 22,
              height: 1.18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            report.summary,
            style: const TextStyle(
              color: _soft,
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountsStrip extends StatelessWidget {
  const _CountsStrip({required this.counts});

  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Answers', counts['answers'] ?? 0),
      ('Diary', counts['diary'] ?? 0),
      ('U-Map', counts['uMapSignals'] ?? 0),
    ];
    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(
            child: _CountPill(label: items[index].$1, value: items[index].$2),
          ),
          if (index != items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: _text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _cyan, size: 19),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event});

  final JournyTimelineEvent event;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: Column(
            children: [
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  color: _gold,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 72,
                margin: const EdgeInsets.only(top: 4),
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ],
          ),
        ),
        Expanded(
          child: _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  event.dateLabel,
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _soft,
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightSection extends StatelessWidget {
  const _InsightSection({
    required this.icon,
    required this.title,
    required this.items,
    required this.emptyLabel,
  });

  final IconData icon;
  final String title;
  final List<JournyInsightBlock> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: icon, title: title, subtitle: '근거 기반 해석'),
        const SizedBox(height: 10),
        if (items.isEmpty)
          _Panel(
            child: Text(emptyLabel, style: const TextStyle(color: _soft)),
          )
        else
          for (final item in items) ...[
            _InsightTile(item: item),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.item});

  final JournyInsightBlock item;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 15,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (item.confidenceLabel.trim().isNotEmpty)
                Text(
                  item.confidenceLabel,
                  style: const TextStyle(
                    color: _mint,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.body,
            style: const TextStyle(
              color: _soft,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({required this.items});

  final List<JournyEvidenceItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.fact_check_rounded,
          title: 'Evidence',
          subtitle: '해석에 사용된 기록 요약',
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          const _Panel(
            child: Text(
              '근거 기록이 부족해요. 다음 리포트에서는 Diary와 탐구 답변을 더 반영할 수 있어요.',
              style: TextStyle(color: _soft, height: 1.45),
            ),
          )
        else
          for (final item in items.take(6)) ...[
            _EvidenceTile(item: item),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({required this.item});

  final JournyEvidenceItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: _gold.withValues(alpha: 0.7), width: 2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.sourceType} · ${item.label}',
              style: const TextStyle(
                color: _text,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: const EdgeInsets.all(16),
      radius: FiYouGlass.glassRadiusSmall,
      borderColor: Colors.white.withValues(alpha: 0.14),
      child: child,
    );
  }
}
