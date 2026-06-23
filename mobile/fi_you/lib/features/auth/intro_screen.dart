import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: SizedBox(
                height: constraints.maxHeight > 52
                    ? constraints.maxHeight - 52
                    : constraints.maxHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 14),
                    const _BrandMark(),
                    const Spacer(),
                    Text(
                      'MY UNIVERSE',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 28, letterSpacing: 0),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '질문과 Diary 기록을 바탕으로 지금의 자기탐색 흐름을 차분히 보여드릴게요.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 34),
                    FiYouLiquidButton(
                      label: '시작하기',
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: onContinue,
                      height: 58,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '사람을 단정하지 않고, 기록에서 흐름을 발견합니다.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox.square(
        dimension: 72,
        child: CustomPaint(painter: _BrandSparkPainter()),
      ),
    );
  }
}

class _BrandSparkPainter extends CustomPainter {
  const _BrandSparkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.48, size.height * 0.52);
    final glowPaint = Paint()
      ..color = const Color(0xFFC4B5FD).withValues(alpha: 0.28)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        size.shortestSide * 0.16,
      );
    final mainPath = _sparkPath(
      center,
      size.shortestSide * 0.33,
      size.shortestSide * 0.115,
    );

    canvas.drawPath(mainPath, glowPaint);
    canvas.drawPath(
      mainPath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.42),
          radius: 0.9,
          colors: const [
            Color(0xFFFFFFFF),
            Color(0xFFE7D9FF),
            Color(0xFFA78BFA),
          ],
          stops: const [0.0, 0.3, 1.0],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      mainPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.7),
    );

    _drawSmallSpark(
      canvas,
      Offset(size.width * 0.76, size.height * 0.22),
      size.shortestSide * 0.11,
      const Color(0xFFE7D9FF),
    );
    _drawSmallSpark(
      canvas,
      Offset(size.width * 0.26, size.height * 0.73),
      size.shortestSide * 0.075,
      const Color(0xFFA78BFA),
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

  void _drawSmallSpark(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    canvas.drawPath(
      _sparkPath(center, radius, radius * 0.35),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _BrandSparkPainter oldDelegate) => false;
}
