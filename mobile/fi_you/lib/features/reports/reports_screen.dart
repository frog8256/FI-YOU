import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/fi_you_components.dart';
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
      data: (items) => FiYouPage(
        children: [
          const FiYouHeader(
            overline: 'Reports',
            title: '기록을 더 깊게\n읽어보는 공간',
            subtitle: '리포트는 지금까지 보이는 흐름을 정리하는 참고 자료이며, 고정된 판단이 아닙니다.',
          ),
          if (items.isEmpty)
            const GlassCard(child: Text('아직 준비된 리포트가 없어요. 기록이 쌓이면 열 수 있어요.'))
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FiYouPill(
                        label: item.status == 'unlocked' ? '열림' : '잠김',
                        icon: item.status == 'unlocked' ? Icons.lock_open_outlined : Icons.lock_outline,
                      ),
                      const SizedBox(height: 12),
                      Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        item.summary ?? '기록이 쌓이면 이 흐름을 더 자세히 읽어볼 수 있어요.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (item.requiredProductId != null) ...[
                        const SizedBox(height: 14),
                        FiYouGradientButton(
                          label: '확장 보기 열기',
                          icon: Icons.stars_rounded,
                          onPressed: () => context.push('/store'),
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
