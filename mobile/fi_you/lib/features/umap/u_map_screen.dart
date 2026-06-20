import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

typedef UMapScreen = FiYouUMapScreen;

/// Full U-Map tab screen used by the app shell.
class FiYouUMapScreen extends StatelessWidget {
  const FiYouUMapScreen({
    super.key,
    this.isEmpty = false,
    this.onStartQuestion,
    this.onShare,
    this.onOpenGrowthMap,
    this.onOpenRelationMap,
    this.onOpenReport,
    this.bottomPadding = 132,
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
    final axes = _sampleAxes;

    return Scaffold(
      backgroundColor: _UMapColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, bottomPadding),
              sliver: SliverList.list(
                children: [
                  const _ScreenHeader(),
                  const SizedBox(height: 18),
                  if (isEmpty)
                    _UMapEmptyState(onStartQuestion: onStartQuestion)
                  else ...[
                    _OverviewMapCard(axes: axes, onShare: onShare),
                    const SizedBox(height: 16),
                    _AxisSummaryBox(axes: axes),
                    const SizedBox(height: 16),
                    _PremiumExtensionSection(
                      onOpenGrowthMap: onOpenGrowthMap,
                      onOpenRelationMap: onOpenRelationMap,
                      onOpenReport: onOpenReport,
                    ),
                    const SizedBox(height: 16),
                    _QuestionCta(onStartQuestion: onStartQuestion),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _HeaderIcon(),
            SizedBox(width: 10),
            Text(
              'U-Map',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                height: 1.16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          '최근 질문과 기록에서 보인 단서를 8개 축으로 정리한 기록 기반 지도예요.',
          style: TextStyle(
            color: _UMapColors.textSoft,
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _UMapColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _UMapColors.primarySoft.withValues(alpha: 0.26),
          ),
        ),
        child: const Icon(
          Icons.bubble_chart_outlined,
          color: _UMapColors.primarySoft,
          size: 19,
        ),
      ),
    );
  }
}

class _OverviewMapCard extends StatelessWidget {
  const _OverviewMapCard({required this.axes, this.onShare});

  final List<_UMapAxis> axes;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return UMapRadarCard(axes: _radarAxes, onShare: onShare);
  }
}

/// Lightweight axis data shared by the U-Map tab and Home preview cards.
class UMapAxis {
  final String label;
  final double value;
  final Color color;

  const UMapAxis({
    required this.label,
    required this.value,
    required this.color,
  });
}

const _radarAxes = [
  UMapAxis(label: '\uC5D0\uB108\uC9C0', value: 78, color: Color(0xFFA78BFA)),
  UMapAxis(label: '\uD68C\uBCF5', value: 72, color: Color(0xFF7DD3FC)),
  UMapAxis(label: '\uAD00\uACC4', value: 65, color: Color(0xFFC4B5FD)),
  UMapAxis(label: '\uAC10\uC815', value: 58, color: Color(0xFFFB7185)),
  UMapAxis(label: '\uC120\uD0DD', value: 80, color: Color(0xFFF7C948)),
  UMapAxis(label: '\uBAB0\uC785', value: 70, color: Color(0xFF60A5FA)),
  UMapAxis(label: '\uAC08\uB4F1', value: 40, color: Color(0xFFF87171)),
  UMapAxis(label: '\uC131\uC7A5', value: 82, color: Color(0xFF8B5CF6)),
];

/// Living Map card that Home can reuse for a compact U-Map preview.
class UMapRadarCard extends StatefulWidget {
  const UMapRadarCard({required this.axes, this.onShare, super.key});

  final List<UMapAxis> axes;
  final VoidCallback? onShare;

