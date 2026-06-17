import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        title: '흐름을 불러오지 못했어요',
        body: '잠시 후 다시 확인해주세요.',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(signatureProvider),
      ),
      data: (flow) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text(
            'Signature',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '현재 기록에서 보이는 흐름이에요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flow.label,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 14),
                Text(
                  flow.summary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
                ),
                const SizedBox(height: 14),
                Text(flow.confidenceNote, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          if (flow.evidence.isNotEmpty) ...[
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('보이는 신호', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  for (final item in flow.evidence)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => context.push('/question'),
            child: const Text('다음 질문 보기'),
          ),
        ],
      ),
    );
  }
}
