import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/data/fi_you_repository.dart';
import 'package:flutter/material.dart';

const _text = FiYouGlass.text;
const _soft = FiYouGlass.textSoft;
const _muted = FiYouGlass.textMuted;
const _gold = FiYouGlass.gold;
const _cyan = FiYouGlass.cyan;
const _mint = Color(0xFF6EE7B7);
const _rose = Color(0xFFFB7185);

class UMapDetailReportScreen extends StatelessWidget {
  const UMapDetailReportScreen({required this.report, super.key});

  final UMapDetailReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _text,
        title: const Text('U-Map Report'),
        actions: [
          IconButton(
            tooltip: 'PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF 저장은 결제 리포트 보관함과 함께 제공될 예정이에요.'),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            _CountsStrip(report: report),
            const SizedBox(height: 16),
            _Hero(report: report),
            const SizedBox(height: 16),
            _SufficiencyPanel(report: report),
            const SizedBox(height: 16),
            _KeywordWrap(keywords: report.keywords),
            const SizedBox(height: 18),
            for (final section in report.sections) ...[
              _ReportSectionTile(section: section),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            _ActionPlanPanel(items: report.actionPlans),
            const SizedBox(height: 14),
            _RecordingGuidePanel(items: report.recordingGuides),
            const SizedBox(height: 14),
            _EvidencePanel(items: report.evidence),
            const SizedBox(height: 14),
            const _DisclaimerPanel(),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.report});

