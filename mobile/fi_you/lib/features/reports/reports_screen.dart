import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_state.dart';
import '../../data/repositories/repository_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportsProvider);

    return reports.when(
      loading: () => const ScreenState.loading(),
      error: (_, __) => ScreenState.message(
        title: '리포트를 불러오지 못했어요',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(reportsProvider),
      ),
      data: (items) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text(
            '리포트',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '현재 기록에서 보이는 흐름을 더 길게 살펴보는 공간이에요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const GlassCard(child: Text('아직 준비된 리포트가 없어요.'))
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        item.summary ?? '기록이 쌓이면 리포트를 만들 수 있어요.',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (item.requiredProductId != null) ...[
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: () => context.push('/store'),
                          child: const Text('확장 보기 열기'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
