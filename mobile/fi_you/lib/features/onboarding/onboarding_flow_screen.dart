import 'dart:async';

import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnboardingProfileSubmit =
    Future<void> Function(OnboardingProfileDraft profile);
typedef OnboardingAnswersSubmit =
    Future<void> Function(OnboardingResult result);

enum OnboardingStep { profile, ready, questions, feedback }

class OnboardingProfileDraft {
  const OnboardingProfileDraft({required this.nickname, this.birthDate});

  final String nickname;
  final DateTime? birthDate;
}

class OnboardingAnswer {
  const OnboardingAnswer({
    required this.questionId,
    required this.prompt,
    required this.selectedOption,
    this.note,
  });

  final String questionId;
  final String prompt;
  final String selectedOption;
  final String? note;
}

class OnboardingResult {
  const OnboardingResult({required this.profile, required this.answers});

  final OnboardingProfileDraft profile;
  final List<OnboardingAnswer> answers;

  List<String> toRepositoryAnswerStrings() {
    return answers
        .map((answer) {
          final note = answer.note?.trim();
          return note?.isNotEmpty == true
              ? '${answer.selectedOption} / $note'
              : answer.selectedOption;
        })
        .toList(growable: false);
  }
}

class OnboardingQuestion {
  const OnboardingQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    this.allowsNote = false,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final bool allowsNote;
}

