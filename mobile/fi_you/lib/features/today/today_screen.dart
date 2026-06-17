import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_state.dart';
import '../../data/repositories/repository_providers.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(todaySummaryProvider);

    return summary.when(
      loading: () => const ScreenState.loading(),
      error: (_, __) => ScreenState.message(
        title: '오늘의 흐름을 불러오지 못했어요',
        body: '네트워크를 확인하고 다시 시도해주세요.',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(todaySummaryProvider),
      ),
      data: (data) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(todaySummaryProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            Text(
              '오늘의 탐험',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '짧게 답하고, 기록하고, 흐름을 확인해요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 질문',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data.question.prompt,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (data.question.whyThisQuestion != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      data.question.whyThisQuestion!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.push('/question'),
                    child: const Text('답하기'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    onTap: () => context.go('/u-map'),
                    child: _Metric(
                      title: 'U-Map 선명도',
                      value: '${data.uMap.overallClarity.round()}%',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    onTap: () => context.go('/signature'),
                    child: const _Metric(title: 'Signature', value: '확인'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GlassCard(
              onTap: () => context.go('/diary'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('최근 Diary', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    data.diaries.isEmpty ? '아직 남긴 기록이 없어요.' : data.diaries.first.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    onTap: () => context.push('/relations'),
                    child: _Metric(
                      title: '관계 탐험',
                      value: data.relations.isEmpty ? '시작' : '${data.relations.length}개',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    onTap: () => context.push('/store'),
                    child: _Metric(
                      title: 'Star',
                      value: '${data.starBalance.balance}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GlassCard(
              onTap: () => context.push('/reports'),
              child: const Text('리포트 보기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
