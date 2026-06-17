import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(
          widget.id == 'new' ? 'Diary 작성' : 'Diary 수정',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '제목'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyController,
                minLines: 7,
                maxLines: 12,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(labelText: '오늘의 기록'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : () => _save(existing),
                child: Text(_saving ? '저장 중...' : '저장하기'),
              ),
              if (existing != null) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _saving ? null : () => _delete(existing.id),
                  child: const Text('삭제하기'),
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
          const SnackBar(content: Text('저장하지 못했어요. 다시 시도해주세요.')),
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
