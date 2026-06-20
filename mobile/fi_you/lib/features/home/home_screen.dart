import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'home_mock_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.data = homeMockData,
    this.onNotificationTap,
    this.onProfileTap,
    this.onStoreTap,
    this.onUMapTap,
    this.onDiaryTap,
    this.onQuestionTap,
    this.onStatusTap,
  });

  final HomeMockData data;

  /// 알림 버튼 클릭 콜백입니다.
  final VoidCallback? onNotificationTap;

  /// 프로필 버튼 클릭 콜백입니다. PM AppShell에서 My 탭 이동에 연결하면 됩니다.
  final VoidCallback? onProfileTap;

  /// Star 박스 클릭 콜백입니다. PM AppShell에서 Store 화면 이동에 연결하면 됩니다.
  final VoidCallback? onStoreTap;

  /// U-Map 카드 클릭 콜백입니다.
  final VoidCallback? onUMapTap;

  /// Diary 작성 유도 카드 클릭 콜백입니다.
  final VoidCallback? onDiaryTap;

  /// 다음 질문 카드 클릭 콜백입니다.
  final VoidCallback? onQuestionTap;

  /// 오늘의 탐구 현황 또는 오늘 발견된 단서 클릭 콜백입니다.
  final VoidCallback? onStatusTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FiYouHomeColors.backgroundBase,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1023),
              FiYouHomeColors.backgroundBase,
              Color(0xFF070A16),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 118),
                sliver: SliverList.list(
                  children: [
                    HomeHeader(data: data, onStoreTap: onStoreTap),
                    const SizedBox(height: 20),
                    GreetingSection(data: data),
                    const SizedBox(height: 15),
                    NextQuestionCard(
                      question: data.nextQuestion,
                      estimatedTime: data.estimatedQuestionTime,
                      onTap: onQuestionTap,
                    ),
                    const SizedBox(height: 14),
                    UMapCard(data: data, onTap: onUMapTap),
                    const SizedBox(height: 14),
                    DiaryPromptCard(
                      prompt: data.diaryPrompt,
                      onTap: onDiaryTap,
                    ),
                    const SizedBox(height: 14),
                    TodayClueCard(clue: data.todayClue, onTap: onStatusTap),
                    const SizedBox(height: 14),
                    ExplorationStatusCard(
                      metrics: data.activityMetrics,
                      latestUpdateLabel: data.latestUpdateLabel,
                      onTap: onStatusTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.data, this.onStoreTap});

  final HomeMockData data;
  final VoidCallback? onStoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: FiYouHomeColors.primaryPurple.withValues(alpha: 0.24),
                blurRadius: 18,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/fi_you_logo_mark.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'FI-YOU',
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
          onTap: onStoreTap,
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
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: FiYouHomeColors.surfaceBase.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: FiYouHomeColors.borderVisible.withValues(alpha: 0.68),
              ),
            ),
            child: Icon(icon, color: FiYouHomeColors.textSecondary, size: 21),
          ),
        ),
      ),
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
          '오늘은 질문 하나와 짧은 기록으로 나를 발견해볼 시간이에요.',
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

class StarLevelBadge extends StatelessWidget {
  const StarLevelBadge({
    super.key,
    required this.starCount,
    required this.levelLabel,
    this.onTap,
  });

