import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/fi_you_components.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_state.dart';
import '../../data/repositories/repository_providers.dart';

class SignatureScreen extends ConsumerWidget {
  const SignatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signature = ref.watch(signatureProvider);

    return signature.when(
      loading: () => const ScreenState.loading(),
      error: (_, __) => ScreenState.message(
        title: 'Signature를 불러오지 못했어요',
        body: '잠시 후 다시 확인해 주세요.',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(signatureProvider),
      ),
      data: (flow) => FiYouPage(
        children: [
          const FiYouHeader(
            overline: 'Signature',
            title: '현재까지 보이는\n나의 흐름 이름',
            subtitle: 'Signature는 고정 유형이 아니며, 기록이 쌓이면 다르게 보일 수 있어요.',
          ),
          GlassCard(
            emphasis: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FiYouPill(label: '현재 기록 기반', icon: Icons.waves_outlined),
                const SizedBox(height: 14),
                Text(flow.label, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 14),
                Text(flow.summary, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 14),
                Text(flow.confidenceNote, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (flow.evidence.isNotEmpty) ...[
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('보이는 단서', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  for (final item in flow.evidence) FiYouInfoRow(text: item, icon: Icons.auto_awesome_outlined),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          FiYouGradientButton(
            label: '다음 질문 보기',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.push('/question'),
          ),
          const SizedBox(height: 10),
          Text(
            'FI-YOU는 사람을 유형으로 고정하지 않고, 지금까지의 기록에서 보이는 흐름을 탐구합니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: FiYouColors.muted),
          ),
        ],
      ),
    );
  }
}
