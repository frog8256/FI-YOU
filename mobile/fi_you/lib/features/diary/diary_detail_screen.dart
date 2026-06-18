import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/fi_you_components.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_state.dart';
import '../../data/repositories/repository_providers.dart';

class DiaryDetailScreen extends ConsumerWidget {
  const DiaryDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diary = ref.watch(diaryProvider(id));

    return diary.when(
      loading: () => const ScreenState.loading(),
      error: (_, __) => const ScreenState.message(title: '기록을 불러오지 못했어요'),
      data: (entry) {
        if (entry == null) {
          return const ScreenState.message(title: '기록을 찾을 수 없어요');
        }
        return FiYouPage(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: '뒤로',
                  onPressed: () => context.canPop() ? context.pop() : context.go('/diary'),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: '수정',
                  onPressed: () => context.push('/diary/$id/edit'),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GlassCard(
              emphasis: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FiYouPill(
                    label: DateFormat('yyyy년 M월 d일').format(entry.entryDate),
                    icon: Icons.calendar_today_outlined,
                    color: FiYouColors.blue,
                  ),
                  const SizedBox(height: 14),
                  Text(entry.title ?? '오늘의 기록', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Text(
                    entry.body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.62),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
