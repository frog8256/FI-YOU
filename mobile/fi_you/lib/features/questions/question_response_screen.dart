import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_state.dart';
import '../../data/models/fiyou_models.dart';
import '../../data/repositories/repository_providers.dart';

class QuestionResponseScreen extends ConsumerStatefulWidget {
  const QuestionResponseScreen({super.key});

  @override
  ConsumerState<QuestionResponseScreen> createState() => _QuestionResponseScreenState();
}

class _QuestionResponseScreenState extends ConsumerState<QuestionResponseScreen> {
  final _freeTextController = TextEditingController();
  String? _selectedChoiceId;
  bool _saving = false;

  @override
  void dispose() {
    _freeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = ref.watch(nextQuestionProvider);

    return question.when(
      loading: () => const ScreenState.loading(),
      error: (_, __) => ScreenState.message(
        title: '질문을 불러오지 못했어요',
        body: '잠시 후 다시 시도해주세요.',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(nextQuestionProvider),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text(
            '질문 응답',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.subtitle ?? '가장 가까운 답을 골라주세요.',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Text(
                  data.prompt,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 18),
                for (final choice in data.choices)
                  _ChoiceTile(
                    choice: choice,
                    selected: _selectedChoiceId == choice.id,
                    onTap: () => setState(() => _selectedChoiceId = choice.id),
                  ),
                const SizedBox(height: 14),
                TextField(
                  controller: _freeTextController,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(labelText: data.optionalTextPrompt),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving || _selectedChoiceId == null ? null : () => _submit(data),
                  child: Text(_saving ? '저장 중...' : '저장하고 Diary에 남기기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(Question question) async {
    setState(() => _saving = true);
    try {
      await ref.read(selfDiscoveryRepositoryProvider).submitAnswer(
            AnswerDraft(
              questionId: question.id,
              selectedChoiceIds: [_selectedChoiceId!],
              freeText: _freeTextController.text.trim().isEmpty
                  ? null
                  : _freeTextController.text.trim(),
            ),
          );
      ref.invalidate(todaySummaryProvider);
      ref.invalidate(nextQuestionProvider);
      ref.invalidate(uMapProvider);
      ref.invalidate(signatureProvider);
      if (mounted) context.push('/diary/new');
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
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final QuestionChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(choice.label)),
            ],
          ),
        ),
      ),
    );
  }
}
