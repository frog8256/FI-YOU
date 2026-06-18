import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/fi_you_components.dart';
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
        body: '잠시 후 다시 시도해 주세요.',
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(nextQuestionProvider),
      ),
      data: (data) => FiYouPage(
        children: [
          const FiYouHeader(
            overline: 'Question',
            title: '정답보다 가까운 느낌을\n골라보세요',
            subtitle: '이 질문은 평가가 아니라 오늘의 흐름을 더 잘 읽기 위한 작은 단서예요.',
          ),
          GlassCard(
            emphasis: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FiYouPill(label: data.category, icon: Icons.auto_awesome_outlined),
                const SizedBox(height: 14),
                if (data.subtitle != null) ...[
                  Text(data.subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                ],
                Text(data.prompt, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final choice in data.choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChoiceTile(
                choice: choice,
                selected: _selectedChoiceId == choice.id,
                onTap: () => setState(() => _selectedChoiceId = choice.id),
              ),
            ),
          const SizedBox(height: 4),
          GlassCard(
            child: TextField(
              controller: _freeTextController,
              minLines: 4,
              maxLines: 7,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                labelText: data.optionalTextPrompt,
                hintText: '떠오르는 장면이나 이유가 있다면 자유롭게 남겨주세요.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          FiYouGradientButton(
            label: '저장하고 Diary 쓰기',
            icon: Icons.edit_note_outlined,
            loading: _saving,
            onPressed: _selectedChoiceId == null ? null : () => _submit(data),
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
          const SnackBar(content: Text('저장하지 못했어요. 다시 시도해 주세요.')),
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
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      emphasis: selected,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: selected ? FiYouColors.cyan : FiYouColors.text,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(choice.label, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
