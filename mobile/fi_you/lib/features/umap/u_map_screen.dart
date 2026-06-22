import 'dart:math' as math;

import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:flutter/material.dart';

typedef UMapScreen = FiYouUMapScreen;

BoxDecoration _liquidGlassDecoration({
  required double radius,
  Color? borderColor,
  bool large = false,
  bool cta = false,
}) {
  if (large) {
    return FiYouGlass.largeGlassV5(radius: radius, borderColor: borderColor);
  }
  return cta
      ? FiYouGlass.ctaGlassV5(radius: radius, borderColor: borderColor)
      : FiYouGlass.smallGlassV5(radius: radius, borderColor: borderColor);
}

class FiYouUMapScreen extends StatelessWidget {
  const FiYouUMapScreen({
    super.key,
    this.isEmpty = false,
    this.onStartQuestion,
    this.onShare,
    this.onOpenGrowthMap,
    this.onOpenRelationMap,
    this.onOpenReport,
    this.bottomPadding = 0,
  });

  final bool isEmpty;
  final VoidCallback? onStartQuestion;
  final VoidCallback? onShare;
  final VoidCallback? onOpenGrowthMap;
  final VoidCallback? onOpenRelationMap;
  final VoidCallback? onOpenReport;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final bottomSpace = math.max(bottomPadding, 24.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, bottomSpace + 132),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  const _Header(),
                  const SizedBox(height: 18),
                  if (isEmpty)
                    _EmptyState(onStartQuestion: onStartQuestion)
                  else ...[
                    _RadarCard(axes: _axes, onShare: onShare),
                    const SizedBox(height: 16),
                    _AxisSummaryBox(
                      axes: _axisSummaries,
                      onOpenReport: onOpenReport,
                    ),
                    const SizedBox(height: 12),
                    _PremiumExtensionSection(
                      onOpenGrowthMap: onOpenGrowthMap,
                      onOpenRelationMap: onOpenRelationMap,
                    ),
                    const SizedBox(height: 14),
                    _QuestionCta(onStartQuestion: onStartQuestion),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.bubble_chart_rounded, color: _UMapColors.cyan, size: 24),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'U-Map',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _RadarCard extends StatelessWidget {
  const _RadarCard({required this.axes, this.onShare});

  final List<_RadarAxis> axes;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'FI-YOU가 정리한 User 님의 현재 흐름',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FiYouLiquidIconButton(
                icon: const Icon(Icons.ios_share_rounded),
                label: '공유',
                onPressed: onShare,
                size: 36,
                radius: 18,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 270,
            width: double.infinity,
            child: CustomPaint(painter: _UMapRadarPainter(axes)),
          ),
          const SizedBox(height: 16),
          const _InsightBox(),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Update : 2026.06.20',
              style: TextStyle(
                color: _UMapColors.textMuted,
                fontSize: 11.5,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightBox extends StatelessWidget {
  const _InsightBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: FiYouGlass.smallGlassV5(
        radius: FiYouGlass.glassRadiusSmall,
        borderColor: _UMapColors.gold,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UMapSparkIcon(color: _UMapColors.gold, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '최근 기록에서는 선택 기준과 관계 반응 쪽 단서가 조금 더 또렷하게 모이고 있어요. 아직 확정된 해석은 아니지만, 지금의 흐름을 살펴볼 수 있는 지도예요.',
              style: TextStyle(
                color: _UMapColors.textSoft,
                fontSize: 12.1,
                height: 1.38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisSummaryBox extends StatelessWidget {
  const _AxisSummaryBox({required this.axes, this.onOpenReport});

  final List<_AxisSummary> axes;
  final VoidCallback? onOpenReport;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '흐름 노드',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: axes.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.94,
            ),
            itemBuilder: (context, index) =>
                _AxisSummaryTile(axis: axes[index]),
          ),
          const SizedBox(height: 12),
          _PremiumActionTile(
            title: '상세 리포트',
            subtitle: 'FI-YOU가 쌓은 기록을 바탕으로 현재 흐름을 더 넓게 정리해요.',
            borderColor: _UMapColors.gold,
            showLeadingIcon: false,
            showChevron: true,
            onTap: onOpenReport,
          ),
        ],
      ),
    );
  }
}

class _AxisSummaryTile extends StatelessWidget {
  const _AxisSummaryTile({required this.axis});