const fiYouOnboardingQuestions = [
  OnboardingQuestion(
    id: 'first-clue-focus',
    prompt: '요즘 나를 더 알고 싶다고 느끼는 순간은 언제인가요?',
    options: [
      '관계에서 반복되는 마음을 볼 때',
      '선택 앞에서 자주 망설일 때',
      '감정이 커지는 이유가 궁금할 때',
      '내가 원하는 방향을 정리하고 싶을 때',
      '이유 없이 나를 더 알고 싶을 때',
    ],
  ),
  OnboardingQuestion(
    id: 'current-pace',
    prompt: '지금의 자기탐색 속도는 어느 쪽에 가까운가요?',
    options: [
      '천천히 부담 없이 시작하고 싶어요',
      '짧은 질문으로 감을 잡고 싶어요',
      '기록을 쌓으며 흐름을 보고 싶어요',
      '조금 깊게 들여다볼 준비가 되었어요',
      '아직은 잘 모르겠어요',
    ],
  ),
  OnboardingQuestion(
    id: 'answer-style',
    prompt: '질문에 답할 때 편한 방식은 무엇인가요?',
    options: ['가까운 선택지를 고르는 방식', '내 말로 짧게 덧붙이는 방식'],
  ),
  OnboardingQuestion(
    id: 'umap-expectation',
    prompt: 'U-Map에서 먼저 보고 싶은 것은 무엇인가요?',
    options: ['요즘 자주 드러나는 마음의 방향', '기록이 쌓이며 바뀌는 흐름'],
  ),
  OnboardingQuestion(
    id: 'next-discovery',
    prompt: '다음 질문들이 어떤 방향으로 이어지면 좋을까요?',
    options: [
      '관계와 거리감',
      '감정과 회복',
      '선택과 실행',
      '일상 루틴과 에너지',
      'My Universe가 제안해주면 좋겠어요',
    ],
    allowsNote: true,
  ),
];

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({
    this.initialStep = OnboardingStep.profile,
    this.onProfileSubmit,
    this.onAnswersSubmit,
    this.onComplete,
    this.onBack,
    this.questions = fiYouOnboardingQuestions,
    super.key,
  });

  final OnboardingStep initialStep;
  final OnboardingProfileSubmit? onProfileSubmit;
  final OnboardingAnswersSubmit? onAnswersSubmit;
  final VoidCallback? onComplete;
  final VoidCallback? onBack;
  final List<OnboardingQuestion> questions;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late OnboardingStep _step = widget.initialStep;
  OnboardingProfileDraft? _profile;
  List<OnboardingAnswer> _answers = const [];
  bool _saving = false;
  String? _notice;

  Future<void> _submitProfile(OnboardingProfileDraft profile) async {
    setState(() {
      _saving = true;
      _notice = null;
    });
    try {
      await widget.onProfileSubmit?.call(profile);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _step = OnboardingStep.ready;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _notice = '프로필을 저장하지 못했어요. 잠시 후 다시 시도해 주세요.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submitAnswers(List<OnboardingAnswer> answers) async {
    final profile = _profile;
    if (profile == null) {
      setState(() {
        _step = OnboardingStep.profile;
        _notice = '프로필을 먼저 알려주세요.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _notice = null;
    });
    try {
      final result = OnboardingResult(profile: profile, answers: answers);
      await widget.onAnswersSubmit?.call(result);
      if (!mounted) return;
      setState(() {
        _answers = List.unmodifiable(answers);
        _step = OnboardingStep.feedback;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _notice = '첫 단서를 저장하지 못했어요. 연결 상태를 확인해 주세요.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _goBack() {
    setState(() => _notice = null);
    switch (_step) {
      case OnboardingStep.profile:
        widget.onBack?.call();
      case OnboardingStep.ready:
        setState(() => _step = OnboardingStep.profile);
      case OnboardingStep.questions:
        setState(() => _step = OnboardingStep.ready);
      case OnboardingStep.feedback:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.questions.isEmpty
        ? fiYouOnboardingQuestions
        : widget.questions;
    return switch (_step) {
      OnboardingStep.profile => _ProfileStep(
        saving: _saving,
        notice: _notice,
        onBack: widget.onBack,
        onComplete: _submitProfile,
      ),
      OnboardingStep.ready => _ReadyStep(
        onBack: _goBack,
        onStart: () => setState(() => _step = OnboardingStep.questions),
      ),
      OnboardingStep.questions => _QuestionStep(
        questions: questions,
        saving: _saving,
        notice: _notice,
        onBack: _goBack,
        onComplete: _submitAnswers,
      ),
      OnboardingStep.feedback => _FeedbackStep(
        answerCount: _answers.length,
        onContinue: widget.onComplete ?? () {},
      ),
    };
  }
}

class _ProfileStep extends StatefulWidget {
  const _ProfileStep({
    required this.onComplete,
    this.onBack,
    this.saving = false,
    this.notice,
  });

  final ValueChanged<OnboardingProfileDraft> onComplete;
  final VoidCallback? onBack;
  final bool saving;
  final String? notice;

  @override
  State<_ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends State<_ProfileStep> {
  final _nickname = TextEditingController();
  final _year = TextEditingController();
  final _month = TextEditingController();
  final _day = TextEditingController();

  bool get _canSubmit => _nickname.text.trim().isNotEmpty && !widget.saving;

  DateTime? get _birthDate {
    final year = int.tryParse(_year.text);
    final month = int.tryParse(_month.text);
    final day = int.tryParse(_day.text);
    if (year == null || month == null || day == null) return null;
    final value = DateTime(year, month, day);
    if (value.year != year || value.month != month || value.day != day) {
      return null;
    }
    return value;
  }

  @override
  void initState() {
    super.initState();
    for (final controller in [_nickname, _year, _month, _day]) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nickname.dispose();
    _year.dispose();
    _month.dispose();
    _day.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: '프로필 설정',
      onBack: widget.onBack,
      bottom: FiYouLiquidButton(
        label: widget.saving
            ? '프로필 저장 중'
            : _canSubmit
            ? 'MY UNIVERSE 시작하기'
            : '닉네임을 입력해 주세요',
        icon: Icon(_canSubmit ? Icons.arrow_forward_rounded : Icons.edit),
        onPressed: _canSubmit
            ? () => widget.onComplete(
                OnboardingProfileDraft(
                  nickname: _nickname.text.trim(),
                  birthDate: _birthDate,
                ),
              )
            : null,
      ),
      children: [
        const _HeroCopy(
          eyebrow: 'First clue',
          title: '나를 부를 이름을 먼저 알려주세요.',
          body: '생년월일은 선택 입력이에요. 이후 질문과 기록을 조금 더 섬세하게 맞추기 위한 참고 정보로만 사용합니다.',
        ),
        const SizedBox(height: 22),
        FiYouGlassSurface(
          padding: const EdgeInsets.all(18),
          radius: FiYouGlass.glassRadiusCard,
          v5Preset: FiYouGlassV5Preset.large,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('닉네임'),
              const SizedBox(height: 8),
              _TextField(controller: _nickname, hintText: '예: User'),
              const SizedBox(height: 18),
              const _Label('생년월일', helper: '선택 입력입니다. 비워도 시작할 수 있어요.'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _TextField(
                      controller: _year,
                      hintText: 'YYYY',
                      maxLength: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TextField(
                      controller: _month,
                      hintText: 'MM',
                      maxLength: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TextField(
                      controller: _day,
                      hintText: 'DD',
                      maxLength: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _SafetyNote(),
        if (widget.notice != null) ...[
          const SizedBox(height: 12),
          _StatusText(widget.notice!, isError: true),
        ],
      ],
    );
  }
}

class _ReadyStep extends StatelessWidget {
  const _ReadyStep({required this.onStart, this.onBack});

  final VoidCallback onStart;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: '첫 단서 준비',
      onBack: onBack,
      bottom: FiYouLiquidButton(
        label: '첫 질문 시작하기',
        icon: const Icon(Icons.arrow_forward_rounded),
        onPressed: onStart,
        accentColor: FiYouGlass.gold,
        accentStrength: 0.45,
        borderColor: FiYouGlass.gold.withValues(alpha: 0.34),
      ),
      children: const [
        SizedBox(height: 34),
        Center(child: _OnboardingLogo(size: 118)),
        SizedBox(height: 28),
        _HeroCopy(
          eyebrow: 'MY UNIVERSE starts here',
          title: '좋아요. 이제 첫 단서를 골라볼까요?',
          body: '다섯 개의 짧은 질문으로 시작해요. 정답을 찾는 과정이 아니라, 지금 가까운 반응을 남기는 시간입니다.',
          centered: true,
        ),
        SizedBox(height: 20),
        _SoftLine(
          text: '질문은 사용자를 분류하거나 진단하지 않아요. 오늘의 자기탐색을 시작하기 위한 첫 기록으로만 다룹니다.',
        ),
      ],
    );
  }
}

class _QuestionStep extends StatefulWidget {
  const _QuestionStep({
    required this.questions,
    required this.onComplete,
    this.onBack,
    this.saving = false,
    this.notice,
  });

  final List<OnboardingQuestion> questions;
  final ValueChanged<List<OnboardingAnswer>> onComplete;
  final VoidCallback? onBack;
  final bool saving;
  final String? notice;

  @override
  State<_QuestionStep> createState() => _QuestionStepState();
}

class _QuestionStepState extends State<_QuestionStep> {
  final _note = TextEditingController();
  final _answers = <OnboardingAnswer>[];
  int _index = 0;
  String? _selected;

  OnboardingQuestion get _question => widget.questions[_index];
  bool get _isLast => _index == widget.questions.length - 1;
  bool get _canContinue => _selected != null && !widget.saving;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _continue() {
    final selected = _selected;
    if (selected == null) return;
    final answer = OnboardingAnswer(
      questionId: _question.id,
      prompt: _question.prompt,
      selectedOption: selected,
      note: _question.allowsNote ? _note.text.trim() : null,
    );
    final next = [..._answers, answer];
    if (_isLast) {
      widget.onComplete(List.unmodifiable(next));
      return;
    }
    setState(() {
      _answers
        ..clear()
        ..addAll(next);
      _index += 1;
      _selected = null;
      _note.clear();
    });
  }

  void _back() {
    if (_index == 0) {
      widget.onBack?.call();
      return;
    }
    setState(() {
      _index -= 1;
      final previous = _answers.removeLast();
      _selected = previous.selectedOption;
      _note.text = previous.note ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: '첫 단서 ${_index + 1} / ${widget.questions.length}',
      onBack: _back,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FiYouLiquidButton(
            label: widget.saving
                ? '저장 중'
                : !_canContinue
                ? '가까운 쪽을 골라주세요'
                : _isLast
                ? '첫 단서 저장하기'
                : '다음 질문',
            icon: Icon(_isLast ? Icons.check_rounded : Icons.arrow_forward),
            onPressed: _canContinue ? _continue : null,
          ),
          if (widget.notice != null) ...[
            const SizedBox(height: 10),
            _StatusText(widget.notice!, isError: true),
          ],
        ],
      ),
      children: [
        Text(
          '질문 ${_index + 1}/${widget.questions.length}',
          style: const TextStyle(
            color: FiYouGlass.cyan,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (_index + 1) / widget.questions.length,
          minHeight: 5,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation(FiYouGlass.cyan),
        ),
        const SizedBox(height: 22),
        _HeroCopy(
          eyebrow: _isLast ? '다음 탐색 방향' : '첫 단서',
          title: _question.prompt,
          body: '지금 가장 가까운 쪽이면 충분해요.',
        ),
        const SizedBox(height: 18),
        for (final option in _question.options) ...[
          _OptionRow(
            label: option,
            selected: _selected == option,
            onTap: () => setState(() => _selected = option),
          ),
          const SizedBox(height: 10),
        ],
        if (_question.allowsNote) ...[
          const SizedBox(height: 8),
          _TextField(
            controller: _note,
            hintText: '선택 이유를 조금 더 남기고 싶다면 적어주세요.',
            minLines: 3,
            maxLines: 5,
          ),
        ],
      ],
    );
  }
}

class _FeedbackStep extends StatefulWidget {
  const _FeedbackStep({required this.onContinue, this.answerCount = 5});

  static const duration = Duration(milliseconds: 4300);

  final VoidCallback onContinue;
  final int answerCount;

  @override
  State<_FeedbackStep> createState() => _FeedbackStepState();
}

class _FeedbackStepState extends State<_FeedbackStep> {
  static const _messages = [
    '첫 선택들이 U-Map의 바탕을 조금씩 밝히고 있어요.',
    '아직 결론이 아니라, 다음 질문을 고르는 단서로 정리하는 중이에요.',
    '곧 Home에서 이어갈 자기탐색 흐름을 보여드릴게요.',
  ];

  Timer? _timer;
  Timer? _completeTimer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1300), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1).clamp(0, _messages.length - 1));
    });
    _completeTimer = Timer(_FeedbackStep.duration, widget.onContinue);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _completeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _OnboardingLogo(size: 128),
              const SizedBox(height: 30),
              const _HeroCopy(
                eyebrow: 'MY UNIVERSE reflection',
                title: '첫 단서가 U-Map에 반영되는 중이에요.',
                body:
                    'My Universe는 지금의 답을 고정된 유형으로 판단하지 않아요. 다음 탐색을 조금 더 섬세하게 이어가기 위한 출발점으로만 다룹니다.',
                centered: true,
              ),
              const SizedBox(height: 22),
              _SoftLine(text: _messages[_index]),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingScaffold extends StatelessWidget {
  const _OnboardingScaffold({
    required this.title,
    required this.children,
    this.bottom,
    this.onBack,
  });

  final String title;
  final List<Widget> children;
  final Widget? bottom;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    if (onBack != null)
                      FiYouLiquidIconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        label: '이전',
                        onPressed: onBack,
                      )
                    else
                      const SizedBox(width: 44),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: FiYouGlass.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
                children: children,
              ),
            ),
            if (bottom != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  22,
                  10,
                  22,
                  MediaQuery.of(context).padding.bottom + 18,
                ),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingLogo extends StatelessWidget {
  const _OnboardingLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        'assets/images/my_universe_logo_symbol.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.eyebrow,
    required this.title,
    required this.body,
    this.centered = false,
  });

  final String eyebrow;
  final String title;
  final String body;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          textAlign: align,
          style: const TextStyle(
            color: FiYouGlass.cyan,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          title,
          textAlign: align,
          style: const TextStyle(
            color: FiYouGlass.text,
            fontSize: 24,
            height: 1.22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          textAlign: align,
          style: const TextStyle(
            color: FiYouGlass.textSoft,
            fontSize: 14,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.label, {this.helper});

  final String label;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: FiYouGlass.text,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper!,
            style: const TextStyle(
              color: FiYouGlass.textMuted,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hintText,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final int? maxLength;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: maxLength == null
          ? TextInputType.text
          : TextInputType.number,
      inputFormatters: maxLength == null
          ? null
          : [FilteringTextInputFormatter.digitsOnly],
      cursorColor: FiYouGlass.nativeBarAccent,
      style: const TextStyle(color: FiYouGlass.text, fontSize: 15),
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFD8DEF0)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FiYouGlass.glassRadiusSmall),
          borderSide: const BorderSide(color: FiYouGlass.glassStrokeSide),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FiYouGlass.glassRadiusSmall),
          borderSide: const BorderSide(color: FiYouGlass.glassStrokeSide),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FiYouGlass.glassRadiusSmall),
          borderSide: const BorderSide(color: FiYouGlass.glassStrokeTop),
        ),
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: const EdgeInsets.all(15),
      radius: FiYouGlass.glassRadiusSmall,
      v5Preset: FiYouGlassV5Preset.small,
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: FiYouGlass.gold, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '이 정보는 사용자를 분류하거나 진단하기 위한 것이 아니에요. 질문과 기록의 표현을 더 섬세하게 맞추기 위한 참고 단서로만 사용합니다.',
              style: TextStyle(
                color: FiYouGlass.textSoft,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      radius: FiYouGlass.glassRadiusSmall,
      v5Preset: FiYouGlassV5Preset.small,
      borderColor: selected ? FiYouGlass.cyan : null,
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? FiYouGlass.text : FiYouGlass.textSoft,
                fontSize: 14,
                height: 1.35,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? FiYouGlass.cyan : FiYouGlass.textMuted,
            size: selected ? 20 : 18,
          ),
        ],
      ),
    );
  }
}

class _SoftLine extends StatelessWidget {
  const _SoftLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: FiYouGlass.glassRadiusSmall,
      v5Preset: FiYouGlassV5Preset.small,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: FiYouGlass.textSoft,
          fontSize: 13,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText(this.text, {required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isError ? const Color(0xFFFFB4AB) : FiYouGlass.textMuted,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
