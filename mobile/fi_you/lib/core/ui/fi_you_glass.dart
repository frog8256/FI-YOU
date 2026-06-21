import 'dart:math' as math;

import 'package:flutter/material.dart';

class FiYouGlass {
  const FiYouGlass._();

  static const background = Color(0xFF050714);
  static const depth = Color(0xFF080D1D);
  static const surface = Color(0xFF0E1325);
  static const surfaceSoft = Color(0xFF141B30);
  static const border = Color(0xFF2D3B62);
  static const text = Color(0xFFFFFFFF);
  static const textSoft = Color(0xFFB7C0D7);
  static const textMuted = Color(0xFF7F8AA6);
  static const primary = Color(0xFF8B5CF6);
  static const primarySoft = Color(0xFFC4B5FD);
  static const cyan = Color(0xFF7DD3FC);
  static const gold = Color(0xFFF7C948);

  static BoxDecoration decoration({
    Color? tint,
    Color? borderColor,
    double radius = 18,
    double alpha = 0.78,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: (borderColor ?? Colors.white).withValues(alpha: 0.14),
      ),
      color: (tint ?? surfaceSoft).withValues(alpha: alpha.clamp(0.0, 1.0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 34,
          offset: const Offset(0, 18),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.055),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  static ButtonStyle filledButtonStyle({
    Color foregroundColor = text,
    double radius = 16,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: Colors.white.withValues(alpha: 0.1),
      foregroundColor: foregroundColor,
      disabledBackgroundColor: Colors.white.withValues(alpha: 0.04),
      disabledForegroundColor: textMuted,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
      ),
    );
  }
}

class FiYouStarryBackground extends StatefulWidget {
  const FiYouStarryBackground({super.key});

  @override
  State<FiYouStarryBackground> createState() => _FiYouStarryBackgroundState();
}

class _FiYouStarryBackgroundState extends State<FiYouStarryBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: disableAnimations ? kAlwaysCompleteAnimation : _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _StarryNightPainter(_controller.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _StarryNightPainter extends CustomPainter {
  const _StarryNightPainter(this.phase);

  final double phase;

  static const _twinkles = [
    (x: 0.08, y: 0.14, size: 1.6, delay: 0.00),
    (x: 0.22, y: 0.08, size: 1.1, delay: 0.36),
    (x: 0.38, y: 0.18, size: 1.4, delay: 0.62),
    (x: 0.58, y: 0.10, size: 1.2, delay: 0.18),
    (x: 0.78, y: 0.16, size: 1.7, delay: 0.45),
    (x: 0.92, y: 0.07, size: 1.0, delay: 0.74),
    (x: 0.15, y: 0.34, size: 1.0, delay: 0.51),
    (x: 0.48, y: 0.31, size: 1.5, delay: 0.27),
    (x: 0.72, y: 0.38, size: 1.2, delay: 0.82),
    (x: 0.88, y: 0.29, size: 1.3, delay: 0.12),
    (x: 0.28, y: 0.52, size: 1.4, delay: 0.69),
    (x: 0.64, y: 0.58, size: 1.1, delay: 0.33),
    (x: 0.83, y: 0.66, size: 1.5, delay: 0.56),
    (x: 0.11, y: 0.73, size: 1.2, delay: 0.23),
    (x: 0.42, y: 0.82, size: 1.0, delay: 0.77),
    (x: 0.70, y: 0.88, size: 1.3, delay: 0.40),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF111936), Color(0xFF070B1A), Color(0xFF030511)],
        ).createShader(rect),
    );

    _drawNebula(canvas, size, const Offset(0.14, 0.05), FiYouGlass.primary);
    _drawNebula(canvas, size, const Offset(0.92, 0.22), FiYouGlass.cyan);
    _drawNebula(canvas, size, const Offset(0.52, 0.92), FiYouGlass.gold);

    for (final dot in _twinkles) {
      final wave = math.sin((phase + dot.delay) * math.pi * 2);
      final alpha = 0.18 + math.pow((wave + 1) / 2, 2) * 0.74;
      final center = Offset(size.width * dot.x, size.height * dot.y);
      final radius = dot.size + alpha * 2.4;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
      canvas.drawCircle(
        center,
        dot.size,
        Paint()..color = Colors.white.withValues(alpha: alpha * 0.78),
      );
    }
  }

  void _drawNebula(Canvas canvas, Size size, Offset anchor, Color color) {
    final center = Offset(size.width * anchor.dx, size.height * anchor.dy);
    final radius = size.shortestSide * 0.62;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.16),
            color.withValues(alpha: 0.035),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _StarryNightPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
