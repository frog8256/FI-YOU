import 'dart:math' as math;
import 'dart:ui';

import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/features/explore/insight_feed_screen.dart';
import 'package:fi_you/features/explore/story_feed_screen.dart';
import 'package:flutter/material.dart';

typedef ExploreAnswersSaved = Future<void> Function(List<String> answers);

const _surface = FiYouGlass.surface;
const _text = FiYouGlass.text;
const _textSoft = FiYouGlass.textSoft;
const _textMuted = FiYouGlass.textMuted;
const _primarySoft = FiYouGlass.primarySoft;
const _cyan = FiYouGlass.cyan;
const _mint = Color(0xFF6EE7B7);
const _gold = FiYouGlass.gold;
const _minimumExplorationLoadingDuration = Duration(milliseconds: 2600);

class ExploreScreen extends ExploreHomeScreen {
  const ExploreScreen({
    super.onStartFreeExplore,
    super.onStartTodayRecommendation,
    super.onAnswersSaved,
    super.onOpenUMap,
    super.key,
  });
}

class ExploreHomeScreen extends StatelessWidget {
  const ExploreHomeScreen({
    this.onStartFreeExplore,
    this.onStartTodayRecommendation,
    this.onAnswersSaved,
    this.onOpenUMap,
    super.key,
  });

