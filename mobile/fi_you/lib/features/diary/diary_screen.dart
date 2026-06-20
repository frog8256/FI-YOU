import 'dart:ui';

import 'package:flutter/material.dart';

const _background = Color(0xFF050714);
const _surface = Color(0xFF0D1424);
const _line = Color(0xFF25334E);
const _gold = Color(0xFFF7C948);
const _mint = Color(0xFF6EE7B7);
const _text = Color(0xFFF8FAFC);
const _softText = Color(0xFFB7C0D7);
const _mutedText = Color(0xFF7F8AA6);
const _headerTitleSize = 19.0;

typedef DiaryEntrySaveCallback = Future<void> Function(DiaryDraft draft);

class DiaryEntryData {
  const DiaryEntryData({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.body,
    this.people,
  });

  final String id;
  final DateTime createdAt;
  final String title;
  final String body;
  final String? people;

  bool get canEdit => DateTime.now().isBefore(editableUntil);

  DateTime get editableUntil {
    final nextDay = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day + 1,
    );
    return DateTime(nextDay.year, nextDay.month, nextDay.day, 9);
  }

  String get yearLabel => '${createdAt.year}년';

  String get dateLabel => '${createdAt.month}월 ${createdAt.day}일';

  String get editWindowLabel =>
      canEdit ? '내일 오전 9시까지 수정 가능' : '수정 마감 · 기록으로 반영됨';
}

class DiaryDraft {
  const DiaryDraft({
    this.id,
    required this.title,
    required this.body,
    this.people,
  });

  final String? id;
  final String title;
  final String body;
  final String? people;
}

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({
    this.initialEntries,
    this.onCreate,
    this.onUpdate,
    this.onSavedForUMap,
    super.key,
  });

  final List<DiaryEntryData>? initialEntries;
  final DiaryEntrySaveCallback? onCreate;
  final DiaryEntrySaveCallback? onUpdate;
  final VoidCallback? onSavedForUMap;

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late List<DiaryEntryData> _entries;
  var _loading = true;
  Object? _error;
  String? _savedFeedback;

  @override
  void initState() {
    super.initState();
    _entries = List<DiaryEntryData>.of(
      widget.initialEntries ?? _buildSampleEntries(),
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
    } catch (error) {
      _error = error;
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        titleSpacing: 20,
        title: const _DiaryHeaderTitle(),
      ),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 84),
        child: FloatingActionButton.extended(
          backgroundColor: _gold,
          foregroundColor: const Color(0xFF171104),
          onPressed: () => _openEditor(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('작성하기'),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const _DiaryLoadingState();
    }
    if (_error != null) {
      return _DiaryErrorState(onRetry: _load);
    }
    if (_entries.isEmpty) {
      return _DiaryEmptyState(onWrite: _openEditor);
    }

    return RefreshIndicator(
      color: _gold,
      backgroundColor: _surface,
      onRefresh: _load,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 148),
        children: [
          _DiaryIntro(savedFeedback: _savedFeedback),
          const SizedBox(height: 18),
          for (final entry in _entries) ...[
            _DiaryEntryCard(
              entry: entry,
              onTap: () => _showEntryDetail(entry),
              onEdit: entry.canEdit ? () => _openEditor(entry: entry) : null,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<void> _openEditor({DiaryEntryData? entry}) async {
    final draft = await Navigator.of(context).push<DiaryDraft>(
      MaterialPageRoute(builder: (_) => DiaryWriteScreen(entry: entry)),
    );
    if (!mounted || draft == null) {
      return;
    }

    try {
      if (draft.id == null) {
        await widget.onCreate?.call(draft);
        if (!mounted) {
          return;
        }
        _insertEntry(draft);
      } else {
        await widget.onUpdate?.call(draft);
        if (!mounted) {
          return;
        }
        _replaceEntry(draft);
      }

      widget.onSavedForUMap?.call();
      const message = 'Diary가 저장되었어요. U-Map 단서에 반영될 준비가 되었어요.';
      setState(() => _savedFeedback = message);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF102238),
          content: Text(message),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장하지 못했어요. 잠시 뒤 다시 시도해주세요.')),
      );
    }
  }

  Future<void> _showEntryDetail(DiaryEntryData entry) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DiaryEntryDetailSheet(
          entry: entry,
          onEdit: entry.canEdit
              ? () {
                  Navigator.of(context).pop();
                  _openEditor(entry: entry);
                }
              : null,
        );
      },
    );
  }

  void _insertEntry(DiaryDraft draft) {
    setState(() {
      _entries.insert(
        0,
        DiaryEntryData(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          createdAt: DateTime.now(),
          title: draft.title.trim().isEmpty ? '오늘의 Diary' : draft.title.trim(),
          body: draft.body.trim(),
          people: _blankToNull(draft.people),
        ),
      );
    });
  }

  void _replaceEntry(DiaryDraft draft) {
    final index = _entries.indexWhere((entry) => entry.id == draft.id);
    if (index == -1) {
      return;
    }
    setState(() {
      final current = _entries[index];
      _entries[index] = DiaryEntryData(
        id: current.id,
        createdAt: current.createdAt,
        title: draft.title.trim().isEmpty ? '오늘의 Diary' : draft.title.trim(),
        body: draft.body.trim(),
        people: _blankToNull(draft.people),
      );
    });
  }
}

