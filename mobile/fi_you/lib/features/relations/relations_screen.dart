import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      data: (items) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text(
            '관계 탐험',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '상대방을 단정하지 않고, 내 기록에서 보이는 관계의 흐름만 살펴봐요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(
              children: [
                TextField(
                  controller: _labelController,
                  decoration: const InputDecoration(labelText: '내가 알아볼 별칭'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: '남기고 싶은 메모'),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? '저장 중...' : '관계 흐름 만들기'),
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
                      Text(item.label, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        item.note ?? '기록이 쌓이면 더 살펴볼 수 있어요.',
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