  @override
  State<UMapRadarCard> createState() => _UMapRadarCardState();
}

class _UMapRadarCardState extends State<UMapRadarCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, drawProgress, child) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF060816),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.28),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0E1325).withValues(alpha: 0.96),
                        const Color(0xFF060816),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.22),
                        blurRadius: 36,
                        offset: const Offset(0, 18),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _UMapLivingHeader(onShare: widget.onShare),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 560;
                          final chart = UMapRadarChart(
                            axes: widget.axes,
                            drawProgress: drawProgress,
                            pulse: _pulseController.value,
                          );
                          if (!wide) return chart;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 176,
                                child: _UMapGuideBox(),
                              ),
                              const SizedBox(width: 18),
                              Expanded(child: chart),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      UMapInsightBox(axes: widget.axes),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: _UMapUpdateStamp(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _UMapUpdateStamp extends StatelessWidget {
  const _UMapUpdateStamp();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Update : 2026.06.20',
      style: TextStyle(
        color: _UMapColors.textMuted.withValues(alpha: 0.82),
        fontSize: 10.8,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _UMapLivingHeader extends StatelessWidget {
  const _UMapLivingHeader({this.onShare});

  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'U-Map',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 22,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '\uB2F9\uC2E0\uB9CC\uC758 \uC5F0\uACB0 \uC9C0\uB3C4\uB97C \uD1B5\uD574\n\uB098\uB97C \uC774\uB8E8\uB294 \uBAA8\uB4E0 \uAC83\uC744 \uD55C\uB208\uC5D0.',
                style: TextStyle(
                  color: Color(0xFFB7C0D7),
                  fontSize: 13.2,
                  height: 1.42,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          label: 'U-Map 공유',
          button: true,
          child: IconButton(
            onPressed: onShare,
            icon: const Icon(Icons.ios_share_rounded),
            color: const Color(0xFFFFFFFF),
            iconSize: 22,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              fixedSize: const Size(50, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: const Color(0xFFA78BFA).withValues(alpha: 0.24),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UMapGuideBox extends StatelessWidget {
  const _UMapGuideBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF060816).withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFA78BFA).withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'U-Map Guide',
            style: TextStyle(
              color: Color(0xFFA78BFA),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _GuideRow(
            color: const Color(0xFFA78BFA),
            label: '\uD604\uC7AC \uB098\uC758 \uD750\uB984',
            isLine: true,
          ),
          const SizedBox(height: 12),
          _GuideRow(
            color: const Color(0xFFB7C0D7).withValues(alpha: 0.72),
            label: '\uC804\uCCB4 \uAC00\uB2A5\uC131',
            isDotted: true,
          ),
          const SizedBox(height: 12),
          const _GuideRow(
            color: Color(0xFF8B5CF6),
            label: '\uCD5C\uADFC \uBCC0\uD654 \uC601\uC5ED',
            isGlow: true,
          ),
        ],
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({
    required this.color,
    required this.label,
    this.isLine = false,
    this.isDotted = false,
    this.isGlow = false,
  });

  final Color color;
  final String label;
  final bool isLine;
  final bool isDotted;
  final bool isGlow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          height: 14,
          child: CustomPaint(
            painter: _GuideMarkPainter(
              color: color,
              isLine: isLine,
              isDotted: isDotted,
              isGlow: isGlow,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB7C0D7),
              fontSize: 11.5,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideMarkPainter extends CustomPainter {
  const _GuideMarkPainter({
    required this.color,
    required this.isLine,
    required this.isDotted,
    required this.isGlow,
  });

  final Color color;
  final bool isLine;
  final bool isDotted;
  final bool isGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    if (isDotted) {
      for (var x = 2.0; x < size.width; x += 7) {
        canvas.drawCircle(Offset(x, size.height / 2), 1.2, paint);
      }
      return;
    }
    if (isGlow) {
      canvas.drawCircle(
        Offset(size.width * 0.28, size.height / 2),
        7,
        Paint()
          ..color = color.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(Offset(size.width * 0.28, size.height / 2), 4, paint);
      return;
    }
    canvas.drawLine(
      Offset.zero.translate(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GuideMarkPainter oldDelegate) => false;
}

/// Animated radar visualization for the Living Map.
class UMapRadarChart extends StatelessWidget {
  const UMapRadarChart({
    required this.axes,
    required this.drawProgress,
    required this.pulse,
    super.key,
  });

  final List<UMapAxis> axes;
  final double drawProgress;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = (constraints.maxWidth / 1.42).clamp(260.0, 340.0);
        return SizedBox(
          width: double.infinity,
          height: height,
          child: Semantics(
            label: '8개 축 기록 기반 U-Map 그래프',
            image: true,
            child: CustomPaint(
              painter: UMapRadarChartPainter(
                axes: axes,
                drawProgress: drawProgress,
                pulse: pulse,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Short reading of the current map, phrased as clues rather than diagnosis.
class UMapInsightBox extends StatelessWidget {
  const UMapInsightBox({required this.axes, super.key});

  final List<UMapAxis> axes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF060816).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFA78BFA).withValues(alpha: 0.28),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UMapSparkIcon(color: Color(0xFFA78BFA), size: 22),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FI-YOU가 이해한 User 님!',
                  style: TextStyle(
                    color: Color(0xFFA78BFA),
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '선택 기준과 성장 방향의 단서가 조금 더 선명하게 쌓이고 있어요. 아직 확정된 해석은 아니지만, 최근 기록은 작게 시도하고 돌아보는 흐름을 자주 보여줘요.',
                  style: TextStyle(
                    color: Color(0xFFB7C0D7),
                    fontSize: 12.4,
                    height: 1.48,
                    fontWeight: FontWeight.w600,
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

/// Painter used by [UMapRadarChart].
class UMapRadarChartPainter extends CustomPainter {
  UMapRadarChartPainter({
    required this.axes,
    required this.drawProgress,
    required this.pulse,
  });

  final List<UMapAxis> axes;
  final double drawProgress;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    if (axes.isEmpty) return;

    final orderedAxes = _orderedAxes;
    final center = Offset(size.width / 2, size.height * 0.48);
    final radiusX = size.width * 0.31;
    final radiusY = radiusX / 1.62;

    _drawParticleLayer(canvas, center, radiusX, radiusY);
    _drawEllipseGrid(canvas, center, radiusX, radiusY, orderedAxes);
    _drawDataArea(canvas, center, radiusX, radiusY, orderedAxes);
    _drawCenterCore(canvas, center);
    for (final axis in orderedAxes) {
      _drawSignalNode(canvas, center, radiusX, radiusY, axis, size);
    }
  }

  List<UMapAxis> get _orderedAxes {
    const order = ['성장', '에너지', '회복', '관계', '감정', '선택', '몰입', '갈등'];
    return [
      for (final label in order)
        axes.firstWhere(
          (axis) => axis.label == label,
          orElse: () => axes.first,
        ),
    ];
  }

  void _drawParticleLayer(
    Canvas canvas,
    Offset center,
    double radiusX,
    double radiusY,
  ) {
    final particles =
        <({double angle, double distance, double size, Color color})>[
          (
            angle: -2.2,
            distance: 0.86,
            size: 0.9,
            color: const Color(0xFF8B5CF6),
          ),
          (
            angle: -1.65,
            distance: 0.92,
            size: 1.15,
            color: const Color(0xFFA78BFA),
          ),
          (
            angle: -0.82,
            distance: 0.9,
            size: 1.05,
            color: const Color(0xFF7DD3FC),
          ),
          (
            angle: 0.04,
            distance: 0.82,
            size: 0.8,
            color: const Color(0xFFC4B5FD),
          ),
          (
            angle: 1.52,
            distance: 0.78,
            size: 1.05,
            color: const Color(0xFFF7C948),
          ),
          (
            angle: 2.42,
            distance: 0.86,
            size: 0.9,
            color: const Color(0xFF60A5FA),
          ),
        ];
    for (final p in particles) {
      final point = _ellipsePoint(
        center,
        radiusX,
        radiusY,
        p.angle,
        p.distance,
      );
      canvas.drawCircle(
        point,
        p.size * (1 + pulse * 0.18),
        Paint()..color = p.color.withValues(alpha: 0.18),
      );
    }
  }

  void _drawEllipseGrid(
    Canvas canvas,
    Offset center,
    double radiusX,
    double radiusY,
    List<UMapAxis> orderedAxes,
  ) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.72;
    for (var step = 1; step <= 5; step++) {
      final ratio = step / 5;
      final rect = Rect.fromCenter(
        center: center,
        width: radiusX * 2 * ratio,
        height: radiusY * 2 * ratio,
      );
      canvas.drawOval(
        rect,
        gridPaint
          ..color = Colors.white.withValues(alpha: step == 5 ? 0.085 : 0.052),
      );
    }

    final axisPaint = Paint()
      ..color = const Color(0xFFC4B5FD).withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.68
      ..strokeCap = StrokeCap.round;
    for (final axis in orderedAxes) {
      final point = _ellipsePoint(
        center,
        radiusX,
        radiusY,
        _angleFor(axis.label),
        1,
      );
      canvas.drawLine(center, point, axisPaint);
    }
  }

  void _drawDataArea(
    Canvas canvas,
    Offset center,
    double radiusX,
    double radiusY,
    List<UMapAxis> orderedAxes,
  ) {
    final path = Path();
    for (var i = 0; i < orderedAxes.length; i++) {
      final axis = orderedAxes[i];
      final ratio = axis.value.clamp(0, 100) / 100 * drawProgress;
      final point = _ellipsePoint(
        center,
        radiusX,
        radiusY,
        _angleFor(axis.label),
        ratio,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final bounds = Rect.fromCenter(
      center: center,
      width: radiusX * 2,
      height: radiusY * 2,
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.12, -0.18),
          radius: 0.95,
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.28 * drawProgress),
            const Color(0xFF8B5CF6).withValues(alpha: 0.13 * drawProgress),
            const Color(0xFF8B5CF6).withValues(alpha: 0.06 * drawProgress),
          ],
        ).createShader(bounds)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFC4B5FD).withValues(alpha: 0.88 * drawProgress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.25
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawCenterCore(Canvas canvas, Offset center) {
    final pulseScale = 1 + pulse * 0.08;
    canvas.drawCircle(
      center,
      20 * pulseScale,
      Paint()
        ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawCircle(
      center,
      8.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            const Color(0xFFA78BFA).withValues(alpha: 0.72),
            const Color(0xFF8B5CF6).withValues(alpha: 0.28),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 12)),
    );
    _drawSpark(canvas, center, 7, Colors.white.withValues(alpha: 0.88));
  }

  void _drawSignalNode(
    Canvas canvas,
    Offset center,
    double radiusX,
    double radiusY,
    UMapAxis axis,
    Size size,
  ) {
    final ratio = axis.value.clamp(0, 100) / 100;
    final animatedRatio = ratio * drawProgress;
    final angle = _angleFor(axis.label);
    final node = _ellipsePoint(center, radiusX, radiusY, angle, animatedRatio);
    final edge = _ellipsePoint(center, radiusX, radiusY, angle, 1.02);
    final labelPoint = _ellipsePoint(center, radiusX, radiusY, angle, 1.18);
    final nodeFade = ((drawProgress - 0.3) / 0.3).clamp(0.0, 1.0);
    final glowFade = ((drawProgress - 0.5) / 0.3).clamp(0.0, 1.0);
    final glowStrength = _glowStrength(axis) * glowFade;

    if (glowStrength > 0) {
      canvas.drawCircle(
        node,
        7 + glowStrength * 12,
        Paint()
          ..color = axis.color.withValues(alpha: 0.12 * glowStrength)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            5 + glowStrength * 10,
          ),
      );
      canvas.drawLine(
        node,
        edge,
        Paint()
          ..color = axis.color.withValues(alpha: 0.16 * glowStrength)
          ..strokeWidth = 0.9
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawCircle(
      node,
      6.2,
      Paint()
        ..color = axis.color.withValues(alpha: 0.18 * nodeFade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.35,
    );
    canvas.drawCircle(
      node,
      4.2,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.98 * nodeFade),
            axis.color.withValues(alpha: nodeFade),
          ],
        ).createShader(Rect.fromCircle(center: node, radius: 5)),
    );

    if (glowStrength > 0.34) {
      final spark = _ellipsePoint(center, radiusX, radiusY, angle - 0.04, 1.1);
      _drawSpark(canvas, spark, 3.8, axis.color.withValues(alpha: 0.74));
    }

    final painter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${axis.label}\n',
            style: TextStyle(
              color: axis.color.withValues(alpha: nodeFade),
              fontSize: 10.5,
              height: 1.08,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: axis.value.round().toString(),
            style: TextStyle(
              color: axis.color.withValues(alpha: nodeFade),
              fontSize: 15,
              height: 1.04,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      textAlign: _labelAlign(angle),
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: 62);
    final dx = (labelPoint.dx - painter.width / 2).clamp(
      4.0,
      size.width - painter.width - 4,
    );
    final dy = (labelPoint.dy - painter.height / 2).clamp(
      4.0,
      size.height - painter.height - 4,
    );
    painter.paint(canvas, Offset(dx, dy));
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

  Offset _ellipsePoint(
    Offset center,
    double radiusX,
    double radiusY,
    double angle,
    double ratio,
  ) {
    return Offset(
      center.dx + math.cos(angle) * radiusX * ratio,
      center.dy + math.sin(angle) * radiusY * ratio,
    );
  }

  double _angleFor(String label) {
    return switch (label) {
      '성장' => -2.28,
      '에너지' => -math.pi / 2,
      '회복' => -0.86,
      '관계' => 0,
      '감정' => 0.86,
      '선택' => math.pi / 2,
      '몰입' => 2.28,
      '갈등' => math.pi,
      _ => -math.pi / 2,
    };
  }

  double _glowStrength(UMapAxis axis) {
    final base = ((axis.value - 42) / 46).clamp(0.04, 0.88);
    return switch (axis.label) {
      '성장' || '선택' || '회복' => math.max(base, 0.72),
      '갈등' => math.min(base, 0.14),
      _ => base,
    };
  }

  TextAlign _labelAlign(double angle) {
    final x = math.cos(angle);
    if (x > 0.38) return TextAlign.left;
    if (x < -0.38) return TextAlign.right;
    return TextAlign.center;
  }

  @override
  bool shouldRepaint(covariant UMapRadarChartPainter oldDelegate) {
    return oldDelegate.axes != axes ||
        oldDelegate.drawProgress != drawProgress ||
        oldDelegate.pulse != pulse;
  }
}

class _AxisSummaryBox extends StatelessWidget {
  const _AxisSummaryBox({required this.axes});

  final List<_UMapAxis> axes;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: _UMapColors.surfaceDeep,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              '8개 축별 요약',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                height: 1.25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: axes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.04,
              ),
              itemBuilder: (context, index) {
                final axis = axes[index];
                return _AxisSummaryButton(axis: axis);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisSummaryButton extends StatelessWidget {
  const _AxisSummaryButton({required this.axis});

  final _UMapAxis axis;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAxisSheet(context, axis),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: axis.color.withValues(alpha: 0.32)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                axis.color.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.045),
                Colors.black.withValues(alpha: 0.06),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: axis.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: axis.color.withValues(alpha: 0.42),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                axis.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _UMapColors.textSoft,
                  fontSize: 10.5,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _AxisSummaryRow extends StatelessWidget {
  const _AxisSummaryRow({required this.axis});

  final _UMapAxis axis;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAxisSheet(context, axis),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
          child: Row(
            children: [
              _AxisBadge(axis: axis),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            axis.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              height: 1.25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${axis.clueCount}개 단서',
                          style: const TextStyle(
                            color: _UMapColors.cyan,
                            fontSize: 11.5,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      axis.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _UMapColors.textSoft,
                        fontSize: 12.5,
                        height: 1.38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ContributionBar(axis: axis),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '>',
                style: TextStyle(
                  color: _UMapColors.textMuted,
                  fontSize: 20,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContributionBar extends StatelessWidget {
  const _ContributionBar({required this.axis});

  final _UMapAxis axis;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 7,
        child: Stack(
          children: [
            Container(color: Colors.white.withValues(alpha: 0.06)),
            FractionallySizedBox(
              widthFactor: axis.strength,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [axis.color, _UMapColors.cyan],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumExtensionSection extends StatelessWidget {
  const _PremiumExtensionSection({
    this.onOpenGrowthMap,
    this.onOpenRelationMap,
    this.onOpenReport,
  });

  final VoidCallback? onOpenGrowthMap;
  final VoidCallback? onOpenRelationMap;
  final VoidCallback? onOpenReport;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PremiumCard(
          icon: Icons.auto_graph_rounded,
          title: 'Growth Map',
          body: '성장 방향에 연결된 기록 단서를 더 깊게 펼쳐봐요.',
          stars: 18,
          onTap: onOpenGrowthMap,
        ),
        const SizedBox(height: 10),
        _PremiumCard(
          icon: Icons.diversity_1_rounded,
          title: 'Relation Map',
          body: '관계 안에서 보인 거리감과 연결감을 따로 정리해요.',
          stars: 18,
          onTap: onOpenRelationMap,
        ),
        const SizedBox(height: 10),
        _PremiumCard(
          icon: Icons.description_rounded,
          title: '상세 리포트',
          body: '현재 U-Map의 단서 흐름을 읽기 쉬운 리포트로 이어봐요.',
          stars: 30,
          onTap: onOpenReport,
        ),
      ],
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.stars,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final int stars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: _UMapColors.surfaceRaised,
      borderColor: _UMapColors.gold.withValues(alpha: 0.28),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _UMapColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _UMapColors.gold.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(icon, color: _UMapColors.gold, size: 22),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          height: 1.24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _UMapColors.textSoft,
                          fontSize: 12.5,
                          height: 1.36,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _StarCost(stars: stars),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarCost extends StatelessWidget {
  const _StarCost({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: _UMapColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _UMapColors.gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, color: _UMapColors.gold, size: 15),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              '$stars Star',
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: const TextStyle(
                color: _UMapColors.gold,
                fontSize: 11.5,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UMapEmptyState extends StatelessWidget {
  const _UMapEmptyState({this.onStartQuestion});

  final VoidCallback? onStartQuestion;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      borderColor: _UMapColors.cyan.withValues(alpha: 0.28),
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SignalIcon(icon: Icons.map_outlined, color: _UMapColors.cyan),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '단서가 부족해요.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '질문 답변이나 Diary 기록이 조금 더 쌓이면 U-Map에 흐름을 표시할 수 있어요.',
            style: TextStyle(
              color: _UMapColors.textSoft,
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          _QuestionCta(onStartQuestion: onStartQuestion),
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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onStartQuestion,
        icon: const UMapSparkIcon(color: Color(0xFF04101A), size: 19),
        label: const Text(
          '질문 시작하기',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _UMapColors.cyan,
          foregroundColor: const Color(0xFF04101A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _AxisBadge extends StatelessWidget {
  const _AxisBadge({required this.axis});

  final _UMapAxis axis;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: axis.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: axis.color.withValues(alpha: 0.28)),
      ),
      child: Icon(axis.icon, color: axis.color, size: 21),
    );
  }
}

class _SignalIcon extends StatelessWidget {
  const _SignalIcon({required this.icon, this.color = _UMapColors.primarySoft});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: icon == Icons.auto_awesome_rounded
          ? UMapSparkIcon(color: color, size: 24)
          : Icon(icon, color: color, size: 23),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = _UMapColors.surface,
    this.borderColor = _UMapColors.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.46),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor.withValues(alpha: 0.64)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.07),
                color.withValues(alpha: 0.38),
                Colors.black.withValues(alpha: 0.08),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Spark icon used for clue/recent-record affordances, not Star currency.
class UMapSparkIcon extends StatelessWidget {
  const UMapSparkIcon({required this.color, required this.size, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _UMapSparkIconPainter(color)),
    );
  }
}

class _UMapSparkIconPainter extends CustomPainter {
  const _UMapSparkIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    final center = Offset(size.width * 0.48, size.height * 0.52);
    final bright = Color.lerp(color, Colors.white, 0.55)!;
    final main = _sparkPath(center, shortest * 0.36, shortest * 0.12);
    canvas.drawPath(
      main,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shortest * 0.12),
    );
    canvas.drawPath(
      main,
      Paint()
        ..shader =
            RadialGradient(
              center: const Alignment(-0.35, -0.45),
              radius: 0.9,
              colors: [Colors.white, bright, color],
              stops: const [0.0, 0.22, 1.0],
            ).createShader(
              Rect.fromCircle(center: center, radius: shortest * 0.42),
            ),
    );
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
  bool shouldRepaint(covariant _UMapSparkIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

void _showAxisSheet(BuildContext context, _UMapAxis axis) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AxisDetailSheet(axis: axis),
  );
}

class _AxisDetailSheet extends StatelessWidget {
  const _AxisDetailSheet({required this.axis});

  final _UMapAxis axis;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.48,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: _UMapColors.modal,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _AxisBadge(axis: axis),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          axis.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${axis.clueCount}개 기록 단서가 이 축에 참고되었어요.',
                          style: const TextStyle(
                            color: _UMapColors.textMuted,
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailBlock(title: '축 설명', body: axis.description),
              const SizedBox(height: 12),
              _DetailBlock(title: 'FI-YOU가 탐구한 당신', body: axis.recentClue),
              const SizedBox(height: 12),
              _Panel(
                color: _UMapColors.surfaceDeep,
                borderColor: _UMapColors.gold.withValues(alpha: 0.24),
                child: const Text(
                  '아직 확정된 해석은 아니에요.',
                  style: TextStyle(
                    color: _UMapColors.gold,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '축별 데이터가 쌓인 흐름',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              for (final record in axis.records) _RecordTile(record: record),
            ],
          ),
        );
      },
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: _UMapColors.surfaceDeep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _UMapColors.cyan,
              fontSize: 13,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: _UMapColors.textSoft,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final _AxisRecord record;

  @override
  Widget build(BuildContext context) {
    final isQuestion = record.source == '질문';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Panel(
        color: _UMapColors.surfaceRaised,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isQuestion
                    ? _UMapColors.primarySoft.withValues(alpha: 0.14)
                    : _UMapColors.cyan.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: isQuestion
                  ? const UMapSparkIcon(
                      color: _UMapColors.primarySoft,
                      size: 17,
                    )
                  : const Icon(
                      Icons.edit_note_rounded,
                      color: _UMapColors.cyan,
                      size: 16,
                    ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.date} · ${record.source}',
                    style: const TextStyle(
                      color: _UMapColors.textMuted,
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    record.text,
                    style: const TextStyle(
                      color: _UMapColors.textSoft,
                      fontSize: 13.2,
                      height: 1.43,
                      fontWeight: FontWeight.w500,
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

class _UMapAxis {
  const _UMapAxis({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.color,
    required this.strength,
    required this.clueCount,
    required this.summary,
    required this.description,
    required this.recentClue,
    required this.records,
  });

  final String label;
  final String shortLabel;
  final IconData icon;
  final Color color;
  final double strength;
  final int clueCount;
  final String summary;
  final String description;
  final String recentClue;
  final List<_AxisRecord> records;
}

class _AxisRecord {
  const _AxisRecord({
    required this.date,
    required this.source,
    required this.text,
  });

  final String date;
  final String source;
  final String text;
}

const _sampleRecords = [
  _AxisRecord(
    date: '6월 17일',
    source: 'Diary',
    text: '일정을 정리하고 나니 다음 움직임이 조금 가벼워졌다는 기록이 있었어요.',
  ),
  _AxisRecord(
    date: '6월 18일',
    source: '질문',
    text: '바로 답을 내기보다 기준을 먼저 확인하고 싶다는 응답이 남아 있어요.',
  ),
  _AxisRecord(
    date: '6월 19일',
    source: 'Diary',
    text: '감정이 커질 때 잠깐 멈추면 다시 선택지가 보인다는 단서가 쌓였어요.',
  ),
];

const _sampleAxes = [
  _UMapAxis(
    label: '에너지 리듬',
    shortLabel: '에너지',
    icon: Icons.bolt_rounded,
    color: Color(0xFF7DD3FC),
    strength: 0.72,
    clueCount: 9,
    summary: '조용히 정리한 뒤 다시 움직이는 흐름이 자주 보여요.',
    description: '에너지가 차오르거나 소모되는 장면, 다시 움직이기 쉬운 조건을 기록으로 살피는 축이에요.',
    recentClue: '최근 기록에서는 혼자 정리하는 시간이 다음 행동을 만드는 단서로 남아 있어요.',
    records: _sampleRecords,
  ),
  _UMapAxis(
    label: '회복 방식',
    shortLabel: '회복',
    icon: Icons.spa_rounded,
    color: Color(0xFF6EE7B7),
    strength: 0.66,
    clueCount: 7,
    summary: '속도를 늦추고 감정을 정리할 때 균형을 찾는 단서가 있어요.',
    description: '긴장이나 피로 뒤에 다시 정리되는 방식과 회복에 필요한 환경을 살피는 축이에요.',
    recentClue: '바로 반응하기보다 잠깐 거리를 두는 선택이 반복해서 보여요.',
    records: _sampleRecords,
  ),
  _UMapAxis(
    label: '관계 거리',
    shortLabel: '관계',
    icon: Icons.people_alt_rounded,
    color: Color(0xFFC4B5FD),
    strength: 0.58,
    clueCount: 6,
    summary: '가까움과 여백 사이를 조심스럽게 조율하려는 흐름이 보여요.',
    description: '관계 안에서 편안한 거리감, 연결감, 여백의 필요를 기록으로 정리하는 축이에요.',
    recentClue: '상대 반응을 확인하면서도 자기 속도를 잃지 않으려는 단서가 남아 있어요.',
    records: _sampleRecords,
  ),
  _UMapAxis(
    label: '감정 신호',
    shortLabel: '감정',
    icon: Icons.water_drop_rounded,
    color: Color(0xFFFB7185),
    strength: 0.62,
    clueCount: 8,
    summary: '감정이 커지기 전에 작은 신호를 알아차리려는 기록이 쌓였어요.',
    description: '감정에 이름을 붙이고 몸과 생각에 남는 변화를 기록으로 살피는 축이에요.',
    recentClue: '불편함을 결론으로 두기보다 먼저 이름 붙여보려는 흐름이 보여요.',
    records: _sampleRecords,
  ),
  _UMapAxis(
    label: '선택 기준',
    shortLabel: '선택',
    icon: Icons.tune_rounded,
    color: Color(0xFFF7C948),
    strength: 0.76,
    clueCount: 10,
    summary: '가능한 이유와 우선순위를 확인한 뒤 선택하려는 단서가 많아요.',
    description: '선택 앞에서 어떤 기준과 우선순위를 확인하는지 기록으로 모아보는 축이에요.',
    recentClue: '빠른 결정보다 이유가 충분히 정리되는 시간을 기다리는 기록이 반복되었어요.',
    records: _sampleRecords,
  ),
  _UMapAxis(
    label: '몰입 조건',
    shortLabel: '몰입',
    icon: Icons.center_focus_strong_rounded,
    color: Color(0xFF93C5FD),
    strength: 0.54,
    clueCount: 5,
    summary: '방해가 적고 목표가 선명할 때 집중이 깊어지는 단서가 있어요.',
    description: '어떤 환경과 조건에서 몰입이 자연스럽게 이어지는지 살피는 축이에요.',
    recentClue: '작은 목표를 먼저 세운 뒤 다음 행동으로 넘어가기 쉬웠다는 기록이 있어요.',
    records: _sampleRecords,
  ),
  _UMapAxis(
    label: '갈등 반응',
    shortLabel: '갈등',
    icon: Icons.compare_arrows_rounded,
    color: Color(0xFFFCA5A5),
    strength: 0.48,
    clueCount: 4,
    summary: '충돌이 생기면 말하기 전에 상황을 정리하려는 단서가 보여요.',
    description: '갈등이나 불편함이 커질 때 먼저 선택하는 반응과 정리 방식을 살피는 축이에요.',
    recentClue: '감정이 올라올 때 바로 말하기보다 문장을 고르는 시간이 필요하다는 단서가 있어요.',
    records: _sampleRecords,
  ),
  _UMapAxis(
    label: '성장 방향',
    shortLabel: '성장',
    icon: Icons.north_east_rounded,
    color: Color(0xFF8B5CF6),
    strength: 0.69,
    clueCount: 8,
    summary: '작게 시도하고 돌아보는 방식이 다음 흐름을 만드는 단서로 보여요.',
    description: '계속 움직이게 만드는 이유, 배우고 싶은 방향, 자주 만들고 싶은 장면을 살피는 축이에요.',
    recentClue: '큰 변화보다 작게 해보고 조정하는 방식이 최근 기록에서 자주 보여요.',
    records: _sampleRecords,
  ),
];

abstract final class _UMapColors {
  static const background = Color(0xFF050714);
  static const surface = Color(0xFF0D1326);
  static const surfaceDeep = Color(0xFF0A1020);
  static const surfaceRaised = Color(0xFF10172A);
  static const modal = Color(0xFF10172A);
  static const border = Color(0xFF273556);
  static const textSoft = Color(0xFFB7C0D7);
  static const textMuted = Color(0xFF7F8AA6);
  static const primary = Color(0xFF8B5CF6);
  static const primarySoft = Color(0xFFC4B5FD);
  static const cyan = Color(0xFF7DD3FC);
  static const gold = Color(0xFFF7C948);
}