  final _AxisSummary axis;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAxisSheet(context, axis),
        borderRadius: BorderRadius.circular(FiYouGlass.glassRadiusSmall),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 7),
          decoration: FiYouGlass.smallGlassV5(
            radius: FiYouGlass.glassRadiusSmall,
            borderColor: axis.color,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FiYouIconTile(
                color: axis.color,
                size: FiYouControlTokens.iconTileSmall,
                radius: 12,
                child: Icon(
                  axis.icon,
                  color: axis.color,
                  size: FiYouControlTokens.iconTileSmallIcon,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                axis.shortLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.2,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumExtensionSection extends StatelessWidget {
  const _PremiumExtensionSection({
    this.onOpenGrowthMap,
    this.onOpenRelationMap,
  });

  final VoidCallback? onOpenGrowthMap;
  final VoidCallback? onOpenRelationMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PremiumActionTile(
          title: 'Growth Map',
          subtitle: '성장 흐름의 단서를 조금 더 깊게 열어봐요.',
          starCost: 30,
          showLeadingIcon: false,
          onTap: onOpenGrowthMap,
        ),
        const SizedBox(height: 10),
        _PremiumActionTile(
          title: 'Relation Map',
          subtitle: '관계 안에서 반복되는 흐름의 단서를 살펴봐요.',
          starCost: 30,
          showLeadingIcon: false,
          onTap: onOpenRelationMap,
        ),
      ],
    );
  }
}

class _PremiumActionTile extends StatelessWidget {
  const _PremiumActionTile({
    required this.title,
    required this.subtitle,
    this.starCost,
    this.borderColor,
    this.showLeadingIcon = true,
    this.showChevron = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final int? starCost;
  final Color? borderColor;
  final bool showLeadingIcon;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FiYouGlass.glassRadiusSmall),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: _liquidGlassDecoration(
            radius: FiYouGlass.glassRadiusSmall,
            borderColor: borderColor,
          ),
          child: Row(
            children: [
              if (showLeadingIcon) ...[
                const Icon(
                  Icons.star_rounded,
                  color: _UMapColors.gold,
                  size: 22,
                ),
                const SizedBox(width: 11),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.2,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _UMapColors.textMuted,
                        fontSize: 12.4,
                        height: 1.32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (starCost != null) ...[
                const SizedBox(width: 12),
                _StarCostPill(cost: starCost!),
              ],
              if (showChevron) ...[
                const SizedBox(width: 12),
                const FiYouChevronButton(
                  color: _UMapColors.gold,
                  label: 'open',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StarCostPill extends StatelessWidget {
  const _StarCostPill({required this.cost});

  final int cost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: FiYouGlass.smallGlassV5(
        radius: 999,
        borderColor: _UMapColors.gold,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: _UMapColors.gold, size: 13),
          const SizedBox(width: 4),
          Text(
            '$cost Star',
            style: const TextStyle(
              color: _UMapColors.gold,
              fontSize: 12.4,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCta extends StatelessWidget {
  const _QuestionCta({this.onStartQuestion});

  final VoidCallback? onStartQuestion;

  @override
  Widget build(BuildContext context) {
    return FiYouLiquidButton(
      label: '질문 시작하기',
      icon: const UMapSparkIcon(color: Colors.white, size: 18),
      onPressed: onStartQuestion,
      height: FiYouControlTokens.buttonRegularHeight,
      fontSize: FiYouControlTokens.buttonRegularFont,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onStartQuestion});

  final VoidCallback? onStartQuestion;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '단서가 부족해요.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '질문과 기록이 조금 더 쌓이면 FI-YOU가 흐름 지도를 더 선명하게 연결해줄게요.',
            style: TextStyle(
              color: _UMapColors.textSoft,
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _QuestionCta(onStartQuestion: onStartQuestion),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: padding ?? const EdgeInsets.all(18),
      borderColor: _UMapColors.radarStroke,
      child: child,
    );
  }
}

class UMapSparkIcon extends StatelessWidget {
  const UMapSparkIcon({required this.color, required this.size, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.auto_awesome_rounded, color: color, size: size);
  }
}

class _UMapRadarPainter extends CustomPainter {
  const _UMapRadarPainter(this.axes);

  final List<_RadarAxis> axes;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 8);
    final radius = math.min(size.width, size.height) * 0.34;
    final dataRadius = radius * 0.84;
    const steps = 5;

    for (var step = 1; step <= steps; step++) {
      final r = radius * step / steps;
      final path = Path();
      for (var i = 0; i < axes.length; i++) {
        final angle = -math.pi / 2 + i * math.pi * 2 / axes.length;
        final point = Offset(
          center.dx + math.cos(angle) * r,
          center.dy + math.sin(angle) * r,
        );
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
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = _UMapColors.radarStroke.withValues(alpha: 0.072),
      );
    }

    final axisEnds = <Offset>[];
    final galaxyPath = Path();
    for (var i = 0; i < axes.length; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / axes.length;
      final axisEnd = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      axisEnds.add(axisEnd);
      if (i == 0) {
        galaxyPath.moveTo(axisEnd.dx, axisEnd.dy);
      } else {
        galaxyPath.lineTo(axisEnd.dx, axisEnd.dy);
      }
    }
    galaxyPath.close();
    final galaxyShaderRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawPath(
      galaxyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round
        ..shader = SweepGradient(
          colors: [
            _UMapColors.cyan.withValues(alpha: 0.048),
            Colors.white.withValues(alpha: 0.108),
            _UMapColors.primarySoft.withValues(alpha: 0.072),
            _UMapColors.cyan.withValues(alpha: 0.048),
          ],
        ).createShader(galaxyShaderRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.8),
    );
    canvas.drawPath(
      galaxyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85
        ..strokeJoin = StrokeJoin.round
        ..shader = SweepGradient(
          colors: [
            Colors.white.withValues(alpha: 0.096),
            _UMapColors.cyan.withValues(alpha: 0.12),
            _UMapColors.primarySoft.withValues(alpha: 0.108),
            Colors.white.withValues(alpha: 0.096),
          ],
        ).createShader(galaxyShaderRect),
    );
    for (var i = 0; i < axisEnds.length; i++) {
      final edgeStart = axisEnds[i];
      final edgeEnd = axisEnds[(i + 1) % axisEnds.length];
      final dust = Offset.lerp(
        edgeStart,
        edgeEnd,
        0.46 + (i.isEven ? 0.08 : -0.06),
      )!;
      canvas.drawCircle(
        dust,
        i.isEven ? 0.95 : 0.7,
        Paint()..color = Colors.white.withValues(alpha: 0.28),
      );
    }

    final dataPath = Path();
    final points = <Offset>[];
    for (var i = 0; i < axes.length; i++) {
      final axis = axes[i];
      final angle = -math.pi / 2 + i * math.pi * 2 / axes.length;
      final point = Offset(
        center.dx + math.cos(angle) * dataRadius * axis.value / 100,
        center.dy + math.sin(angle) * dataRadius * axis.value / 100,
      );
      points.add(point);
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    canvas.drawPath(
      dataPath,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _UMapColors.primary.withValues(alpha: 0.36),
            _UMapColors.cyan.withValues(alpha: 0.12),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeJoin = StrokeJoin.round
        ..color = _UMapColors.primarySoft.withValues(alpha: 0.6),
    );

    const coreScale = 0.7;
    canvas.drawCircle(
      center,
      11 * coreScale,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _UMapColors.primarySoft.withValues(alpha: 0.95),
            _UMapColors.primary.withValues(alpha: 0.18),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 16 * coreScale)),
    );
    _drawSpark(
      canvas,
      center,
      9.5 * coreScale,
      Colors.white.withValues(alpha: 0.92),
    );

    for (var i = 0; i < axes.length; i++) {
      final axis = axes[i];
      final angle = -math.pi / 2 + i * math.pi * 2 / axes.length;
      final axisEnd = axisEnds[i];
      canvas.drawLine(
        center,
        axisEnd,
        Paint()
          ..color = _UMapColors.radarStroke.withValues(alpha: 0.06)
          ..strokeWidth = 1,
      );

      final point = axisEnd;
      canvas.drawCircle(
        point,
        4.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.05
          ..color = axis.color.withValues(alpha: 0.76),
      );
      canvas.drawCircle(
        point,
        2.45,
        Paint()..color = axis.color.withValues(alpha: 0.32),
      );

      final labelRadius = radius + (math.sin(angle) > 0.9 ? 25 : 33);
      final label = Offset(
        center.dx + math.cos(angle) * labelRadius,
        center.dy + math.sin(angle) * labelRadius,
      );
      _drawText(
        canvas,
        label,
        '${axis.label}\n${axis.value.round()}',
        axis.color,
      );
    }
  }

  void _drawText(Canvas canvas, Offset anchor, String text, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10.8,
          height: 1.12,
          fontWeight: FontWeight.w900,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 58);

    final dx = anchor.dx - painter.width / 2;
    final dy = anchor.dy - painter.height / 2;
    painter.paint(canvas, Offset(dx, dy));
  }

  void _drawSpark(Canvas canvas, Offset center, double size, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(
        center.dx + size * 0.24,
        center.dy - size * 0.24,
        center.dx + size,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + size * 0.24,
        center.dy + size * 0.24,
        center.dx,
        center.dy + size,
      )
      ..quadraticBezierTo(
        center.dx - size * 0.24,
        center.dy + size * 0.24,
        center.dx - size,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - size * 0.24,
        center.dy - size * 0.24,
        center.dx,
        center.dy - size,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _UMapRadarPainter oldDelegate) =>
      oldDelegate.axes != axes;
}

void _showAxisSheet(BuildContext context, _AxisSummary axis) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _AxisSheet(axis: axis),
  );
}

class _AxisSheet extends StatelessWidget {
  const _AxisSheet({required this.axis});

  final _AxisSummary axis;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: _GlassPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(axis.icon, color: axis.color, size: 24),
                const SizedBox(width: 10),
                Text(
                  axis.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              axis.description,
              style: const TextStyle(
                color: _UMapColors.textSoft,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '최근 기록에서 보인 단서',
              style: TextStyle(
                color: _UMapColors.cyan,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              axis.recentClue,
              style: const TextStyle(
                color: _UMapColors.textSoft,
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '아직 확정된 해석은 아니에요.',
              style: TextStyle(
                color: _UMapColors.textMuted,
                fontSize: 12.8,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarAxis {
  const _RadarAxis(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}

class _AxisSummary {
  const _AxisSummary({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.color,
    required this.description,
    required this.recentClue,
  });

  final String label;
  final String shortLabel;
  final IconData icon;
  final Color color;
  final String description;
  final String recentClue;
}

const _axes = [
  _RadarAxis('관계', 82, Color(0xFF7DD3FC)),
  _RadarAxis('이해', 78, Color(0xFF6EE7B7)),
  _RadarAxis('감정', 68, Color(0xFFC4B5FD)),
  _RadarAxis('회복', 74, Color(0xFFFB7185)),
  _RadarAxis('선택', 81, Color(0xFFF7C948)),
  _RadarAxis('몰입', 76, Color(0xFF60A5FA)),
  _RadarAxis('갈등', 59, Color(0xFFF87171)),
  _RadarAxis('표현', 72, Color(0xFF8B5CF6)),
];

const _axisSummaries = [
  _AxisSummary(
    label: '관계 반응',
    shortLabel: '관계',
    icon: Icons.people_alt_rounded,
    color: Color(0xFF7DD3FC),
    description: '관계 안에서 연결감, 거리감, 반응 방식이 어떻게 이어지는지 기록으로 살펴보는 흐름이에요.',
    recentClue: '최근 기록에서는 대화 직후 감정 변화를 살피고 다시 균형을 찾으려는 단서가 보여요.',
  ),
  _AxisSummary(
    label: '이해 흐름',
    shortLabel: '이해',
    icon: Icons.hub_rounded,
    color: Color(0xFF6EE7B7),
    description: '질문과 기록 속에서 생각이 어떤 순서로 정리되는지 살펴보는 흐름이에요.',
    recentClue: '최근에는 이유를 먼저 확인하고 다음 행동을 고르려는 단서가 반복되어 보여요.',
  ),
  _AxisSummary(
    label: '감정 신호',
    shortLabel: '감정',
    icon: Icons.water_drop_rounded,
    color: Color(0xFFC4B5FD),
    description: '감정이 커질 때 몸과 생각에 남는 작은 변화를 기록으로 살펴보는 흐름이에요.',
    recentClue: '불편함을 바로 결론으로 보기보다 이름을 붙여보려는 흐름이 보여요.',
  ),
  _AxisSummary(
    label: '회복 패턴',
    shortLabel: '회복',
    icon: Icons.spa_rounded,
    color: Color(0xFFFB7185),
    description: '긴장이나 피로 뒤에 다시 정리되는 방식과 필요한 환경을 살펴보는 흐름이에요.',
    recentClue: '바로 반응하기보다 잠깐 거리를 두는 선택이 반복되어 보여요.',
  ),
  _AxisSummary(
    label: '선택 기준',
    shortLabel: '선택',
    icon: Icons.tune_rounded,
    color: Color(0xFFF7C948),
    description: '선택 앞에서 어떤 기준과 우선순위를 확인하는지 기록으로 모아보는 흐름이에요.',
    recentClue: '빠른 결정보다 이유가 충분히 정리되는 시간을 기다리는 기록이 보여요.',
  ),
  _AxisSummary(
    label: '몰입 방향',
    shortLabel: '몰입',
    icon: Icons.center_focus_strong_rounded,
    color: Color(0xFF93C5FD),
    description: '어떤 환경과 조건에서 몰입이 자연스럽게 이어지는지 살펴보는 흐름이에요.',
    recentClue: '작은 목표를 먼저 세운 뒤 다음 행동으로 이어가려는 단서가 있어요.',
  ),
  _AxisSummary(
    label: '갈등 반응',
    shortLabel: '갈등',
    icon: Icons.compare_arrows_rounded,
    color: Color(0xFFFCA5A5),
    description: '갈등이나 불편함이 커질 때 먼저 선택하는 반응과 정리 방식을 살펴보는 흐름이에요.',
    recentClue: '감정에 따라 바로 말하기보다 문장을 고르는 시간이 필요하다는 단서가 있어요.',
  ),
  _AxisSummary(
    label: '표현 확장',
    shortLabel: '표현',
    icon: Icons.north_east_rounded,
    color: Color(0xFF8B5CF6),
    description: '말, 글, 선택으로 내면의 흐름이 어떻게 밖으로 이어지는지 살펴보는 흐름이에요.',
    recentClue: '지금의 마음을 문장으로 정리한 뒤 다음 행동을 선명하게 만들려는 기록이 보여요.',
  ),
];

abstract final class _UMapColors {
  static const textSoft = Color(0xFFB7C0D7);
  static const textMuted = Color(0xFF7F8AA6);
  static const primary = Color(0xFF8B5CF6);
  static const primarySoft = Color(0xFFC4B5FD);
  static const radarStroke = Color(0xFFA8A0D8);
  static const cyan = Color(0xFF7DD3FC);
  static const gold = Color(0xFFF7C948);
}
