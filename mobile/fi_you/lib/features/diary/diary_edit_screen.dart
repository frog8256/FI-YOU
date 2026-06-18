import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/fi_you_components.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_state.dart';
import '../../data/models/fiyou_models.dart';
import '../../data/repositories/repository_providers.dart';

class DiaryEditScreen extends ConsumerStatefulWidget {
  const DiaryEditScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<DiaryEditScreen> createState() => _DiaryEditScreenState();
}

class _DiaryEditScreenState extends ConsumerState<DiaryEditScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _didFill = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.id == 'new' ? null : ref.watch(diaryProvider(widget.id));
    if (existing != null) {
      return existing.when(
        loading: () => const ScreenState.loading(),
        error: (_, __) => const ScreenState.message(title: '기록을 불러오지 못했어요'),
        data: (entry) {
          if (entry != null && !_didFill) {
            _titleController.text = entry.title ?? '';
            _bodyController.text = entry.body;
            _didFill = true;
          }
          return _form(entry);
        },
      );
    }
    return _form(null);
  }

  Widget _form(DiaryEntry? existing) {
    return FiYouPage(
      children: [
        FiYouHeader(
          overline: 'Diary',
          title: widget.id == 'new' ? '오늘의 기록을 남겨요' : '기록을 다듬어요',
          subtitle: '정리된 글이 아니어도 괜찮아요. 지금 남는 감각을 그대로 적어도 충분합니다.',
        ),
        GlassCard(
          emphasis: true,
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '제목',
                  hintText: '예: 오늘 유난히 마음에 남은 일',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyController,
                minLines: 8,
                maxLines: 14,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: '오늘의 기록',
                  hintText: '무슨 일이 있었고, 그때 어떤 느낌이 남았나요?',
                ),
              ),
              const SizedBox(height: 16),
              FiYouGradientButton(
                label: '저장하기',
                icon: Icons.check_rounded,
                loading: _saving,
                onPressed: _saving ? null : () => _save(existing),
              ),
              if (existing != null) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _saving ? null : () => _delete(existing.id),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('삭제하기'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _save(DiaryEntry? existing) async {
    if (_bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기록을 조금만 남겨주세요.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final saved = await ref.read(selfDiscoveryRepositoryProvider).saveDiary(
            DiaryEntry(
              id: existing?.id ?? 'new',
              entryDate: existing?.entryDate ?? DateTime.now(),
              title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
              body: _bodyController.text.trim(),
              moodScore: existing?.moodScore,
              tags: existing?.tags ?? const [],
            ),
          );
      ref.invalidate(diariesProvider);
      ref.invalidate(todaySummaryProvider);
      if (mounted) context.go('/diary/${saved.id}');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장하지 못했어요. 다시 시도해 주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(String id) async {
    await ref.read(selfDiscoveryRepositoryProvider).deleteDiary(id);
    ref.invalidate(diariesProvider);
    ref.invalidate(todaySummaryProvider);
    if (mounted) context.go('/diary');
  }
}
