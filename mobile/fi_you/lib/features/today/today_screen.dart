import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/fi_you_components.dart';
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
        body: '네트워크 상태를 확인한 뒤 다시 시도해 주세요.',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(todaySummaryProvider),
      ),
      data: (data) => FiYouPage(
        onRefresh: () async => ref.invalidate(todaySummaryProvider),
        children: [
          FiYouHeader(
            overline: 'Today',
            title: '오늘의 나를\n조금 더 선명하게',
            subtitle: '질문에 답하고 짧게 기록하면 U-Map의 흐름이 천천히 또렷해집니다.',
            trailing: const BrandMark(size: 52),
          ),
          GlassCard(
            emphasis: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FiYouPill(label: '오늘의 질문', icon: Icons.question_answer_outlined),
                const SizedBox(height: 14),
                Text(
                  data.question.prompt,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (data.question.whyThisQuestion != null) ...[
                  const SizedBox(height: 10),
                  Text(data.question.whyThisQuestion!, style: Theme.of(context).textTheme.bodyMedium),
                ],
                const SizedBox(height: 18),
                FiYouGradientButton(
                  label: '답하고 Diary로 이어가기',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => context.push('/question'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            onTap: () => context.go('/u-map'),
            child: Column(
              children: [
                MiniUMap(
                  size: 230,
                  axes: data.uMap.axes.map((axis) => axis.score).toList(growable: false),
                ),
                const SizedBox(height: 8),
                Text('U-Map 선명도 ${data.uMap.overallClarity.round()}%', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  '현재까지의 기록에서 보이는 흐름이에요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FiYouMetricCard(
                  title: 'Signature',
                  value: data.signature.label.isEmpty ? '흐름 대기' : data.signature.label,
                  caption: '고정 유형이 아닌 현재 흐름',
                  icon: Icons.waves_outlined,
                  onTap: () => context.go('/signature'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FiYouMetricCard(
                  title: 'Star',
                  value: '${data.starBalance.balance}',
                  caption: '추가 탐구에 사용하는 별',
                  icon: Icons.stars_rounded,
                  onTap: () => context.push('/store'),
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
                Row(
                  children: [
                    const Icon(Icons.edit_note_outlined, color: FiYouColors.cyan),
                    const SizedBox(width: 10),
                    Text('최근 Diary', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  data.diaries.isEmpty
                      ? '아직 남긴 기록이 없어요. 오늘의 생각을 짧게 남겨보세요.'
                      : data.diaries.first.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FiYouMetricCard(
                  title: 'Reports',
                  value: data.reports.isEmpty ? '준비 중' : '${data.reports.length}개',
                  caption: '기록을 더 깊게 읽기',
                  icon: Icons.article_outlined,
                  onTap: () => context.push('/reports'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FiYouMetricCard(
                  title: 'Relations',
                  value: data.relations.isEmpty ? '시작' : '${data.relations.length}개',
                  caption: '관계의 흐름 살펴보기',
                  icon: Icons.hub_outlined,
                  onTap: () => context.push('/relations'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
