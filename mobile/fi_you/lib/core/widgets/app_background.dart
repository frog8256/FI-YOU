import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  FiYouColors.canvas,
                  Color(0xFF050A17),
                  FiYouColors.canvas,
                ],
              ),
            ),
          ),
        ),
        const Positioned.fill(child: _GlowWash()),
        Positioned.fill(
          child: CustomPaint(
            painter: _FieldLinePainter(
              color: Colors.white.withValues(alpha: 0.026),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowWash extends StatelessWidget {
  const _GlowWash();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.74, -0.82),
          radius: 1.08,
          colors: [
            FiYouColors.violet.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const [0, 1],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.86, -0.38),
            radius: 0.96,
            colors: [
              FiYouColors.blue.withValues(alpha: 0.16),
              Colors.transparent,
            ],
            stops: const [0, 1],
          ),
        ),
      ),
    );
  }
}

class _FieldLinePainter extends CustomPainter {
  const _FieldLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const gap = 42.0;
    for (var x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.45, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FieldLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 64, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _BrandMarkPainter(),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.28;
    final ringPaint = Paint()
      ..color = FiYouColors.violetSoft.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final corePaint = Paint()
      ..shader = const LinearGradient(
        colors: [FiYouColors.violet, FiYouColors.purple],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    final nodePaint = Paint()..color = FiYouColors.cyan;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.34);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.width * 0.86, height: size.height * 0.36),
      ringPaint,
    );
    canvas.rotate(0.68);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.width * 0.76, height: size.height * 0.32),
      ringPaint..color = FiYouColors.blue.withValues(alpha: 0.34),
    );
    canvas.restore();

    canvas.drawCircle(center, radius, corePaint);
    canvas.drawCircle(center + Offset(size.width * 0.28, -size.height * 0.08), size.width * 0.055, nodePaint);
    canvas.drawCircle(center + Offset(-size.width * 0.24, size.height * 0.16), size.width * 0.045, Paint()..color = FiYouColors.gold);
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter oldDelegate) => false;
}
