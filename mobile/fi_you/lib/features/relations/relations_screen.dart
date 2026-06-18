import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/fi_you_components.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_state.dart';
import '../../data/repositories/repository_providers.dart';

class RelationsScreen extends ConsumerStatefulWidget {
  const RelationsScreen({super.key});

  @override
  ConsumerState<RelationsScreen> createState() => _RelationsScreenState();
}

class _RelationsScreenState extends ConsumerState<RelationsScreen> {
  final _labelController = TextEditingController();
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _labelController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relations = ref.watch(relationsProvider);
    return relations.when(
      loading: () => const ScreenState.loading(),
      error: (_, __) => ScreenState.message(
        title: '관계 목록을 불러오지 못했어요',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(relationsProvider),
      ),
      data: (items) => FiYouPage(
        children: [
          const FiYouHeader(
            overline: 'Relations',
            title: '관계도 판단하지 않고\n흐름으로 살펴봐요',
            subtitle: '상대방을 분석하지 않습니다. 내 기록 안에서 반복되는 관계의 감각만 탐구합니다.',
          ),
          GlassCard(
            emphasis: true,
            child: Column(
              children: [
                TextField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    labelText: '살펴볼 관계 이름',
                    hintText: '예: 가족, 동료, 친구',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '남기고 싶은 메모',
                    hintText: '그 관계에서 자주 남는 느낌을 적어보세요.',
                  ),
                ),
                const SizedBox(height: 14),
                FiYouGradientButton(
                  label: '관계 흐름 만들기',
                  icon: Icons.hub_outlined,
                  loading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const GlassCard(child: Text('아직 저장한 관계 흐름이 없어요.'))
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FiYouPill(label: item.status, icon: Icons.waves_outlined),
                      const SizedBox(height: 12),
                      Text(item.label, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        item.note ?? '기록이 쌓이면 이 관계에서 느껴지는 흐름을 더 살펴볼 수 있어요.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_labelController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(selfDiscoveryRepositoryProvider).createRelation(
            label: _labelController.text.trim(),
            note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          );
      _labelController.clear();
      _noteController.clear();
      ref.invalidate(relationsProvider);
      ref.invalidate(todaySummaryProvider);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