  final VoidCallback? onStartFreeExplore;
  final VoidCallback? onStartTodayRecommendation;
  final ExploreAnswersSaved? onAnswersSaved;
  final VoidCallback? onOpenUMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 122),
          children: [
            const _ExploreHeader(),
            const SizedBox(height: 18),
            _FlowCard(
              onStartQuestion: () => _startTodayRecommendation(context),
            ),
            const SizedBox(height: 14),
            const _InsightFeedEntryCard(),
            const SizedBox(height: 14),
            _FreeExploreCard(onStart: () => _startFreeExplore(context)),
            const SizedBox(height: 18),
            _TodayRecommendationCard(
              onStart: () => _startTodayRecommendation(context),
            ),
            const SizedBox(height: 14),
            const _StoryFeedEntryCard(),
          ],
        ),
      ),
    );
  }

  void _startFreeExplore(BuildContext context) {
    onStartFreeExplore?.call();
    _openQuestionFlow(context, initialTitle: '지금 떠오르는 주제로 나를 탐구해볼까요?');
  }

  void _startTodayRecommendation(BuildContext context) {
    onStartTodayRecommendation?.call();
    _openQuestionFlow(context, initialTitle: '갈등 상황에서 나는 어떻게 반응할까?');
  }

  void _openQuestionFlow(BuildContext context, {required String initialTitle}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ExplorationExperienceScreen(),
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 46,
          height: 46,
          child: Center(child: ExploreSparkIcon(color: _gold, size: 25)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '탐구',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: _text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard({required this.onStartQuestion});

  final VoidCallback onStartQuestion;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              ExploreSparkIcon(color: _primarySoft, size: 21),
              SizedBox(width: 8),
              Text(
                '탐구 흐름',
                style: TextStyle(
                  color: _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '질문과 Diary에서 쌓인 단서를 바탕으로, 아직 더 살펴볼 자기탐험 영역을 보여줘요.',
            style: TextStyle(
              color: _textSoft,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _Metric(label: '완료 질문', value: '12'),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _Metric(label: '발견 단서', value: '5'),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _Metric(label: '탐구 영역', value: '3'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _FlowListItem(
            icon: Icons.timeline_rounded,
            title: '최근 이어진 흐름',
            body: '감정을 먼저 정리하려는 단서가 보여요.',
          ),
          const SizedBox(height: 12),
          const _FlowListItem(
            icon: Icons.map_outlined,
            title: '다음 탐구 영역',
            body: '첫 반응과 회복 방식을 더 살펴봐요.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _QuestionStartButton(onPressed: onStartQuestion),
          ),
        ],
      ),
    );
  }
}

class _InsightFeedEntryCard extends StatelessWidget {
  const _InsightFeedEntryCard();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: _cyan, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '조금씩 선명해지는 방향',
                  style: TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '최근 탐험에서 떠오른 발견을 살펴보세요.',
                  style: TextStyle(
                    color: _textSoft,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '발견 열기',
            icon: const Icon(Icons.arrow_forward_rounded, color: _text),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const InsightFeedScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StoryFeedEntryCard extends StatelessWidget {
  const _StoryFeedEntryCard();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: _gold, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '나의 이야기',
                  style: TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '탐험에서 이어지는 조용한 장을 읽어보세요.',
                  style: TextStyle(
                    color: _textSoft,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '이야기 열기',
            icon: const Icon(Icons.arrow_forward_rounded, color: _text),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const StoryFeedScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FreeExploreCard extends StatelessWidget {
  const _FreeExploreCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      onTap: onStart,
      child: Row(
        children: [
          const _RingedPlanetIcon(color: _gold, size: 34),
          const SizedBox(width: 14),
          const Expanded(child: _FreeExploreCopy()),
          const SizedBox(width: 12),
          _FreeExploreStarPill(onPressed: onStart),
        ],
      ),
    );
  }
}

class _FreeExploreStarPill extends StatelessWidget {
  const _FreeExploreStarPill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '자유탐구 Star 소비',
      child: FiYouLiquidButton(
        label: '30 Star',
        icon: const Icon(Icons.star_rounded),
        onPressed: onPressed,
        width: 92,
        height: 34,
        radius: 999,
        fontSize: 11.5,
        foregroundColor: _gold,
        borderColor: _gold,
        borderWidth: 1.15,
        accentColor: _gold,
        accentStrength: 0.38,
        iconSize: 14,
        horizontalPadding: 10,
      ),
    );
  }
}

class _FreeExploreCopy extends StatelessWidget {
  const _FreeExploreCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '자유탐구',
          style: TextStyle(
            color: _text,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '지금 떠오르는 주제를 질문으로 이어가요.',
          style: TextStyle(color: _textSoft, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}

class _TodayRecommendationCard extends StatelessWidget {
  const _TodayRecommendationCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 탐구 추천',
          style: TextStyle(
            color: _text,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        _GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [_Tag('관계지향'), _Tag('감정패턴')],
              ),
              const SizedBox(height: 15),
              const Text(
                '갈등 상황에서 나는 어떻게 반응할까?',
                style: TextStyle(
                  color: _text,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                '정답을 고르는 질문이 아니라, 가까운 반응을 기록해 다음 단서로 남겨요.',
                style: TextStyle(color: _textSoft, fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                child: _QuestionStartButton(
                  label: '탐구 시작하기',
                  onPressed: onStart,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExplorationExperienceScreen extends StatefulWidget {
  const ExplorationExperienceScreen({super.key});

  @override
  State<ExplorationExperienceScreen> createState() =>
      _ExplorationExperienceScreenState();
}

class _ExplorationExperienceScreenState
    extends State<ExplorationExperienceScreen> {
  final _noteController = TextEditingController();
  final Set<String> _selectedOptionIds = {};

  late FiYouRepository _repository;

  ExplorationCard? _card;
  String? _errorMessage;
  bool _loading = true;
  bool _submitting = false;
  bool _awaitingNextCard = false;
  bool _startedLoading = false;
  int _cardSerial = 0;

  ExplorationCard? get _currentCard => _card;

  bool get _isBusy => _loading || _submitting || _awaitingNextCard;

  bool get _canContinue {
    final card = _currentCard;
    if (card == null || _isBusy) {
      return false;
    }
    return card.allowsMultipleSelection
        ? _selectedOptionIds.length == _requiredSelections(card)
        : _selectedOptionIds.length == 1;
  }

  @override
  void initState() {
    super.initState();
    _noteController.addListener(_refresh);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = FiYouRepositoryScope.of(context);
    if (!_startedLoading) {
      _startedLoading = true;
      _loadNextCard();
    }
  }

  @override
  void dispose() {
    _noteController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  int _requiredSelections(ExplorationCard card) {
    if (!card.allowsMultipleSelection) {
      return 1;
    }
    final maxAllowed = math.min(3, card.options.length);
    return card.requiredSelections.clamp(2, maxAllowed).toInt();
  }

  Future<void> _loadNextCard() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final minimumLoading = Future<void>.delayed(
      _minimumExplorationLoadingDuration,
    );

    try {
      final nextCard = await _repository.loadNextExplorationCard();
      await minimumLoading;
      if (!mounted) {
        return;
      }
      setState(() {
        _card = nextCard;
        _selectedOptionIds.clear();
        _noteController.clear();
        _awaitingNextCard = false;
        _loading = false;
        _cardSerial += 1;
      });
    } catch (_) {
      await minimumLoading;
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = '질문을 불러오지 못했어요. 다시 시도해 주세요.';
      });
    }
  }

  Future<void> _submitAnswer() async {
    final card = _currentCard;
    if (card == null || !_canContinue) {
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await _repository.submitExplorationAnswer(
        ExplorationAnswerInput(
          cardId: card.id,
          selectedOptionIds: List.unmodifiable(_selectedOptionIds),
          userNote: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _errorMessage = '응답을 기록하지 못했어요. 선택은 그대로 남겨둘게요.';
      });
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
      _awaitingNextCard = true;
    });
    await _loadNextCard();
  }

  void _toggleOption(ExplorationCardOption option) {
    final card = _currentCard;
    if (card == null || _isBusy) {
      return;
    }

    setState(() {
      if (card.allowsMultipleSelection) {
        if (_selectedOptionIds.contains(option.id)) {
          _selectedOptionIds.remove(option.id);
        } else if (_selectedOptionIds.length < _requiredSelections(card)) {
          _selectedOptionIds.add(option.id);
        }
      } else {
        _selectedOptionIds
          ..clear()
          ..add(option.id);
      }
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = _currentCard;
    final showStatus =
        _loading ||
        card == null ||
        (_awaitingNextCard && _errorMessage != null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _text,
        leading: IconButton(
          tooltip: '닫기',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 210),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 0.035),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
          child: showStatus
              ? _ExplorationStatusView(
                  key: ValueKey('status-${card?.id}-${_errorMessage ?? ''}'),
                  errorMessage: _errorMessage,
                  onRetry: _loading ? null : _loadNextCard,
                )
              : _ExplorationCardView(
                  key: ValueKey('card-${card.id}-$_cardSerial'),
                  card: card,
                  selectedOptionIds: _selectedOptionIds,
                  noteController: _noteController,
                  submitting: _submitting,
                  errorMessage: _errorMessage,
                  canContinue: _canContinue,
                  onSelectOption: _toggleOption,
                  onContinue: _submitAnswer,
                ),
        ),
      ),
    );
  }
}

class _ExplorationStatusView extends StatelessWidget {
  const _ExplorationStatusView({
    required this.errorMessage,
    required this.onRetry,
    super.key,
  });

  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasError) ...[
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: _cyan,
                ),
              ),
              const SizedBox(height: 18),
            ],
            Text(
              hasError ? errorMessage! : '당신을 탐구하기 위해 준비 중 이에요.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 150,
                child: _GlassButton(
                  label: '다시 시도',
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExplorationCardView extends StatelessWidget {
  const _ExplorationCardView({
    required this.card,
    required this.selectedOptionIds,
    required this.noteController,
    required this.submitting,
    required this.errorMessage,
    required this.canContinue,
    required this.onSelectOption,
    required this.onContinue,
    super.key,
  });

  final ExplorationCard card;
  final Set<String> selectedOptionIds;
  final TextEditingController noteController;
  final bool submitting;
  final String? errorMessage;
  final bool canContinue;
  final ValueChanged<ExplorationCardOption> onSelectOption;
  final VoidCallback onContinue;

  bool get _isPriority => card.allowsMultipleSelection;

  int get _requiredSelections {
    if (!_isPriority) {
      return 1;
    }
    final maxAllowed = math.min(3, card.options.length);
    return card.requiredSelections.clamp(2, maxAllowed).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 26),
            children: [
              const SizedBox(height: 18),
              Text(
                card.question,
                style: const TextStyle(
                  color: _text,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  height: 1.32,
                ),
              ),
              if (_isPriority) ...[
                const SizedBox(height: 14),
                Text(
                  '$_requiredSelections개를 선택해 주세요 (${selectedOptionIds.length}/$_requiredSelections)',
                  style: const TextStyle(
                    color: _cyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              for (final option in card.options) ...[
                _ExplorationOptionTile(
                  key: ValueKey('exploration-option-${option.id}'),
                  label: option.label,
                  selected: selectedOptionIds.contains(option.id),
                  multiSelect: _isPriority,
                  onTap: () => onSelectOption(option),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
              _ExplorationNoteField(controller: noteController),
              if (errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            10,
            22,
            MediaQuery.of(context).padding.bottom + 18,
          ),
          child: FiYouLiquidButton(
            key: const ValueKey('exploration-continue'),
            label: submitting ? '이어가는 중' : '계속',
            icon: Icon(
              submitting ? Icons.hourglass_top_rounded : Icons.arrow_forward,
            ),
            onPressed: canContinue ? onContinue : null,
            accentColor: _cyan,
            accentStrength: 0.35,
            borderColor: _cyan.withValues(alpha: 0.32),
          ),
        ),
      ],
    );
  }
}

class _ExplorationOptionTile extends StatelessWidget {
  const _ExplorationOptionTile({
    required this.label,
    required this.selected,
    required this.multiSelect,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FiYouGlass.glassRadiusSmall),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: _glassDecoration(
            radius: FiYouGlass.glassRadiusSmall,
            borderColor: selected ? _cyan.withValues(alpha: 0.52) : null,
          ),
          child: Row(
            children: [
              Icon(
                multiSelect
                    ? selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined
                    : selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? _cyan : _textMuted,
                size: 23,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? _text : _textSoft,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExplorationNoteField extends StatelessWidget {
  const _ExplorationNoteField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(FiYouGlass.glassRadiusSmall),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: FiYouGlass.glassBlurSigma,
          sigmaY: FiYouGlass.glassBlurSigma,
        ),
        child: Container(
          decoration: _glassDecoration(radius: FiYouGlass.glassRadiusSmall),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: _textMuted),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '생각 남기기 (선택)',
                      style: TextStyle(
                        color: _textSoft,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                minLines: 4,
                maxLines: 6,
                maxLength: 300,
                style: const TextStyle(
                  color: _text,
                  fontSize: 14,
                  height: 1.45,
                ),
                cursorColor: _cyan,
                decoration: const InputDecoration(
                  hintText: '필수는 아니에요. 떠오르는 생각이 있다면 남겨보세요.',
                  hintStyle: TextStyle(color: _textMuted),
                  counterStyle: TextStyle(color: _textMuted),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionFlowScreen extends StatefulWidget {
  const QuestionFlowScreen({
    this.initialQuestionTitle,
    this.onAnswersSaved,
    this.onOpenUMap,
    super.key,
  });

  final String? initialQuestionTitle;
  final ExploreAnswersSaved? onAnswersSaved;
  final VoidCallback? onOpenUMap;

  @override
  State<QuestionFlowScreen> createState() => _QuestionFlowScreenState();
}

class _QuestionFlowScreenState extends State<QuestionFlowScreen> {
  final _textController = TextEditingController();
  final _mixedTextController = TextEditingController();
  final List<String> _answers = [];

  int _stepIndex = 0;
  String? _selectedChoice;
  bool _saving = false;

  late final List<_QuestionStep> _steps = [
    _questionSteps.first.copyWith(title: widget.initialQuestionTitle),
    ..._questionSteps.skip(1),
  ];

  _QuestionStep get _step => _steps[_stepIndex];

  bool get _canContinue {
    if (_saving) {
      return false;
    }
    return switch (_step.type) {
      _AnswerType.choice => _selectedChoice != null,
      _AnswerType.text => _textController.text.trim().isNotEmpty,
      _AnswerType.mixed => _selectedChoice != null,
    };
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(_refresh);
  }

  @override
  void dispose() {
    _textController
      ..removeListener(_refresh)
      ..dispose();
    _mixedTextController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _continue() async {
    if (!_canContinue) {
      return;
    }

    _answers.add(_currentAnswer);

    if (_stepIndex < _steps.length - 1) {
      setState(() {
        _stepIndex += 1;
        _selectedChoice = null;
        _textController.clear();
        _mixedTextController.clear();
      });
      return;
    }

    setState(() => _saving = true);
    try {
      await (widget.onAnswersSaved?.call(List.unmodifiable(_answers)) ??
          Future<void>.delayed(const Duration(milliseconds: 260)));
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => QuestionCompleteScreen(
            answers: List.unmodifiable(_answers),
            onOpenUMap: widget.onOpenUMap,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String get _currentAnswer {
    return switch (_step.type) {
      _AnswerType.choice => _selectedChoice!,
      _AnswerType.text => _textController.text.trim(),
      _AnswerType.mixed => [
        _selectedChoice!,
        if (_mixedTextController.text.trim().isNotEmpty)
          _mixedTextController.text.trim(),
      ].join(' / '),
    };
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_stepIndex + 1) / _steps.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _text,
        title: const Text('오늘의 질문'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                children: [
                  Row(
                    children: [
                      Text(
                        '질문 ${_stepIndex + 1}/${_steps.length}',
                        style: const TextStyle(
                          color: _cyan,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '예상 3분',
                        style: TextStyle(color: _textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: FiYouGlass.glassFill,
                      valueColor: const AlwaysStoppedAnimation(_cyan),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _QuestionCard(step: _step),
                  const SizedBox(height: 18),
                  _AnswerArea(
                    step: _step,
                    selectedChoice: _selectedChoice,
                    textController: _textController,
                    mixedTextController: _mixedTextController,
                    onSelect: (value) =>
                        setState(() => _selectedChoice = value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                10,
                22,
                MediaQuery.of(context).padding.bottom + 18,
              ),
              child: SizedBox(
                width: double.infinity,
                child: _GlassButton(
                  label: _saving
                      ? '기록하는 중'
                      : _stepIndex == _steps.length - 1
                      ? '답변 저장'
                      : '다음 질문',
                  icon: _stepIndex == _steps.length - 1
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  onPressed: _canContinue ? _continue : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionCompleteScreen extends StatelessWidget {
  const QuestionCompleteScreen({
    required this.answers,
    this.onOpenUMap,
    super.key,
  });

  final List<String> answers;
  final VoidCallback? onOpenUMap;

  @override
  Widget build(BuildContext context) {
    final firstAnswer = answers.isEmpty ? '오늘의 반응' : answers.first;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
          children: [
            const ExploreSparkIcon(color: _mint, size: 52),
            const SizedBox(height: 20),
            const Text(
              '단서 발견',
              style: TextStyle(
                color: _text,
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '오늘의 답변은 기록으로 남겨졌어요. 아직 고정된 결론은 아니며, 다음 기록과 함께 더 살펴볼 작은 단서예요.',
              style: TextStyle(color: _textSoft, fontSize: 14, height: 1.55),
            ),
            const SizedBox(height: 22),
            _GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘 발견된 단서',
                    style: TextStyle(
                      color: _mint,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    firstAnswer,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '갈등 장면에서 어떤 기준을 먼저 붙잡는지 탐구해볼 수 있는 단서가 남았어요.',
                    style: TextStyle(
                      color: _textSoft,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _ReflectionStrip(),
            const SizedBox(height: 24),
            _GlassButton(
              label: '다른 질문 이어가기',
              icon: Icons.refresh_rounded,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => QuestionFlowScreen(onOpenUMap: onOpenUMap),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FiYouLiquidButton(
              label: 'U-Map',
              icon: const Icon(Icons.map_outlined),
              onPressed: () {
                onOpenUMap?.call();
                Navigator.of(context).pop();
              },
              height: 52,
              fontSize: 14,
            ),
            const SizedBox(height: 8),
            FiYouLiquidButton(
              label: 'Close',
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
              height: 52,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.step});

  final _QuestionStep step;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.travel_explore_rounded, color: _cyan, size: 19),
              SizedBox(width: 8),
              Text(
                '정답보다 가까운 반응',
                style: TextStyle(
                  color: _cyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            step.title,
            style: const TextStyle(
              color: _text,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            step.description,
            style: const TextStyle(
              color: _textSoft,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerArea extends StatelessWidget {
  const _AnswerArea({
    required this.step,
    required this.selectedChoice,
    required this.textController,
    required this.mixedTextController,
    required this.onSelect,
  });

  final _QuestionStep step;
  final String? selectedChoice;
  final TextEditingController textController;
  final TextEditingController mixedTextController;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return switch (step.type) {
      _AnswerType.choice => _ChoiceList(
        options: step.options,
        selectedChoice: selectedChoice,
        onSelect: onSelect,
      ),
      _AnswerType.text => _TextAnswer(controller: textController),
      _AnswerType.mixed => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChoiceList(
            options: step.options,
            selectedChoice: selectedChoice,
            onSelect: onSelect,
          ),
          const SizedBox(height: 14),
          _TextAnswer(
            controller: mixedTextController,
            label: '이유를 조금 더 적어볼까요?',
            minLines: 4,
          ),
        ],
      ),
    };
  }
}

class _ChoiceList extends StatelessWidget {
  const _ChoiceList({
    required this.options,
    required this.selectedChoice,
    required this.onSelect,
  });

  final List<String> options;
  final String? selectedChoice;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in options) ...[
          _ChoiceTile(
            label: option,
            selected: option == selectedChoice,
            onTap: () => onSelect(option),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FiYouGlass.glassRadiusSmall),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: _glassDecoration(radius: FiYouGlass.glassRadiusSmall),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? _cyan : _textMuted,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? _text : _textSoft,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextAnswer extends StatelessWidget {
  const _TextAnswer({
    required this.controller,
    this.label = '짧게 적어도 충분해요.',
    this.minLines = 6,
  });

  final TextEditingController controller;
  final String label;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _text,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(FiYouGlass.glassRadiusSmall),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: FiYouGlass.glassBlurSigma,
              sigmaY: FiYouGlass.glassBlurSigma,
            ),
            child: TextField(
              controller: controller,
              minLines: minLines,
              maxLines: 10,
              style: const TextStyle(color: _text, fontSize: 14, height: 1.45),
              cursorColor: _cyan,
              decoration: InputDecoration(
                hintText: '떠오르는 장면이나 감정을 편하게 남겨주세요.',
                hintStyle: const TextStyle(color: _textMuted),
                filled: true,
                fillColor: FiYouGlass.glassFill,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    FiYouGlass.glassRadiusSmall,
                  ),
                  borderSide: const BorderSide(
                    color: FiYouGlass.glassStrokeSide,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    FiYouGlass.glassRadiusSmall,
                  ),
                  borderSide: const BorderSide(
                    color: FiYouGlass.glassStrokeTop,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      transparent: true,
      v5Preset: FiYouGlassV5Preset.large,
      child: child,
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: _glassDecoration(radius: FiYouGlass.glassRadiusSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _text,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(color: _textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowListItem extends StatelessWidget {
  const _FlowListItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primarySoft, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textSoft,
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: _glassDecoration(radius: 999),
      child: Text(
        label,
        style: const TextStyle(
          color: _primarySoft,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QuestionStartButton extends StatelessWidget {
  const _QuestionStartButton({required this.onPressed, this.label = '탐구 시작하기'});

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FiYouSettingsActionButton(
      label: label,
      icon: const Icon(Icons.auto_awesome_rounded),
      onPressed: onPressed,
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FiYouSettingsActionButton(
      label: label,
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}

class ExploreSparkIcon extends StatelessWidget {
  const ExploreSparkIcon({required this.color, required this.size, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _ExploreSparkIconPainter(color)),
    );
  }
}

class _RingedPlanetIcon extends StatelessWidget {
  const _RingedPlanetIcon({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _RingedPlanetIconPainter(color)),
    );
  }
}

class _RingedPlanetIconPainter extends CustomPainter {
  const _RingedPlanetIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final coreRadius = shortest * 0.22;
    final ringRect = Rect.fromCenter(
      center: center,
      width: shortest * 0.88,
      height: shortest * 0.34,
    );
    final bright = Color.lerp(color, Colors.white, 0.42)!;

    canvas.drawCircle(
      center,
      coreRadius * 1.8,
      Paint()
        ..color = color.withValues(alpha: 0.13)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shortest * 0.12),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 8);
    canvas.translate(-center.dx, -center.dy);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, shortest * 0.07)
      ..strokeCap = StrokeCap.round
      ..color = bright.withValues(alpha: 0.86);
    canvas.drawOval(ringRect, ringPaint);

    final backMaskPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.2, shortest * 0.09)
      ..strokeCap = StrokeCap.round
      ..color = _surface.withValues(alpha: 0.88);
    canvas.drawArc(
      ringRect,
      math.pi * 0.05,
      math.pi * 0.9,
      false,
      backMaskPaint,
    );

    final frontRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, shortest * 0.07)
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      ringRect,
      math.pi * 0.05,
      math.pi * 0.9,
      false,
      frontRingPaint,
    );
    canvas.restore();

    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.45),
          radius: 0.9,
          colors: [bright, color, color.withValues(alpha: 0.68)],
          stops: const [0, 0.58, 1],
        ).createShader(Rect.fromCircle(center: center, radius: coreRadius)),
    );
    canvas.drawCircle(
      Offset(center.dx + coreRadius * 0.35, center.dy + coreRadius * 0.25),
      coreRadius * 0.16,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant _RingedPlanetIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ExploreSparkIconPainter extends CustomPainter {
  const _ExploreSparkIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    final center = Offset(size.width * 0.48, size.height * 0.52);
    final bright = Color.lerp(color, Colors.white, 0.55)!;
    final main = _sparkPath(center, shortest * 0.36, shortest * 0.12);
    canvas.drawPath(
      main,
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shortest * 0.12),
    );
    canvas.drawPath(main, Paint()..color = color);
    canvas.drawPath(
      main,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeJoin = StrokeJoin.round
        ..color = bright.withValues(alpha: 0.7),
    );
    _drawSmall(
      canvas,
      Offset(size.width * 0.76, size.height * 0.24),
      shortest * 0.12,
      bright,
    );
    _drawSmall(
      canvas,
      Offset(size.width * 0.24, size.height * 0.72),
      shortest * 0.09,
      color,
    );
  }

  Path _sparkPath(Offset center, double longRadius, double shortRadius) {
    return Path()
      ..moveTo(center.dx, center.dy - longRadius)
      ..quadraticBezierTo(
        center.dx + shortRadius * 0.62,
        center.dy - shortRadius * 0.62,
        center.dx + longRadius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + shortRadius * 0.62,
        center.dy + shortRadius * 0.62,
        center.dx,
        center.dy + longRadius,
      )
      ..quadraticBezierTo(
        center.dx - shortRadius * 0.62,
        center.dy + shortRadius * 0.62,
        center.dx - longRadius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - shortRadius * 0.62,
        center.dy - shortRadius * 0.62,
        center.dx,
        center.dy - longRadius,
      )
      ..close();
  }

  void _drawSmall(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawPath(
      _sparkPath(center, radius, radius * 0.35),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _ExploreSparkIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ReflectionStrip extends StatelessWidget {
  const _ReflectionStrip();

  @override
  Widget build(BuildContext context) {
    return const _GlassPanel(
      child: Row(
        children: [
          Icon(Icons.map_outlined, color: _cyan),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'U-Map에 반영돼요. 질문과 Diary가 쌓이면 자기이해 영역의 흐름이 선명해져요.',
              style: TextStyle(color: _textSoft, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _glassDecoration({required double radius, Color? borderColor}) {
  return FiYouGlass.ctaGlassV5(radius: radius, borderColor: borderColor);
}

enum _AnswerType { choice, text, mixed }

class _QuestionStep {
  const _QuestionStep({
    required this.type,
    required this.title,
    required this.description,
    this.options = const [],
  });

  final _AnswerType type;
  final String title;
  final String description;
  final List<String> options;

  _QuestionStep copyWith({String? title}) {
    return _QuestionStep(
      type: type,
      title: title ?? this.title,
      description: description,
      options: options,
    );
  }
}

const _questionSteps = [
  _QuestionStep(
    type: _AnswerType.choice,
    title: '갈등 상황에서 나는 먼저 무엇을 붙잡으려 할까?',
    description: '가장 가까운 반응 하나를 골라주세요. 선택은 성향을 확정하지 않고 다음 기록의 단서로만 남아요.',
    options: [
      '내 감정을 먼저 정리한다',
      '상대의 입장을 먼저 확인한다',
      '상황의 맥락을 다시 본다',
      '잠시 거리를 두고 생각한다',
    ],
  ),
  _QuestionStep(
    type: _AnswerType.text,
    title: '최근 비슷한 장면이 있었다면 어떤 순간이었나요?',
    description: '길게 쓰지 않아도 괜찮아요. 떠오르는 장면 한두 문장만 남겨도 충분해요.',
  ),
  _QuestionStep(
    type: _AnswerType.mixed,
    title: '그때 나에게 가장 가까웠던 마음은 무엇인가요?',
    description: '선택은 흐름의 방향을 돕고, 짧은 문장은 그 이유를 더 선명하게 남겨줘요.',
    options: ['정리하고 싶었어요', '이해하고 싶었어요', '확인하고 싶었어요', '표현하고 싶었어요'],
  ),
];
