import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_state.dart';
import '../../data/repositories/repository_providers.dart';

class DiaryListScreen extends ConsumerWidget {
  const DiaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaries = ref.watch(diariesProvider);

    return diaries.when(
      loading: () => const ScreenState.loading(),
      error: (_, __) => ScreenState.message(
        title: 'Diary를 불러오지 못했어요',
        body: '네트워크가 연결되면 다시 확인할 수 있어요.',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(diariesProvider),
      ),
      data: (items) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Diary',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => context.push('/diary/new'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            ScreenState.message(
              title: '아직 남긴 기록이 없어요',
              body: '오늘의 생각을 짧게 남겨보세요.',
              actionLabel: '작성하기',
              onAction: () => context.push('/diary/new'),
            )
          else
            for (final entry in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  onTap: () => context.push('/diary/${entry.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('M월 d일').format(entry.entryDate),
                        style: const TextStyle(color: Colors.white54),
                      ),
                      const SizedBox(height: 6),
                      Text(entry.title ?? '오늘의 기록'),
                      const SizedBox(height: 6),
                      Text(
                        entry.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