  final UMapDetailReport report;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      borderColor: _cyan.withValues(alpha: 0.28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal U-Map Analysis',
            style: TextStyle(
              color: _cyan,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            report.title,
            style: const TextStyle(
              color: _text,
              fontSize: 27,
              height: 1.08,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            report.coreSentence,
            style: const TextStyle(
              color: _text,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            report.summary,
            style: const TextStyle(
              color: _soft,
              fontSize: 13,
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
  const _CountsStrip({required this.report});

  final UMapDetailReport report;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Nodes', report.sourceCounts['nodes'] ?? 0, _cyan),
      ('Records', report.sourceCounts['records'] ?? 0, _gold),
      ('Diary', report.sourceCounts['diary'] ?? 0, _mint),
    ];
    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(
            child: _CountPill(
              label: items[index].$1,
              value: items[index].$2,
              color: items[index].$3,
            ),
          ),
          if (index != items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
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

class _SufficiencyPanel extends StatelessWidget {
  const _SufficiencyPanel({required this.report});

  final UMapDetailReport report;

  @override
  Widget build(BuildContext context) {
    final sufficiency = report.dataSufficiency;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox.square(
                dimension: 58,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: sufficiency.score.clamp(0, 100) / 100,
                      strokeWidth: 5,
                      color: _mint,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    ),
                    Center(
                      child: Text(
                        '${sufficiency.score}',
                        style: const TextStyle(
                          color: _text,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '분석 충실도',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      sufficiency.label,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          for (final item in sufficiency.items) ...[
            _SufficiencyRow(item: item),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SufficiencyRow extends StatelessWidget {
  const _SufficiencyRow({required this.item});

  final UMapDataSufficiencyItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            item.label,
            style: const TextStyle(
              color: _soft,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          item.value,
          style: const TextStyle(
            color: _text,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          item.status,
          style: const TextStyle(
            color: _mint,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _KeywordWrap extends StatelessWidget {
  const _KeywordWrap({required this.keywords});

  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < keywords.length; index++)
          _KeywordChip(
            label: keywords[index],
            color: _keywordColors[index % _keywordColors.length],
          ),
      ],
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: Color.lerp(color, Colors.white, 0.22),
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ReportSectionTile extends StatelessWidget {
  const _ReportSectionTile({required this.section});

  final UMapReportSection section;

  @override
  Widget build(BuildContext context) {
    final color = _sectionColor(section.type);
    return _Panel(
      borderColor: color.withValues(alpha: 0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_sectionIcon(section.type), color: color, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 17,
                    height: 1.22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            section.body,
            style: const TextStyle(
              color: _soft,
              fontSize: 13,
              height: 1.54,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (section.insights.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final insight in section.insights) ...[
              _BulletLine(text: insight, color: color),
              const SizedBox(height: 7),
            ],
          ],
          if (section.evidenceLabels.isNotEmpty) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final evidence in section.evidenceLabels)
                  _MiniEvidence(label: evidence, color: color),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionPlanPanel extends StatelessWidget {
  const _ActionPlanPanel({required this.items});

  final List<UMapActionPlan> items;

  @override
  Widget build(BuildContext context) {
    return _TitledPanel(
      icon: Icons.task_alt_rounded,
      title: '맞춤 액션 플랜',
      color: _mint,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _ActionPlanTile(item: items[index]),
            if (index != items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ActionPlanTile extends StatelessWidget {
  const _ActionPlanTile({required this.item});

  final UMapActionPlan item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _mint.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _mint.withValues(alpha: 0.18)),
          ),
          child: Text(
            item.horizon,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _mint,
              fontSize: 10.5,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 14,
                  height: 1.28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.body,
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
      ],
    );
  }
}

class _RecordingGuidePanel extends StatelessWidget {
  const _RecordingGuidePanel({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _TitledPanel(
      icon: Icons.edit_note_rounded,
      title: '다음 기록 질문',
      color: _gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items) ...[
            _BulletLine(text: item, color: _gold),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _EvidencePanel extends StatelessWidget {
  const _EvidencePanel({required this.items});

  final List<JournyEvidenceItem> items;

  @override
  Widget build(BuildContext context) {
    return _TitledPanel(
      icon: Icons.fact_check_rounded,
      title: '근거 기록',
      color: _cyan,
      child: Column(
        children: [
          if (items.isEmpty)
            const Text(
              '표시할 근거가 아직 부족해요. 다음 기록이 쌓이면 리포트 근거가 더 선명해집니다.',
              style: TextStyle(color: _soft, height: 1.45),
            )
          else
            for (final item in items.take(6)) ...[
              _EvidenceTile(item: item),
              const SizedBox(height: 9),
            ],
        ],
      ),
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
          left: BorderSide(color: _cyan.withValues(alpha: 0.7), width: 2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 3, bottom: 3),
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

class _DisclaimerPanel extends StatelessWidget {
  const _DisclaimerPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      borderColor: _rose.withValues(alpha: 0.18),
      child: const Text(
        '이 리포트는 U-Map 노드와 기록을 근거로 한 자기이해용 해석입니다. 의료, 법률, 금융 진단이나 조언이 아니며 민감한 결정에는 전문가의 도움을 함께 고려해주세요.',
        style: TextStyle(
          color: _muted,
          fontSize: 11.5,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TitledPanel extends StatelessWidget {
  const _TitledPanel({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      borderColor: color.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _soft,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniEvidence extends StatelessWidget {
  const _MiniEvidence({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 10.5,
            height: 1,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.borderColor});

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: const EdgeInsets.all(16),
      radius: FiYouGlass.glassRadiusSmall,
      borderColor: borderColor ?? Colors.white.withValues(alpha: 0.14),
      child: child,
    );
  }
}

IconData _sectionIcon(String type) {
  switch (type) {
    case 'clear_results':
      return Icons.verified_rounded;
    case 'preference_results':
      return Icons.favorite_rounded;
    case 'interest_results':
      return Icons.travel_explore_rounded;
    case 'aptitude_work_fit':
      return Icons.work_rounded;
    case 'career_type_fit':
      return Icons.account_tree_rounded;
    case 'relationship_fit':
      return Icons.groups_rounded;
    case 'personality_temperament':
      return Icons.psychology_alt_rounded;
    case 'friction_conditions':
      return Icons.warning_amber_rounded;
    case 'evidence':
      return Icons.fact_check_rounded;
    case 'needs_more_records':
      return Icons.playlist_add_check_rounded;
    case 'structure':
      return Icons.hub_rounded;
    case 'themes':
      return Icons.category_rounded;
    case 'patterns':
      return Icons.route_rounded;
    case 'strength':
      return Icons.auto_awesome_rounded;
    case 'risk':
      return Icons.spa_rounded;
    default:
      return Icons.article_outlined;
  }
}

Color _sectionColor(String type) {
  switch (type) {
    case 'clear_results':
      return _cyan;
    case 'preference_results':
      return _rose;
    case 'interest_results':
      return _gold;
    case 'aptitude_work_fit':
      return _mint;
    case 'career_type_fit':
      return FiYouGlass.primarySoft;
    case 'relationship_fit':
      return _cyan;
    case 'personality_temperament':
      return _gold;
    case 'friction_conditions':
      return _rose;
    case 'evidence':
      return _cyan;
    case 'needs_more_records':
      return _muted;
    case 'structure':
      return _cyan;
    case 'themes':
      return _gold;
    case 'patterns':
      return FiYouGlass.primarySoft;
    case 'strength':
      return _mint;
    case 'risk':
      return _rose;
    default:
      return _soft;
  }
}

const _keywordColors = [_cyan, _mint, _gold, FiYouGlass.primarySoft, _rose];
