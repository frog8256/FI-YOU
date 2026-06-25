import 'dart:math' as math;

import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:flutter/material.dart';

import 'home_mock_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.data = homeMockData,
    this.onNotificationTap,
    this.onProfileTap,
    this.onStoreTap,
    this.onLevelTap,
    this.onUMapTap,
    this.onDiaryTap,
    this.onQuestionTap,
    this.onStatusTap,
    this.onShareTap,
  });

  final HomeMockData data;

  /// 알림 버튼 클릭 콜백입니다.
  final VoidCallback? onNotificationTap;

  /// 프로필 버튼 클릭 콜백입니다. PM AppShell에서 My 탭 이동에 연결하면 됩니다.
  final VoidCallback? onProfileTap;

  /// Star 박스 클릭 콜백입니다. PM AppShell에서 Store 화면 이동에 연결하면 됩니다.
  final VoidCallback? onStoreTap;

  /// Level 클릭 콜백입니다. PM AppShell에서 My 탭 이동에 연결하면 됩니다.
  final VoidCallback? onLevelTap;

  /// U-Map 카드 클릭 콜백입니다.
  final VoidCallback? onUMapTap;

  /// Diary 작성 유도 카드 클릭 콜백입니다.
  final VoidCallback? onDiaryTap;

  /// 다음 질문 카드 클릭 콜백입니다.
  final VoidCallback? onQuestionTap;

  /// 오늘의 탐구 현황 또는 오늘 발견된 단서 클릭 콜백입니다.
  final VoidCallback? onStatusTap;
  final VoidCallback? onShareTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 118),
              sliver: SliverList.list(
                children: [
                  _HomeWidth(
                    child: HomeHeader(
                      data: data,
                      onStoreTap: onStoreTap,
                      onLevelTap: onLevelTap,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _HomeWidth(
                    child: TodayDiscoveryCard(
                      insight: data.todayClue,
                      onTap: onStatusTap,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _HomeWidth(
                    child: GrowthTimelineCard(
                      metrics: data.activityMetrics,
                      latestUpdateLabel: data.latestUpdateLabel,
                      onTap: onStatusTap,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HomeWidth(
                    child: HeroUniverseCard(data: data, onTap: onUMapTap),
                  ),
                  const SizedBox(height: 16),
                  _HomeWidth(
                    child: AIObservationCard(data: data, onTap: onStatusTap),
                  ),
                  const SizedBox(height: 16),
                  _HomeWidth(
                    child: UniversePreviewCard(
                      data: data,
                      onTap: onUMapTap,
                      onShareTap: onShareTap,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HomeWidth(
                    child: NextExplorationRecommendationCard(
                      data: data,
                      onQuestionTap: onQuestionTap,
                      onDiaryTap: onDiaryTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeWidth extends StatelessWidget {
  const _HomeWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class HeroUniverseCard extends StatelessWidget {
  const HeroUniverseCard({super.key, required this.data, this.onTap});

  final HomeMockData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      borderColor: FiYouHomeColors.primarySoft.withValues(alpha: 0.44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SignalIconPanel(
                icon: Icons.bubble_chart_rounded,
                color: FiYouHomeColors.primarySoft,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionKicker(label: '당신에 대해'),
                    SizedBox(height: 6),
                    Text(
                      '발견된 나의 구조',
                      style: TextStyle(
                        color: FiYouHomeColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              FiYouChevronButton(
                label: '나의 구조',
                onPressed: onTap,
                color: FiYouHomeColors.textSecondary,
                showBorder: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const pattern = _DiscoveryMetricPanel(
                value: '127',
                label: '패턴',
                help: '반복해서 드러난 생각과 행동의 단서',
                color: FiYouHomeColors.accentCyan,
              );
              const connection = _DiscoveryMetricPanel(
                value: '42',
                label: '연결',
                help: '서로 영향을 주는 감정, 선택, 관계의 고리',
                color: FiYouHomeColors.accentGold,
              );

              if (constraints.maxWidth < 332) {
                return const Column(
                  children: [pattern, SizedBox(height: 10), connection],
                );
              }

              return const Row(
                children: [
                  Expanded(child: pattern),
                  SizedBox(width: 10),
                  Expanded(child: connection),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 0.9,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '최근 관측된 특징',
                  style: TextStyle(
                    color: FiYouHomeColors.textMuted,
                    fontSize: 11.2,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  '새로운 아이디어를 현실로 옮기는 속도가 빠르며,\n하나를 오래 이어가는 방식은 계속 진화하고 있습니다.',
                  style: TextStyle(
                    color: FiYouHomeColors.textSecondary,
                    fontSize: 13,
                    height: 1.48,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryMetricPanel extends StatelessWidget {
  const _DiscoveryMetricPanel({
    required this.value,
    required this.label,
    required this.help,
    required this.color,
  });

  final String value;
  final String label;
  final String help;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 106),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: FiYouHomeColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            help,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: FiYouHomeColors.textMuted,
              fontSize: 10.6,
              height: 1.32,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class TodayDiscoveryCard extends StatelessWidget {
  const TodayDiscoveryCard({super.key, required this.insight, this.onTap});

  final String insight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SignalIconPanel(
            icon: Icons.lightbulb_rounded,
            color: FiYouHomeColors.accentGold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 인사이트',
                  style: TextStyle(
                    color: FiYouHomeColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FiYouHomeColors.textSecondary,
                    fontSize: 12.2,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FiYouChevronButton(
            label: '오늘의 인사이트',
            onPressed: onTap,
            color: FiYouHomeColors.textSecondary,
            showBorder: false,
          ),
        ],
      ),
    );
  }
}

class AIObservationCard extends StatelessWidget {
  const AIObservationCard({super.key, required this.data, this.onTap});

  final HomeMockData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const keywords = [
      '차분한 정리',
      '기준 세우기',
      '느린 확신',
      '혼자 회복',
      '상황 관찰',
      '오래 가는 선택',
    ];

    return FiYouSurface(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SignalIconPanel(
                icon: Icons.psychology_alt_rounded,
                color: FiYouHomeColors.primarySoft,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionKicker(label: 'AI가 보는 나'),
                    SizedBox(height: 6),
                    Text(
                      '깊은 관찰',
                      style: TextStyle(
                        color: FiYouHomeColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              FiYouChevronButton(
                label: '깊은 관찰',
                onPressed: onTap,
                color: FiYouHomeColors.textSecondary,
                showBorder: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '최근 기록에서 자주 반복된 나의 신호예요.',
            style: TextStyle(
              color: FiYouHomeColors.textMuted,
              fontSize: 11.5,
              height: 1.35,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < keywords.length; i++)
                _ObservationKeywordChip(
                  label: keywords[i],
                  color: _observationKeywordColors[i],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ObservationKeywordChip extends StatelessWidget {
  const _ObservationKeywordChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.9),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Color.lerp(color, Colors.white, 0.18),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

const _observationKeywordColors = [
  FiYouHomeColors.primarySoft,
  FiYouHomeColors.accentGold,
  FiYouHomeColors.accentCyan,
  Color(0xFF6EE7B7),
  Color(0xFFF0ABFC),
  Color(0xFFFB7185),
];

class GrowthTimelineCard extends StatelessWidget {
  const GrowthTimelineCard({
    super.key,
    required this.metrics,
    required this.latestUpdateLabel,
    this.onTap,
  });

  final List<HomeActivityMetric> metrics;
  final String latestUpdateLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final timeline = [
      ('오늘', '감정 신호 3개가 새로 연결됐어요', FiYouHomeColors.accentGold),
      ('이번 주', '선택 기준 노드가 더 선명해졌어요', FiYouHomeColors.accentCyan),
      ('최근', '관계 반응과 회복 패턴 사이의 연결을 발견했어요', FiYouHomeColors.primarySoft),
    ];

    return FiYouSurface(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionKicker(label: '성장 타임라인'),
                    SizedBox(height: 6),
                    Text(
                      '최근 변화',
                      style: TextStyle(
                        color: FiYouHomeColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                latestUpdateLabel,
                style: const TextStyle(
                  color: FiYouHomeColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          for (var i = 0; i < timeline.length; i++) ...[
            _TimelineRow(
              label: timeline[i].$1,
              body: timeline[i].$2,
              color: timeline[i].$3,
            ),
            if (i != timeline.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.body,
    required this.color,
  });

  final String label;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.34),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(
              color: FiYouHomeColors.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
        ),
        Expanded(
          child: Text(
            body,
            style: const TextStyle(
              color: FiYouHomeColors.textSecondary,
              fontSize: 12.5,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class UniverseProgressCard extends StatelessWidget {
  const UniverseProgressCard({super.key, required this.data, this.onTap});

  final HomeMockData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionKicker(label: 'Universe Progress'),
          const SizedBox(height: 6),
          const Text(
            '10개 영역의 대표 작은 신호',
            style: TextStyle(
              color: FiYouHomeColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 15),
          for (var i = 0; i < _homeNodeHighlights.length; i++) ...[
            _NodeSubnodeRow(node: _homeNodeHighlights[i]),
            if (i != _homeNodeHighlights.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _NodeSubnodeRow extends StatelessWidget {
  const _NodeSubnodeRow({required this.node});

  final _HomeNodeHighlight node;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: node.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: node.color.withValues(alpha: 0.28),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 78,
          child: Text(
            node.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: FiYouHomeColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.topSubnode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: node.color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                node.signal,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: FiYouHomeColors.textMuted,
                  fontSize: 10.8,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UniversePreviewCard extends StatelessWidget {
  const UniversePreviewCard({
    super.key,
    required this.data,
    this.onTap,
    this.onShareTap,
  });

  final HomeMockData data;
  final VoidCallback? onTap;
  final VoidCallback? onShareTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionKicker(label: 'Universe Preview'),
                    SizedBox(height: 6),
                    Text(
                      '나의 U-Map 스냅샷',
                      style: TextStyle(
                        color: FiYouHomeColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              FiYouLiquidIconButton(
                label: '공유',
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: onShareTap,
                size: 38,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '10개의 영역에서 지금 가장 선명한 작은 신호예요.',
            style: TextStyle(
              color: FiYouHomeColors.textMuted,
              fontSize: 11.5,
              height: 1.35,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          const _MiniUMapSubnodeGrid(nodes: _homeNodeHighlights),
        ],
      ),
    );
  }
}

class _MiniUMapSubnodeGrid extends StatelessWidget {
  const _MiniUMapSubnodeGrid({required this.nodes});

  final List<_HomeNodeHighlight> nodes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 24) / 5;
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final node in nodes)
              SizedBox(
                width: itemWidth,
                child: _MiniUMapSubnodeTile(node: node),
              ),
          ],
        );
      },
    );
  }
}

class _MiniUMapSubnodeTile extends StatelessWidget {
  const _MiniUMapSubnodeTile({required this.node});

  final _HomeNodeHighlight node;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(6, 7, 6, 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: node.color.withValues(alpha: 0.18),
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: node.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: node.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            node.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: FiYouHomeColors.textMuted,
              fontSize: 9.2,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Center(
              child: Text(
                node.topSubnode,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: node.color,
                  fontSize: 9.8,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeNodeHighlight {
  const _HomeNodeHighlight({
    required this.label,
    required this.topSubnode,
    required this.signal,
    required this.color,
  });

  final String label;
  final String topSubnode;
  final String signal;
  final Color color;
}

const _homeNodeHighlights = [
  _HomeNodeHighlight(
    label: '관계 반응',
    topSubnode: '빠른 공감 감지',
    signal: '상대의 온도 변화를 먼저 읽음',
    color: Color(0xFFA78BFA),
  ),
  _HomeNodeHighlight(
    label: '탐험 흐름',
    topSubnode: '패턴 재구성',
    signal: '흩어진 단서를 구조로 묶음',
    color: Color(0xFF7DD3FC),
  ),
  _HomeNodeHighlight(
    label: '감정 신호',
    topSubnode: '잔상 오래 보기',
    signal: '하루 뒤에도 남는 장면을 추적',
    color: Color(0xFFFB7185),
  ),
  _HomeNodeHighlight(
    label: '회복 패턴',
    topSubnode: '혼자 정리하는 시간',
    signal: '소음이 줄 때 에너지가 회복됨',
    color: Color(0xFFC4B5FD),
  ),
  _HomeNodeHighlight(
    label: '선택 기준',
    topSubnode: '오래 갈 수 있음',
    signal: '즉시성보다 지속성을 우선함',
    color: Color(0xFFF7C948),
  ),
  _HomeNodeHighlight(
    label: '몰입 방향',
    topSubnode: '아이디어 실행',
    signal: '생각을 빠르게 현실로 옮김',
    color: Color(0xFF60A5FA),
  ),
  _HomeNodeHighlight(
    label: '갈등 반응',
    topSubnode: '거리 두고 판단',
    signal: '바로 맞서기보다 맥락을 확인',
    color: Color(0xFFF87171),
  ),
  _HomeNodeHighlight(
    label: '표현 확장',
    topSubnode: '짧고 선명한 언어',
    signal: '복잡한 감각을 문장으로 압축',
    color: Color(0xFF8B5CF6),
  ),
  _HomeNodeHighlight(
    label: '생활 리듬',
    topSubnode: '몰입 후 회복',
    signal: '강한 집중 뒤 휴식이 필요함',
    color: Color(0xFF6EE7B7),
  ),
  _HomeNodeHighlight(
    label: '성장 방식',
    topSubnode: '반복보다 변형',
    signal: '같은 방식을 조금씩 바꿔 감',
    color: Color(0xFFF0ABFC),
  ),
];

class NextExplorationRecommendationCard extends StatelessWidget {
  const NextExplorationRecommendationCard({
    super.key,
    required this.data,
    this.onQuestionTap,
    this.onDiaryTap,
  });

  final HomeMockData data;
  final VoidCallback? onQuestionTap;
  final VoidCallback? onDiaryTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      borderColor: FiYouHomeColors.accentGold.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionKicker(label: '다음 탐구 추천'),
          const SizedBox(height: 7),
          Text(
            data.nextQuestion,
            style: const TextStyle(
              color: FiYouHomeColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.estimatedQuestionTime,
            style: const TextStyle(
              color: FiYouHomeColors.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 15),
          _NextExplorationActions(
            onQuestionTap: onQuestionTap,
            onDiaryTap: onDiaryTap,
          ),
        ],
      ),
    );
  }
}

class _NextExplorationActions extends StatelessWidget {
  const _NextExplorationActions({this.onQuestionTap, this.onDiaryTap});

  final VoidCallback? onQuestionTap;
  final VoidCallback? onDiaryTap;

  @override
  Widget build(BuildContext context) {
    final primary = FiYouLiquidButton(
      label: '탐구 시작하기',
      icon: const Icon(Icons.auto_awesome_rounded),
      onPressed: onQuestionTap,
      height: 52,
      fontSize: 14,
      accentColor: FiYouHomeColors.accentGold,
      accentStrength: 0.8,
    );
    final secondary = FiYouLiquidButton(
      label: 'Diary로 남기기',
      icon: const Icon(Icons.edit_note_rounded),
      onPressed: onDiaryTap,
      height: 52,
      fontSize: 14,
      accentColor: FiYouHomeColors.accentCyan,
      accentStrength: 0.45,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 336) {
          return Column(
            children: [primary, const SizedBox(height: 10), secondary],
          );
        }

        return Row(
          children: [
            Expanded(flex: 6, child: primary),
            const SizedBox(width: 10),
            Expanded(flex: 5, child: secondary),
          ],
        );
      },
    );
  }
}

class _SectionKicker extends StatelessWidget {
  const _SectionKicker({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: FiYouHomeColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 0,
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.data,
    this.onStoreTap,
    this.onLevelTap,
  });

  final HomeMockData data;
  final VoidCallback? onStoreTap;
  final VoidCallback? onLevelTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 38,
          height: 38,
          child: Center(
            child: HomeSparkIcon(
              color: FiYouHomeColors.brandLavender,
              size: 34,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'My Universe',
          style: TextStyle(
            color: FiYouHomeColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const Spacer(),
        StarLevelBadge(
          starCount: data.starCount,
          levelLabel: data.levelLabel,
          onStarTap: onStoreTap,
          onLevelTap: onLevelTap,
        ),
      ],
    );
  }
}

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouLiquidIconButton(
      label: tooltip,
      icon: Icon(icon),
      onPressed: onTap,
      size: 42,
    );
  }
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key, required this.data});

  final HomeMockData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요. ${data.userName} 님!',
          style: const TextStyle(
            color: FiYouHomeColors.textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            height: 1.18,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '오늘도 나를 발견하는 하루 되세요.',
          style: TextStyle(
            color: FiYouHomeColors.textSecondary,
            fontSize: 12.5,
            height: 1.4,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class JourneyStatsStrip extends StatelessWidget {
  const JourneyStatsStrip({super.key, required this.metrics});

  final List<HomeJourneyMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      fillColor: FiYouHomeColors.surfaceCompact,
      borderColor: FiYouHomeColors.borderSubtle,
      child: Row(
        children: [
          for (var i = 0; i < metrics.length; i++) ...[
            Expanded(child: _JourneyMetricPill(metric: metrics[i])),
            if (i == 2) const _JourneyStatsDivider(),
            if (i != metrics.length - 1 && i != 2) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _JourneyStatsDivider extends StatelessWidget {
  const _JourneyStatsDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: FiYouGlass.glassStrokeBottom,
    );
  }
}

class _JourneyMetricPill extends StatelessWidget {
  const _JourneyMetricPill({required this.metric});

  final HomeJourneyMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            metric.label,
            maxLines: 1,
            style: const TextStyle(
              color: FiYouHomeColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            metric.value,
            maxLines: 1,
            style: const TextStyle(
              color: FiYouHomeColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class StarLevelBadge extends StatelessWidget {
  const StarLevelBadge({
    super.key,
    required this.starCount,
    required this.levelLabel,
    this.onStarTap,
    this.onLevelTap,
  });

  final int starCount;
  final String levelLabel;
  final VoidCallback? onStarTap;
  final VoidCallback? onLevelTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: FiYouGlass.ctaGlassV5(
        borderColor: FiYouHomeColors.accentGold,
        radius: FiYouGlass.glassRadiusSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Star 구매 화면으로 이동',
            child: _BadgeSegment(
              onTap: onStarTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HomeStarIcon(
                    color: FiYouHomeColors.accentGold,
                    size: 19,
                  ),
                  const SizedBox(width: 6),
                  Text('$starCount', style: _badgeTextStyle),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: FiYouGlass.glassStrokeSide,
          ),
          Tooltip(
            message: 'My 화면으로 이동',
            child: _BadgeSegment(
              onTap: onLevelTap,
              child: Text(levelLabel, style: _badgeTextStyle),
            ),
          ),
        ],
      ),
    );
  }

  static const _badgeTextStyle = TextStyle(
    color: FiYouHomeColors.accentGold,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );
}

class _BadgeSegment extends StatelessWidget {
  const _BadgeSegment({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
          child: child,
        ),
      ),
    );
  }
}

class HomeStarIcon extends StatelessWidget {
  const HomeStarIcon({required this.color, required this.size, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _HomeStarIconPainter(color)),
    );
  }
}

class _HomeStarIconPainter extends CustomPainter {
  const _HomeStarIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.shortestSide * 0.46;
    final inner = outer * 0.48;
    final path = Path();

    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final shadow = Paint()
      ..color = color.withValues(alpha: 0.32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path.shift(const Offset(0, 1)), shadow);

    final fill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.95,
        colors: [
          Colors.white.withValues(alpha: 0.96),
          color,
          const Color(0xFFD99A1F),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(covariant _HomeStarIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class NextQuestionCard extends StatelessWidget {
  const NextQuestionCard({
    super.key,
    required this.question,
    required this.estimatedTime,
    this.onTap,
  });

  final String question;
  final String estimatedTime;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
      fillColor: FiYouHomeColors.surfaceAction,
      borderColor: FiYouHomeColors.borderSubtle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SignalIconPanel(
            icon: Icons.lightbulb_rounded,
            color: FiYouHomeColors.accentGold,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘 할 일',
                  style: TextStyle(
                    color: FiYouHomeColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 10),
                _TaskLine(
                  icon: Icons.edit_note_rounded,
                  label: 'Diary 작성하기',
                  color: FiYouHomeColors.accentCyan,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FiYouChevronButton(
            color: FiYouHomeColors.textSecondary,
            label: 'Diary',
            size: 32,
            onPressed: onTap,
            showBorder: false,
          ),
        ],
      ),
    );
  }
}

class _TaskLine extends StatelessWidget {
  const _TaskLine({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FiYouIconTile(
          color: color,
          size: FiYouControlTokens.iconTileXSmall,
          child: icon == Icons.auto_awesome_rounded
              ? HomeSparkIcon(
                  color: color,
                  size: FiYouControlTokens.iconTileXSmallIcon,
                )
              : Icon(
                  icon,
                  color: color,
                  size: FiYouControlTokens.iconTileXSmallIcon,
                ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: FiYouHomeColors.textSecondary,
            fontSize: 12.3,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class UMapCard extends StatelessWidget {
  const UMapCard({super.key, required this.data, this.onTap, this.onShareTap});

  final HomeMockData data;
  final VoidCallback? onTap;
  final VoidCallback? onShareTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 18),
      fillColor: FiYouHomeColors.surfaceBase,
      borderColor: FiYouHomeColors.borderVisible,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.018),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.24),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SignalIconPanel(
                  icon: Icons.auto_awesome_rounded,
                  color: FiYouHomeColors.primarySoft,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '현재 기록에서 보이는 나의 흐름',
                        style: TextStyle(
                          color: FiYouHomeColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"${data.userName}" 님은 ${data.universeOneLiner}처럼 보여요',
                        style: const TextStyle(
                          color: FiYouHomeColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 0.9,
              ),
            ),
            child: Text(
              data.universeSummaryBody,
              style: const TextStyle(
                color: FiYouHomeColors.textSecondary,
                fontSize: 13,
                height: 1.55,
                letterSpacing: 0,
              ),
            ),
          ),
          const Offstage(child: SizedBox.shrink()),
          Offstage(
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: FiYouHomeColors.textSecondary,
                      fontSize: 13,
                      height: 1.48,
                      letterSpacing: 0,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '"${data.userName}" 님은 ${data.universeOneLiner}처럼 보여요.\n',
                        style: const TextStyle(
                          color: FiYouHomeColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(text: data.universeSummaryBody),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  data.universeSummarySupport,
                  style: const TextStyle(
                    color: FiYouHomeColors.textMuted,
                    fontSize: 11.8,
                    height: 1.42,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < data.recommendations.length; i++) ...[
                Expanded(
                  child: _RecommendationTile(item: data.recommendations[i]),
                ),
                if (i != data.recommendations.length - 1)
                  const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.item});

  final HomeRecommendation item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 78),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.018),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.42),
          width: 1.25,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 18),
          const SizedBox(height: 7),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: FiYouHomeColors.textMuted,
              fontSize: 9.8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.value,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.4,
                height: 1.18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UMapGraph extends StatelessWidget {
  const UMapGraph({super.key, required this.axes});

  final List<HomeAxisClue> axes;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: UMapGraphPainter(axes: axes),
      child: const SizedBox.expand(),
    );
  }
}

class UMapGraphPainter extends CustomPainter {
  const UMapGraphPainter({required this.axes});

  final List<HomeAxisClue> axes;

  @override
  void paint(Canvas canvas, Size size) {
    if (axes.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.31;
    final axisCount = axes.length;

    _drawAtmosphere(canvas, center, radius);
    _drawGrid(canvas, center, radius, axisCount);
    _drawData(canvas, center, radius, axisCount);
    _drawCenterCore(canvas, center);
    _drawNodesAndLabels(canvas, size, center, radius, axisCount);
  }

  void _drawAtmosphere(Canvas canvas, Offset center, double radius) {
    final glowRect = Rect.fromCircle(center: center, radius: radius * 1.7);
    canvas.drawCircle(
      center,
      radius * 1.45,
      Paint()
        ..shader = RadialGradient(
          colors: [
            FiYouHomeColors.primaryPurple.withValues(alpha: 0.22),
            FiYouHomeColors.accentCyan.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ).createShader(glowRect),
    );

    final particles = [
      (angle: -0.72, distance: 1.3, size: 1.4, color: const Color(0xFF7DD3FC)),
      (angle: 0.36, distance: 1.24, size: 1.1, color: const Color(0xFFC4B5FD)),
      (angle: 1.18, distance: 1.27, size: 1.3, color: const Color(0xFFF7C948)),
      (angle: 2.26, distance: 1.28, size: 1.5, color: const Color(0xFF60A5FA)),
      (angle: 3.06, distance: 1.22, size: 1.1, color: const Color(0xFFFB7185)),
      (angle: 4.08, distance: 1.26, size: 1.2, color: const Color(0xFF8B5CF6)),
    ];

    for (final particle in particles) {
      final point = Offset(
        center.dx + math.cos(particle.angle) * radius * particle.distance,
        center.dy + math.sin(particle.angle) * radius * particle.distance,
      );
      canvas.drawCircle(
        point,
        particle.size,
        Paint()..color = particle.color.withValues(alpha: 0.42),
      );
    }
  }

  void _drawGrid(Canvas canvas, Offset center, double radius, int axisCount) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65;
    final axisPaint = Paint()
      ..color = FiYouHomeColors.primarySoft.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    for (var step = 1; step <= 5; step++) {
      final path = Path();
      final stepRadius = radius * step / 5;
      for (var i = 0; i < axisCount; i++) {
        final point = _point(center, stepRadius, i, axisCount);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        gridPaint..color = Colors.white.withValues(alpha: 0.055 + step * 0.012),
      );
    }

    final outerPath = Path();
    for (var i = 0; i < axisCount; i++) {
      final point = _point(center, radius * 1.06, i, axisCount);
      if (i == 0) {
        outerPath.moveTo(point.dx, point.dy);
      } else {
        outerPath.lineTo(point.dx, point.dy);
      }
      canvas.drawLine(center, _point(center, radius, i, axisCount), axisPaint);
    }
    outerPath.close();
    canvas.drawPath(
      outerPath,
      Paint()
        ..color = const Color(0xFFC4B5FD).withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.95,
    );

    final dotPaint = Paint()..style = PaintingStyle.fill;
    const dotCount = 56;
    for (var i = 0; i < dotCount; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / dotCount;
      final point = Offset(
        center.dx + math.cos(angle) * radius * 1.16,
        center.dy + math.sin(angle) * radius * 1.16,
      );
      canvas.drawCircle(
        point,
        i.isEven ? 0.85 : 0.55,
        dotPaint
          ..color = const Color(
            0xFFC4B5FD,
          ).withValues(alpha: i.isEven ? 0.2 : 0.12),
      );
    }
  }

  void _drawData(Canvas canvas, Offset center, double radius, int axisCount) {
    final path = Path();
    for (var i = 0; i < axisCount; i++) {
      final valueRatio = _ratio(axes[i].value);
      final point = _point(center, radius * valueRatio, i, axisCount);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          colors: [
            FiYouHomeColors.primaryPurple.withValues(alpha: 0.34),
            FiYouHomeColors.primaryPurple.withValues(alpha: 0.16),
            FiYouHomeColors.accentCyan.withValues(alpha: 0.05),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFC4B5FD).withValues(alpha: 0.86)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawCenterCore(Canvas canvas, Offset center) {
    canvas.drawCircle(
      center,
      19,
      Paint()
        ..shader = RadialGradient(
          colors: [
            FiYouHomeColors.primarySoft.withValues(alpha: 0.28),
            FiYouHomeColors.primaryPurple.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 24)),
    );
    canvas.drawCircle(
      center,
      4.2,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.92),
            FiYouHomeColors.primarySoft.withValues(alpha: 0.72),
            FiYouHomeColors.primaryPurple.withValues(alpha: 0.22),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 8)),
    );
    _drawSpark(canvas, center, 7.2, Colors.white.withValues(alpha: 0.88));
  }

  void _drawNodesAndLabels(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    int axisCount,
  ) {
    for (var i = 0; i < axisCount; i++) {
      final axis = axes[i];
      final valueRatio = _ratio(axis.value);
      final node = _point(center, radius * valueRatio, i, axisCount);
      final glowStrength = ((valueRatio - 0.4) / 0.45).clamp(0.0, 1.0);

      if (glowStrength > 0.08) {
        canvas.drawCircle(
          node,
          5.5 + glowStrength * 8,
          Paint()
            ..color = axis.color.withValues(alpha: 0.18 * glowStrength)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              5 + glowStrength * 8,
            ),
        );
      }

      canvas.drawCircle(
        node,
        3.5,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.94), axis.color],
          ).createShader(Rect.fromCircle(center: node, radius: 4.4)),
      );
      canvas.drawCircle(
        node,
        3.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = Colors.white.withValues(alpha: 0.58),
      );

      final labelPoint = _point(center, radius + 34, i, axisCount);
      final angle = -math.pi / 2 + i * 2 * math.pi / axisCount;
      final align = math.cos(angle) > 0.35
          ? TextAlign.left
          : math.cos(angle) < -0.35
          ? TextAlign.right
          : TextAlign.center;
      final painter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${axis.label}\n',
              style: TextStyle(
                color: axis.color,
                fontSize: 9.2,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: _valueLabel(axis.value),
              style: TextStyle(
                color: axis.color,
                fontSize: 11.5,
                height: 1.05,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        textAlign: align,
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: 46);
      final dx = (labelPoint.dx - painter.width / 2).clamp(
        0.0,
        size.width - painter.width,
      );
      final dy = (labelPoint.dy - painter.height / 2).clamp(
        0.0,
        size.height - painter.height,
      );
      painter.paint(canvas, Offset(dx, dy));
    }
  }

  double _ratio(double value) {
    final normalized = value > 1 ? value / 100 : value;
    return normalized.clamp(0.08, 1.0);
  }

  String _valueLabel(double value) {
    return value > 1
        ? value.round().toString()
        : (value * 100).round().toString();
  }

  Offset _point(Offset center, double radius, int index, int total) {
    final angle = -math.pi / 2 + index * 2 * math.pi / total;
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  void _drawSpark(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx + radius * 0.18,
        center.dy - radius * 0.18,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.18,
        center.dy + radius * 0.18,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.18,
        center.dy + radius * 0.18,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.18,
        center.dy - radius * 0.18,
        center.dx,
        center.dy - radius,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant UMapGraphPainter oldDelegate) {
    return oldDelegate.axes != axes;
  }
}

class DiaryPromptCard extends StatelessWidget {
  const DiaryPromptCard({super.key, required this.prompt, this.onTap});

  final String prompt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouActionTile(
      title: 'Diary 작성하기',
      body: prompt,
      icon: Icons.edit_note_rounded,
      accentColor: FiYouHomeColors.accentCyan,
      onTap: onTap,
    );
  }
}

class TodayClueCard extends StatelessWidget {
  const TodayClueCard({super.key, required this.clue, this.onTap});

  final String clue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      fillColor: FiYouHomeColors.surfaceInsight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SignalIconPanel(
            icon: Icons.auto_awesome_rounded,
            color: FiYouHomeColors.accentGold,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘 발견된 단서',
                  style: TextStyle(
                    color: FiYouHomeColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  clue,
                  style: const TextStyle(
                    color: FiYouHomeColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.42,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '아직 고정된 결론이 아니에요. 기록에서 발견한 작은 신호입니다.',
                  style: TextStyle(
                    color: FiYouHomeColors.textMuted,
                    fontSize: 11.2,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          FiYouChevronButton(
            color: FiYouHomeColors.textSecondary,
            label: 'clue',
            size: 32,
            onPressed: onTap,
            showBorder: false,
          ),
        ],
      ),
    );
  }
}

class ExplorationStatusCard extends StatelessWidget {
  const ExplorationStatusCard({
    super.key,
    required this.metrics,
    required this.latestUpdateLabel,
    this.onTap,
  });

  final List<HomeActivityMetric> metrics;
  final String latestUpdateLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      fillColor: FiYouHomeColors.surfaceCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '오늘의 탐구 현황',
                  style: TextStyle(
                    color: FiYouHomeColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              FiYouChevronButton(
                label: 'details',
                onPressed: onTap,
                color: FiYouHomeColors.textSecondary,
                showBorder: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < metrics.length; i++) ...[
                Expanded(child: ActivityMetricItem(metric: metrics[i])),
                if (i != metrics.length - 1)
                  Container(
                    width: 1,
                    height: 44,
                    color: FiYouGlass.glassStrokeSide,
                  ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              latestUpdateLabel,
              style: const TextStyle(
                color: FiYouHomeColors.textMuted,
                fontSize: 11.5,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityMetricItem extends StatelessWidget {
  const ActivityMetricItem({super.key, required this.metric});

  final HomeActivityMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FiYouIconTile(
          color: metric.color,
          size: FiYouControlTokens.iconTileSmall,
          child: metric.icon == Icons.auto_awesome_rounded
              ? HomeSparkIcon(
                  color: metric.color,
                  size: FiYouControlTokens.iconTileSmallIcon,
                )
              : Icon(
                  metric.icon,
                  color: metric.color,
                  size: FiYouControlTokens.iconTileSmallIcon,
                ),
        ),
        const SizedBox(height: 8),
        Text(
          metric.value,
          style: const TextStyle(
            color: FiYouHomeColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          metric.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: FiYouHomeColors.textMuted,
            fontSize: 10.5,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class FiYouActionTile extends StatelessWidget {
  const FiYouActionTile({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      fillColor: FiYouHomeColors.surfaceBase,
      borderColor: FiYouHomeColors.borderSubtle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: FiYouHomeColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                body,
                style: const TextStyle(
                  color: FiYouHomeColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.38,
                  letterSpacing: 0,
                ),
              ),
            ],
          );
          final action = FiYouChevronButton(
            label: title,
            onPressed: onTap,
            color: FiYouHomeColors.textSecondary,
            showBorder: false,
          );

          if (constraints.maxWidth < 312) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SignalIconPanel(icon: icon, color: accentColor),
                    const SizedBox(width: 13),
                    Expanded(child: text),
                  ],
                ),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            );
          }

          return Row(
            children: [
              SignalIconPanel(icon: icon, color: accentColor),
              const SizedBox(width: 13),
              Expanded(child: text),
              const SizedBox(width: 12),
              action,
            ],
          );
        },
      ),
    );
  }
}

class SignalIconPanel extends StatelessWidget {
  const SignalIconPanel({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FiYouIconTile(
      color: color,
      child: icon == Icons.auto_awesome_rounded
          ? HomeSparkIcon(
              color: color,
              size: FiYouControlTokens.iconTileMediumSpark,
            )
          : Icon(
              icon,
              color: color,
              size: FiYouControlTokens.iconTileMediumIcon,
            ),
    );
  }
}

class HomeSparkIcon extends StatelessWidget {
  const HomeSparkIcon({required this.color, required this.size, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _HomeSparkIconPainter(color)),
    );
  }
}

class _HomeSparkIconPainter extends CustomPainter {
  const _HomeSparkIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    final center = Offset(size.width * 0.48, size.height * 0.52);
    final bright = Color.lerp(color, Colors.white, 0.55)!;
    final glow = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shortest * 0.12);
    final fill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.9,
        colors: [Colors.white, bright, color],
        stops: const [0.0, 0.22, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: shortest * 0.42));

    final main = _sparkPath(center, shortest * 0.36, shortest * 0.12);
    canvas.drawPath(main, glow);
    canvas.drawPath(main, fill);
    canvas.drawPath(
      main,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeJoin = StrokeJoin.round
        ..color = bright.withValues(alpha: 0.72),
    );
    _drawSmall(
      canvas,
      Offset(size.width * 0.76, size.height * 0.24),
      shortest * 0.12,
      bright,
    );
    _drawSmall(
      canvas,
      Offset(size.width * 0.24, size.height * 0.72),
      shortest * 0.09,
      color,
    );
  }

  Path _sparkPath(Offset center, double longRadius, double shortRadius) {
    return Path()
      ..moveTo(center.dx, center.dy - longRadius)
      ..quadraticBezierTo(
        center.dx + shortRadius * 0.62,
        center.dy - shortRadius * 0.62,
        center.dx + longRadius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + shortRadius * 0.62,
        center.dy + shortRadius * 0.62,
        center.dx,
        center.dy + longRadius,
      )
      ..quadraticBezierTo(
        center.dx - shortRadius * 0.62,
        center.dy + shortRadius * 0.62,
        center.dx - longRadius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - shortRadius * 0.62,
        center.dy - shortRadius * 0.62,
        center.dx,
        center.dy - longRadius,
      )
      ..close();
  }

  void _drawSmall(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawPath(
      _sparkPath(center, radius, radius * 0.35),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeSparkIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class FiYouSurface extends StatelessWidget {
  const FiYouSurface({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.fillColor = FiYouHomeColors.surfaceBase,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color fillColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: padding,
      borderColor: borderColor,
      onTap: onTap,
      child: child,
    );
  }
}

abstract final class FiYouHomeColors {
  static const backgroundBase = Color(0xFF050714);
  static const surfaceBase = Color(0xFF0B1020);
  static const surfaceGlass = FiYouGlass.glassFill;
  static const surfaceInsight = Color(0xFF10172A);
  static const surfaceAction = Color(0xFF0B1722);
  static const surfaceCompact = Color(0xFF0C1222);
  static const borderSubtle = Color(0xFF1A2440);
  static const borderVisible = FiYouGlass.glassStrokeSide;
  static const glassBorder = FiYouGlass.glassStrokeSide;
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB7C0D7);
  static const textMuted = Color(0xFF7F8AA6);
  static const primaryPurple = Color(0xFF8B5CF6);
  static const primarySoft = Color(0xFFC4B5FD);
  static const brandLavender = Color(0xFFE7D9FF);
  static const accentCyan = Color(0xFF7DD3FC);
  static const accentGold = Color(0xFFF7C948);
}