class _DiaryHeaderTitle extends StatelessWidget {
  const _DiaryHeaderTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.edit_note_rounded, color: _gold, size: 25),
        SizedBox(width: 8),
        Text(
          'Diary',
          style: TextStyle(
            color: _text,
            fontSize: _headerTitleSize,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class DiaryWriteScreen extends StatefulWidget {
  const DiaryWriteScreen({this.entry, super.key});

  final DiaryEntryData? entry;

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _peopleController;
  late final TextEditingController _bodyController;

  bool get _canEdit => widget.entry?.canEdit ?? true;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _peopleController = TextEditingController(text: entry?.people ?? '');
    _bodyController = TextEditingController(text: entry?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _peopleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: Text(widget.entry == null ? 'Diary 작성' : 'Diary 보기'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_canEdit)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: _SoftNotice(
                  text: '이 기록은 수정 가능 시간이 지나 U-Map 단서로 반영되어 있어요.',
                ),
              ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  bottomInset > 0 ? 24 : 96,
                ),
                children: [
                  _PlainTextField(
                    controller: _titleController,
                    enabled: _canEdit,
                    hintText: '제목',
                    textStyle: const TextStyle(
                      color: _text,
                      fontSize: 23,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PlainTextField(
                    controller: _peopleController,
                    enabled: _canEdit,
                    hintText: '함께 있었던 사람',
                    prefixIcon: Icons.group_outlined,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _bodyController,
                    enabled: _canEdit,
                    minLines: 16,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    cursorColor: _gold,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 16,
                      height: 1.58,
                    ),
                    decoration: const InputDecoration(
                      hintText:
                          '오늘 있었던 상황과 나의 행동, 결정, 생각, 감정 등을 적어주면 당신을 탐구하는데에 도움이 돼요!',
                      hintMaxLines: 4,
                      hintStyle: TextStyle(color: _mutedText, height: 1.45),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            _DiaryWriteFooter(canEdit: _canEdit, onSave: _save),
          ],
        ),
      ),
    );
  }

  void _save() {
    final body = _bodyController.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('본문을 조금만 적어주세요.')));
      return;
    }

    Navigator.of(context).pop(
      DiaryDraft(
        id: widget.entry?.id,
        title: _titleController.text.trim(),
        body: body,
        people: _blankToNull(_peopleController.text),
      ),
    );
  }
}

class _DiaryIntro extends StatelessWidget {
  const _DiaryIntro({this.savedFeedback});

  final String? savedFeedback;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘의 기록',
          style: TextStyle(
            color: _text,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '하루의 장면을 남기면 현재 자기탐색 흐름을 보는 단서가 쌓여요.',
          style: TextStyle(color: _softText, fontSize: 14, height: 1.45),
        ),
        if (savedFeedback != null) ...[
          const SizedBox(height: 16),
          _SoftNotice(text: savedFeedback!),
        ],
      ],
    );
  }
}

class _DiaryEntryCard extends StatelessWidget {
  const _DiaryEntryCard({
    required this.entry,
    required this.onTap,
    required this.onEdit,
  });

