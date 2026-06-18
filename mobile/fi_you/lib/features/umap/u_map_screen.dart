import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/fi_you_components.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_state.dart';
import '../../data/models/fiyou_models.dart';
import '../../data/repositories/repository_providers.dart';

class UMapScreen extends ConsumerWidget {
  const UMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uMap = ref.watch(uMapProvider);

    return uMap.when(
      loading: () => const ScreenState.loading(),
      error: (_, __) => ScreenState.message(
        title: 'U-Map을 불러오지 못했어요',
        body: '저장된 기록을 확인할 수 있을 때 다시 보여드릴게요.',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(uMapProvider),
      ),
      data: (snapshot) {
        if (snapshot.axes.isEmpty) {
          return ScreenState.message(
            title: '아직 선명한 흐름이 없어요',
            body: '질문과 Diary가 쌓이면 U-Map이 조금씩 또렷해집니다.',
            actionLabel: '질문 답하기',
            onAction: () => context.push('/question'),
          );
        }
        return FiYouPage(
          children: [
            const FiYouHeader(
              overline: 'U-Map',
              title: '현재 기록에서 보이는\n흐름의 지도',
              subtitle: '점수는 사람을 분류하기 위한 값이 아니라, 지금까지 기록된 경향의 선명도를 보여주는 단서예요.',
            ),
            GlassCard(
              emphasis: true,
              child: Column(
                children: [
                  SizedBox(
                    height: 260,
                    child: CustomPaint(
                      painter: UMapPainter(snapshot.axes),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FiYouPill(
                    label: '선명도 ${snapshot.overallClarity.round()}%',
                    icon: Icons.blur_on_outlined,
                    color: FiYouColors.cyan,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final axis in snapshot.axes)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(axis.label, style: Theme.of(context).textTheme.titleMedium)),
                          FiYouPill(label: '${axis.clarity.round()}%', color: FiYouColors.blue),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 7,
                          value: axis.clarity.clamp(0, 100) / 100,
                          color: FiYouColors.cyan,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(axis.summary, style: Theme.of(context).textTheme.bodyMedium),
                      if (axis.nextDepth != null) ...[
                        const SizedBox(height: 8),
                        Text('다음 탐구: ${axis.nextDepth}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 4),
            FiYouGradientButton(
              label: '다음 탐구 질문 보기',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.push('/question'),
            ),
          ],
        );
      },
    );
  }
}

class UMapPainter extends CustomPainter {
  UMapPainter(this.axes);

  final List<UMapAxis> axes;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.38;
    final gridPaint = Paint()
      ..color = FiYouColors.blue.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          FiYouColors.violet.withValues(alpha: 0.34),
          FiYouColors.cyan.withValues(alpha: 0.12),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    final linePaint = Paint()
      ..color = FiYouColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    for (var ring = 1; ring <= 4; ring++) {
      canvas.drawCircle(center, radius * ring / 4, gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < axes.length; i++) {
      final angle = -pi / 2 + i * 2 * pi / axes.length;
      final valueRadius = radius * (axes[i].score.clamp(0, 100) / 100);
      final outer = center + Offset(cos(angle), sin(angle)) * radius;
      final point = center + Offset(cos(angle), sin(angle)) * valueRadius;
      points.add(point);
      canvas.drawLine(center, outer, gridPaint);
      canvas.drawCircle(outer, 3, Paint()..color = FiYouColors.blue.withValues(alpha: 0.8));
    }

    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, linePaint);
    for (final point in points) {
      canvas.drawCircle(point, 4.5, Paint()..color = FiYouColors.cyan);
    }
  }

  @override
  bool shouldRepaint(covariant UMapPainter oldDelegate) => oldDelegate.axes != axes;
}
