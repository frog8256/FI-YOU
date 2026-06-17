import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        body: '저장된 기록을 확인할 수 없어요.',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(uMapProvider),
      ),
      data: (snapshot) {
        if (snapshot.axes.isEmpty) {
          return ScreenState.message(
            title: '아직 덜 보이는 영역이에요',
            body: '질문과 Diary가 쌓이면 U-Map이 조금씩 선명해져요.',
            actionLabel: '질문 답하기',
            onAction: () => context.push('/question'),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            Text(
              'U-Map',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '현재 기록에서 보이는 경향이에요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  SizedBox(
                    height: 240,
                    child: CustomPaint(
                      painter: UMapPainter(snapshot.axes),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '선명도 ${snapshot.overallClarity.round()}%',
                    style: Theme.of(context).textTheme.titleMedium,
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
                          Expanded(
                            child: Text(
                              axis.label,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text('${axis.clarity.round()}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        axis.summary,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            GlassCard(
              onTap: () => context.push('/question'),
              child: const Text('다음 탐험 질문 보기'),
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
      ..color = Colors.white.withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fillPaint = Paint()
      ..color = const Color(0xFF9B7CFF).withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = const Color(0xFF64D6E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var ring = 1; ring <= 4; ring++) {
      canvas.drawCircle(center, radius * ring / 4, gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < axes.length; i++) {
      final angle = -pi / 2 + i * 2 * pi / axes.length;
      final valueRadius = radius * (axes[i].score.clamp(0, 100) / 100);
      final outer = center + Offset(cos(angle), sin(angle)) * radius;
      points.add(center + Offset(cos(angle), sin(angle)) * valueRadius);
      canvas.drawLine(center, outer, gridPaint);
    }

    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant UMapPainter oldDelegate) => oldDelegate.axes != axes;
}