  final int starCount;
  final String levelLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Store로 이동',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: FiYouHomeColors.accentGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: FiYouHomeColors.accentGold.withValues(alpha: 0.34),
              ),
              boxShadow: [
                BoxShadow(
                  color: FiYouHomeColors.accentGold.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HomeStarIcon(color: FiYouHomeColors.accentGold, size: 19),
                const SizedBox(width: 6),
                Text('$starCount', style: _badgeTextStyle),
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: FiYouHomeColors.accentGold.withValues(alpha: 0.44),
                ),
                Text(levelLabel, style: _badgeTextStyle),
              ],
            ),
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 15, 15),
      fillColor: FiYouHomeColors.surfaceAction,
      borderColor: const Color(0xFF27405A),
      child: Row(
        children: [
          const SignalIconPanel(
            icon: Icons.auto_awesome_rounded,
            color: FiYouHomeColors.primarySoft,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '오늘 할 일 · 다음 질문',
                        style: TextStyle(
                          color: FiYouHomeColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Text(
                      estimatedTime,
                      style: const TextStyle(
                        color: FiYouHomeColors.textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  question,
                  style: const TextStyle(
                    color: FiYouHomeColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.38,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const _TinyActionPill(
            label: '시작',
            color: FiYouHomeColors.primarySoft,
          ),
        ],
      ),
    );
  }
}

class UMapCard extends StatelessWidget {
  const UMapCard({super.key, required this.data, this.onTap});

  final HomeMockData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouSurface(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1B2140).withValues(alpha: 0.86),
          const Color(0xFF0E1325).withValues(alpha: 0.94),
          const Color(0xFF080C1A),
        ],
      ),
      borderColor: FiYouHomeColors.primaryPurple.withValues(alpha: 0.28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 350;
          final graph = SizedBox(
            width: compact ? 172 : 190,
            height: compact ? 172 : 190,
            child: UMapGraph(axes: data.axisClues),
          );

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'U-Map',
                      style: TextStyle(
                        color: FiYouHomeColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: FiYouHomeColors.primaryPurple.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: FiYouHomeColors.primarySoft.withValues(
                          alpha: 0.24,
                        ),
                      ),
                    ),
                    child: Text(
                      data.uMapLevelLabel,
                      style: const TextStyle(
                        color: FiYouHomeColors.primarySoft,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 10),
                Center(child: graph),
                const SizedBox(height: 10),
                Text(
                  "지금까지의 기록을 바탕으로 탐구한 '${data.userName}' 님 입니다.",
                  style: const TextStyle(
                    color: FiYouHomeColors.textSecondary,
                    fontSize: 12,
                    height: 1.42,
                    letterSpacing: 0,
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              const SizedBox(height: 8),
              Center(child: graph),
              const SizedBox(height: 9),
              Text(
                "지금까지의 기록을 바탕으로 탐구한 '${data.userName}' 님 입니다.",
                style: const TextStyle(
                  color: FiYouHomeColors.textSecondary,
                  fontSize: 12,
                  height: 1.42,
                  letterSpacing: 0,
                ),
              ),
            ],
          );
        },
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
      actionLabel: '짧게 기록',
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
                  '아직 확정된 해석이 아니라, 기록에서 발견한 작은 신호입니다.',
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
          const Icon(
            Icons.chevron_right_rounded,
            color: FiYouHomeColors.textMuted,
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
              TextButton(onPressed: onTap, child: const Text('자세히')),
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
                    color: FiYouHomeColors.borderSubtle.withValues(alpha: 0.65),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            latestUpdateLabel,
            style: const TextStyle(
              color: FiYouHomeColors.textMuted,
              fontSize: 11.5,
              letterSpacing: 0,
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
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: metric.color.withValues(alpha: 0.12),
          ),
          child: metric.icon == Icons.auto_awesome_rounded
              ? HomeSparkIcon(color: metric.color, size: 18)
              : Icon(metric.icon, color: metric.color, size: 17),
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
    required this.actionLabel,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  final String title;
  final String body;
  final String actionLabel;
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
          final action = _TinyActionPill(
            label: actionLabel,
            color: accentColor,
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

class _TinyActionPill extends StatelessWidget {
  const _TinyActionPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.chevron_right_rounded, color: color, size: 17),
        ],
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
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: icon == Icons.auto_awesome_rounded
          ? HomeSparkIcon(color: color, size: 22)
          : Icon(icon, color: color, size: 20),
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
    this.borderColor = FiYouHomeColors.borderSubtle,
    this.gradient,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color fillColor;
  final Color borderColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? fillColor.withValues(alpha: 0.56) : null,
            gradient:
                gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.075),
                    fillColor.withValues(alpha: 0.38),
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor.withValues(alpha: 0.62)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: content,
      ),
    );
  }
}

abstract final class FiYouHomeColors {
  static const backgroundBase = Color(0xFF050714);
  static const surfaceBase = Color(0xFF0B1020);
  static const surfaceInsight = Color(0xFF10172A);
  static const surfaceAction = Color(0xFF0B1722);
  static const surfaceCompact = Color(0xFF0C1222);
  static const borderSubtle = Color(0xFF1A2440);
  static const borderVisible = Color(0xFF273556);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB7C0D7);
  static const textMuted = Color(0xFF7F8AA6);
  static const primaryPurple = Color(0xFF8B5CF6);
  static const primarySoft = Color(0xFFC4B5FD);
  static const accentCyan = Color(0xFF7DD3FC);
  static const accentGold = Color(0xFFF7C948);
}
