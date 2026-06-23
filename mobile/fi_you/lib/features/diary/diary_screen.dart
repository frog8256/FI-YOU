import 'dart:ui';

import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:flutter/material.dart';

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
  late final List<DiaryEntryData> _entries = List<DiaryEntryData>.of(
    widget.initialEntries ?? _sampleEntries(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(
              Icons.edit_note_rounded,
              color: FiYouGlass.nativeBarAccent,
              size: 23,
            ),
            SizedBox(width: 8),
            Text(
              'Diary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 148),
          children: [
            const Text(
              '오늘의 기록',
              style: TextStyle(
                color: FiYouGlass.text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '하루의 장면과 감정을 남기면 나를 이해하는 단서가 쌓여요.',
              style: TextStyle(
                color: FiYouGlass.textSoft,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            for (final entry in _entries) ...[
              _DiaryEntryCard(
                entry: entry,
                onTap: () => _showEntry(entry),
                onEdit: entry.canEdit ? () => _openEditor(entry: entry) : null,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 84),
        child: SizedBox(
          width: 134,
          child: FiYouLiquidButton(
            label: '작성하기',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openEditor(),
            height: FiYouControlTokens.buttonRegularHeight,
            fontSize: FiYouControlTokens.buttonRegularFont,
          ),
        ),
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

    if (draft.id == null) {
      await widget.onCreate?.call(draft);
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
    } else {
      await widget.onUpdate?.call(draft);
      final index = _entries.indexWhere((entry) => entry.id == draft.id);
      if (index != -1) {
        final current = _entries[index];
        _entries[index] = DiaryEntryData(
          id: current.id,
          createdAt: current.createdAt,
          title: draft.title.trim().isEmpty ? '오늘의 Diary' : draft.title.trim(),
          body: draft.body.trim(),
          people: _blankToNull(draft.people),
        );
      }
    }

    widget.onSavedForUMap?.call();
    setState(() {});
  }

  Future<void> _showEntry(DiaryEntryData entry) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DiaryDetailSheet(
        entry: entry,
        onEdit: entry.canEdit
            ? () {
                Navigator.of(context).pop();
                _openEditor(entry: entry);
              }
            : null,
      ),
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
  late final _titleController = TextEditingController(
    text: widget.entry?.title ?? '',
  );
  late final _peopleController = TextEditingController(
    text: widget.entry?.people ?? '',
  );
  late final _bodyController = TextEditingController(
    text: widget.entry?.body ?? '',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _peopleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.entry?.canEdit ?? true;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.entry == null ? 'Diary 작성' : 'Diary 보기'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _GlassTextField(
                    controller: _titleController,
                    enabled: canEdit,
                    hintText: '제목',
                  ),
                  const SizedBox(height: 14),
                  _GlassTextField(
                    controller: _peopleController,
                    enabled: canEdit,
                    hintText: '함께 있었던 사람',
                    prefixIcon: Icons.group_outlined,
                  ),
                  const SizedBox(height: 14),
                  _GlassTextField(
                    controller: _bodyController,
                    enabled: canEdit,
                    hintText: '오늘 있었던 장면과 감정을 적어주세요.',
                    minLines: 12,
                    maxLines: null,
                  ),
                ],
              ),
            ),
            if (canEdit)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: FiYouControlTokens.buttonRegularHeight,
                  child: FiYouLiquidButton(
                    label: 'Diary 저장',
                    icon: const Icon(Icons.check_rounded),
                    onPressed: _save,
                    height: FiYouControlTokens.buttonRegularHeight,
                    fontSize: FiYouControlTokens.buttonRegularFont,
                  ),
                ),
              ),
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
    return _GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(right: onEdit == null ? 0 : 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.yearLabel} ${entry.dateLabel}',
                  style: const TextStyle(
                    color: FiYouGlass.textSoft,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  entry.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: FiYouGlass.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD8DEF0),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            Positioned(
              top: 0,
              right: 0,
              child: FiYouLiquidIconButton(
                label: '수정',
                icon: const Icon(Icons.edit_rounded),
                onPressed: onEdit,
                size: 36,
                radius: 18,
              ),
            ),
        ],
      ),
    );
  }
}

class _DiaryDetailSheet extends StatelessWidget {
  const _DiaryDetailSheet({required this.entry, required this.onEdit});

  final DiaryEntryData entry;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.48,
      maxChildSize: 0.94,
      builder: (context, controller) {
        return _GlassContainer(
          radius: FiYouGlass.glassRadiusCard,
          padding: EdgeInsets.zero,
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '${entry.yearLabel} ${entry.dateLabel}',
                style: const TextStyle(
                  color: FiYouGlass.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                entry.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: FiYouGlass.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                entry.body,
                style: const TextStyle(
                  color: FiYouGlass.text,
                  fontSize: 15,
                  height: 1.62,
                ),
              ),
              if (onEdit != null) ...[
                const SizedBox(height: 24),
                FiYouLiquidButton(
                  label: '수정',
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: onEdit,
                  height: FiYouControlTokens.buttonRegularHeight,
                  fontSize: FiYouControlTokens.buttonRegularFont,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.prefixIcon,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final IconData? prefixIcon;
  final int minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(FiYouGlass.glassRadiusSmall),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: FiYouGlass.glassBlurSigma,
                sigmaY: FiYouGlass.glassBlurSigma,
              ),
              child: DecoratedBox(
                decoration: FiYouGlass.ctaGlassV5(
                  radius: FiYouGlass.glassRadiusSmall,
                ),
              ),
            ),
          ),
          TextField(
            controller: controller,
            enabled: enabled,
            minLines: minLines,
            maxLines: maxLines,
            cursorColor: FiYouGlass.nativeBarAccent,
            style: const TextStyle(
              color: FiYouGlass.text,
              fontSize: 15,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFFD8DEF0),
                fontSize: 15,
                height: 1.45,
              ),
              prefixIcon: prefixIcon == null
                  ? null
                  : Icon(prefixIcon, color: FiYouGlass.textSoft, size: 20),
              filled: true,
              fillColor: Colors.transparent,
              border: _fieldBorder(),
              enabledBorder: _fieldBorder(),
              focusedBorder: _fieldBorder(FiYouGlass.glassV3Highlight),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _fieldBorder([
    Color color = FiYouGlass.glassV3StrokeSide,
  ]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(FiYouGlass.glassRadiusSmall),
      borderSide: BorderSide(color: color.withValues(alpha: 0.82), width: 1.05),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  const _GlassContainer({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = FiYouGlass.glassRadiusCard,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: padding,
      radius: radius,
      onTap: onTap,
      transparent: true,
      v5Preset: radius >= 24
          ? FiYouGlassV5Preset.large
          : FiYouGlassV5Preset.small,
      child: child,
    );
  }
}

List<DiaryEntryData> _sampleEntries() {
  final now = DateTime.now();
  return [
    DiaryEntryData(
      id: 'd-001',
      createdAt: DateTime(now.year, now.month, now.day, 20),
      title: '조용한 시간이 필요했던 날',
      body: '퇴근 후 조용히 걷는 시간이 오래 필요했다. 말보다 공기가 먼저 기억나는 날이었고, 내 속도도 조금 늦추고 싶었다.',
      people: '혼자',
    ),
    DiaryEntryData(
      id: 'd-002',
      createdAt: DateTime(now.year, now.month, now.day - 2, 21),
      title: '말보다 표정이 먼저 읽혔던 시간',
      body: '대화가 끝난 뒤에도 마음에 남아 있는 장면이 있었다. 다음에는 내 반응을 조금 더 천천히 보고 싶다.',
      people: '동료',
    ),
  ];
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
