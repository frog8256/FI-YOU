import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.canPop() ? context.pop() : context.go('/diary'),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: () => context.push('/diary/$id/edit'),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('yyyy년 M월 d일').format(entry.entryDate),
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.title ?? '오늘의 기록',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    entry.body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
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