  final DiaryEntryData entry;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _line.withValues(alpha: 0.64)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.075),
                    _surface.withValues(alpha: 0.42),
                    _surface.withValues(alpha: 0.34),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${entry.yearLabel} ${entry.dateLabel}',
                          style: const TextStyle(
                            color: _mutedText,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          entry.canEdit
                              ? Icons.schedule_rounded
                              : Icons.lock_outline_rounded,
                          color: entry.canEdit ? _mint : _mutedText,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            entry.editWindowLabel,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: entry.canEdit ? _mint : _mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      entry.title,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _softText,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    if (entry.people?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Text(
                        '함께 있었던 사람 · ${entry.people}',
                        style: const TextStyle(color: _mutedText, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text(
                          '탭해서 전체 보기',
                          style: TextStyle(color: _mutedText, fontSize: 11),
                        ),
                        const Spacer(),
                        if (onEdit == null)
                          const Text(
                            '수정 마감',
                            style: TextStyle(
                              color: _mutedText,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        else
                          TextButton.icon(
                            onPressed: onEdit,
                            style: TextButton.styleFrom(
                              foregroundColor: _gold,
                              minimumSize: const Size(0, 34),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: const Text('수정'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiaryEntryDetailSheet extends StatelessWidget {
  const _DiaryEntryDetailSheet({required this.entry, required this.onEdit});

  final DiaryEntryData entry;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.48,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            border: Border.fromBorderSide(BorderSide(color: _line)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${entry.yearLabel} ${entry.dateLabel}',
                      style: const TextStyle(
                        color: _mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    entry.canEdit
                        ? Icons.schedule_rounded
                        : Icons.lock_outline_rounded,
                    color: entry.canEdit ? _mint : _mutedText,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      entry.editWindowLabel,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: entry.canEdit ? _mint : _mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 22,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (entry.people?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.group_outlined,
                      color: _mutedText,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '함께 있었던 사람 · ${entry.people}',
                        style: const TextStyle(
                          color: _softText,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              Text(
                entry.body,
                style: const TextStyle(
                  color: _text,
                  fontSize: 15,
                  height: 1.62,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 26),
              if (onEdit == null)
                const _SoftNotice(text: '이 기록은 수정 마감되었고, U-Map 단서로 반영되어 있어요.')
              else
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: onEdit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: const Color(0xFF171104),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('수정'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PlainTextField extends StatelessWidget {
  const _PlainTextField({
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.prefixIcon,
    this.textStyle,
  });

  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final IconData? prefixIcon;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      cursorColor: _gold,
      style:
          textStyle ??
          const TextStyle(color: _text, fontSize: 16, height: 1.35),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: _mutedText.withValues(alpha: 0.82),
          fontSize: textStyle?.fontSize,
          fontWeight: textStyle?.fontWeight,
        ),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: _mutedText, size: 20),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: _line),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _line),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _gold),
        ),
        disabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _line),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _DiaryWriteFooter extends StatelessWidget {
  const _DiaryWriteFooter({required this.canEdit, required this.onSave});

  final bool canEdit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: _background,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Diary 내용은 나를 더 잘 이해하는 단서로 활용돼요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mutedText, fontSize: 12, height: 1.35),
          ),
          if (canEdit) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: const Color(0xFF171104),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Diary 저장'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SoftNotice extends StatelessWidget {
  const _SoftNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF102238),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF24415E)),
      ),
      child: Row(
        children: [
          const DiarySparkIcon(color: _gold, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _text, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class DiarySparkIcon extends StatelessWidget {
  const DiarySparkIcon({required this.color, required this.size, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _DiarySparkIconPainter(color)),
    );
  }
}

class _DiarySparkIconPainter extends CustomPainter {
  const _DiarySparkIconPainter(this.color);

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
        ..color = color.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shortest * 0.12),
    );
    canvas.drawPath(
      main,
      Paint()
        ..shader =
            RadialGradient(
              center: const Alignment(-0.35, -0.45),
              radius: 0.9,
              colors: [Colors.white, bright, color],
              stops: const [0.0, 0.22, 1.0],
            ).createShader(
              Rect.fromCircle(center: center, radius: shortest * 0.42),
            ),
    );
    canvas.drawPath(
      main,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeJoin = StrokeJoin.round
        ..color = bright.withValues(alpha: 0.72),
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
  bool shouldRepaint(covariant _DiarySparkIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _DiaryLoadingState extends StatelessWidget {
  const _DiaryLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 148),
      children: const [
        Center(child: CircularProgressIndicator(color: _gold)),
        SizedBox(height: 18),
        Center(
          child: Text(
            'Diary 기록을 불러오고 있어요.',
            style: TextStyle(color: _mutedText),
          ),
        ),
      ],
    );
  }
}

class _DiaryEmptyState extends StatelessWidget {
  const _DiaryEmptyState({required this.onWrite});

  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 148),
      children: [
        const Icon(Icons.edit_note_rounded, color: _gold, size: 44),
        const SizedBox(height: 18),
        const Text(
          '아직 남긴 Diary가 없어요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '하루를 확정해서 해석하지 않아도 괜찮아요. 떠오르는 장면을 적으면 자기탐색의 단서가 쌓여요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _softText, height: 1.45),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: onWrite,
          icon: const Icon(Icons.add_rounded),
          label: const Text('첫 Diary 작성'),
        ),
      ],
    );
  }
}

class _DiaryErrorState extends StatelessWidget {
  const _DiaryErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 148),
      children: [
        const Icon(Icons.error_outline_rounded, color: _gold, size: 42),
        const SizedBox(height: 16),
        const Text(
          'Diary를 불러오지 못했어요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _text,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '잠시 뒤 다시 시도해주세요. 저장된 기록은 그대로 유지돼요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _softText, height: 1.45),
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('다시 불러오기'),
        ),
      ],
    );
  }
}

List<DiaryEntryData> _buildSampleEntries() {
  final now = DateTime.now();
  return [
    DiaryEntryData(
      id: 'd-001',
      createdAt: DateTime(now.year, now.month, now.day, 20),
      title: '조용한 시간이 필요했던 날',
      body:
          '퇴근 후 조용히 걷는 시간이 오래 필요했어요. 말보다 공기가 먼저 기억나는 날이었고, 내 속도를 조금 늦추고 싶다는 생각이 들었습니다.',
      people: '혼자',
    ),
    DiaryEntryData(
      id: 'd-002',
      createdAt: DateTime(now.year, now.month, now.day - 2, 21),
      title: '말보다 표정을 먼저 읽었던 시간',
      body: '대화가 끝난 뒤에 마음이 남아 있어서 짧게 적었어요. 다음에는 내 반응을 조금 더 천천히 보고 싶습니다.',
      people: '동료',
    ),
  ];
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
