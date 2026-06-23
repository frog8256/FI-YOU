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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 118),
              sliver: SliverList.list(
                children: [
                  HomeHeader(
                    data: data,
                    onStoreTap: onStoreTap,
                    onLevelTap: onLevelTap,
                  ),
                  const SizedBox(height: 20),
                  GreetingSection(data: data),
                  const SizedBox(height: 14),
                  ExplorationStatusCard(
                    metrics: homeStatsMetrics,
                    latestUpdateLabel: data.latestUpdateLabel,
                    onTap: onStatusTap,
                  ),
                  const SizedBox(height: 14),
                  UMapCard(
                    data: data,
                    onTap: onUMapTap,
                    onShareTap: onShareTap,
                  ),
                  const SizedBox(height: 14),
                  DiaryPromptCard(prompt: data.diaryPrompt, onTap: onDiaryTap),
                  const SizedBox(height: 14),
                  TodayClueCard(clue: data.todayClue, onTap: onStatusTap),
                ],
              ),
            ),
          ],
        ),
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
                  '아직 확정된 해석이 아닙니다. 기록에서 발견한 작은 신호입니다.',
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
