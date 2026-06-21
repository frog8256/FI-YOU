import 'dart:ui';

import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/features/diary/diary.dart' as diary;
import 'package:fi_you/features/explore/explore_screen.dart' as explore;
import 'package:fi_you/features/home/home.dart' as home;
import 'package:fi_you/features/my/my.dart' as my;
import 'package:fi_you/features/umap/umap.dart' as umap;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: FiYouColors.background,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final repository = MockFiYouRepository();
  await repository.restoreLaunchState();
  runApp(FiYouApp(repository: repository));
}

class FiYouApp extends StatelessWidget {
  const FiYouApp({required this.repository, super.key});

  final FiYouRepository repository;

  @override
  Widget build(BuildContext context) {
    return FiYouRepositoryScope(
      repository: repository,
      child: MaterialApp(
        title: 'FI-YOU',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: FiYouColors.background,
          colorScheme: const ColorScheme.dark(
            primary: FiYouColors.primary,
            secondary: FiYouColors.cyan,
            surface: FiYouColors.surface,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FiYouGlass.filledButtonStyle(),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: FiYouColors.cyan,
              backgroundColor: FiYouGlass.buttonTint,
              side: const BorderSide(
                color: FiYouGlass.buttonBorderSoft,
                width: 1.1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  FiYouGlass.glassRadiusSmall,
                ),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: FiYouColors.cyan,
              backgroundColor: FiYouGlass.buttonTint,
              overlayColor: FiYouGlass.buttonTintPressed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  FiYouGlass.glassRadiusSmall,
                ),
                side: const BorderSide(
                  color: FiYouGlass.buttonBorderSoft,
                  width: 1,
                ),
              ),
            ),
          ),
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(
              backgroundColor: FiYouGlass.buttonTint,
              foregroundColor: FiYouColors.text,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  FiYouGlass.glassRadiusSmall,
                ),
                side: const BorderSide(
                  color: FiYouGlass.buttonBorderSoft,
                  width: 1,
                ),
              ),
            ),
          ),
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              color: FiYouColors.text,
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
            titleLarge: TextStyle(
              color: FiYouColors.text,
              fontSize: 17,
              height: 1.28,
              fontWeight: FontWeight.w800,
            ),
            titleMedium: TextStyle(
              color: FiYouColors.text,
              fontSize: 15,
              height: 1.34,
              fontWeight: FontWeight.w700,
            ),
            bodyMedium: TextStyle(
              color: FiYouColors.textSoft,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
            bodySmall: TextStyle(
              color: FiYouColors.textMuted,
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: media.textScaler.clamp(
                minScaleFactor: 0.9,
                maxScaleFactor: 1.0,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(child: FiYouBackground()),
                child ?? const SizedBox.shrink(),
              ],
            ),
          );
        },
        home: const FiYouShell(),
      ),
    );
  }
}

class FiYouShell extends StatefulWidget {
  const FiYouShell({super.key});

  @override
  State<FiYouShell> createState() => _FiYouShellState();
}

class _FiYouShellState extends State<FiYouShell> {
  FiYouTab _tab = FiYouTab.home;

  void _select(FiYouTab tab) {
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          IndexedStack(
            index: FiYouTab.values.indexOf(_tab),
            children: [
              home.HomeScreen(
                onNotificationTap: () =>
                    _showMessage(context, '알림 설정은 출시 후 연결됩니다.'),
                onProfileTap: () => _select(FiYouTab.my),
                onStoreTap: () => _select(FiYouTab.my),
                onUMapTap: () => _select(FiYouTab.uMap),
                onDiaryTap: () => _select(FiYouTab.diary),
                onQuestionTap: () => _select(FiYouTab.explore),
                onStatusTap: () => _select(FiYouTab.explore),
              ),
              const diary.DiaryScreen(),
              explore.ExploreScreen(
                onOpenUMap: () => _select(FiYouTab.uMap),
                onAnswersSaved: (_) async {
                  _showMessage(context, '답변이 기록되었어요. U-Map 단서에 반영할 준비가 되었어요.');
                },
              ),
              umap.FiYouUMapScreen(
                onStartQuestion: () => _select(FiYouTab.explore),
                onShare: () => _showMessage(context, '공유 기능은 출시 후 연결됩니다.'),
                onOpenGrowthMap: () =>
                    _showMessage(context, 'Growth Map은 Star 콘텐츠로 준비 중입니다.'),
                onOpenRelationMap: () =>
                    _showMessage(context, 'Relation Map은 Star 콘텐츠로 준비 중입니다.'),
                onOpenReport: () =>
                    _showMessage(context, '상세 리포트는 Star 콘텐츠로 준비 중입니다.'),
              ),
              const my.MyScreen(),
            ],
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: MediaQuery.of(context).padding.bottom + 10,
            child: FiYouNavBar(current: _tab, onChanged: _select),
          ),
        ],
      ),
    );
  }
}

enum FiYouTab { home, diary, explore, uMap, my }

class FiYouColors {
  const FiYouColors._();

  static const background = Color(0xFF050714);
  static const depth = Color(0xFF080D1D);
  static const surface = Color(0xFF0E1325);
  static const border = Color(0xFF1E2945);
  static const primary = Color(0xFF8B5CF6);
  static const navMain = FiYouGlass.nativeBarAccent;
  static const cyan = Color(0xFF7DD3FC);
  static const gold = Color(0xFFF7C948);
  static const text = Color(0xFFFFFFFF);
  static const textSoft = Color(0xFFB7C0D7);
  static const textMuted = Color(0xFF7F8AA6);
}

class FiYouBackground extends StatelessWidget {
  const FiYouBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(),
      child: FiYouStarryBackground(),
    );
  }
}

class FiYouNavBar extends StatelessWidget {
  const FiYouNavBar({
    required this.current,
    required this.onChanged,
    super.key,
  });

  final FiYouTab current;
  final ValueChanged<FiYouTab> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(FiYouTab.home, Icons.home_rounded, '홈'),
      _NavItem(FiYouTab.diary, Icons.edit_note_rounded, 'Diary'),
      _NavItem(FiYouTab.explore, Icons.auto_awesome_rounded, '탐구'),
      _NavItem(FiYouTab.uMap, Icons.bubble_chart_outlined, 'U-Map'),
      _NavItem(FiYouTab.my, Icons.person_rounded, 'My'),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: FiYouGlass.glassBlurSigma,
          sigmaY: FiYouGlass.glassBlurSigma,
        ),
        child: Container(
          height: 72,
          decoration: FiYouGlass.nativeBarDecoration(radius: 32),
          child: Row(
            children: [
              for (final item in items)
                Expanded(
                  child: _NavButton(
                    item: item,
                    active: current == item.tab,
                    onTap: () => onChanged(item.tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isExplore = widget.item.tab == FiYouTab.explore;
    final iconColor = isExplore
        ? FiYouColors.gold
        : widget.active
        ? FiYouColors.navMain
        : FiYouColors.textMuted;
    final labelColor = isExplore
        ? FiYouColors.gold
        : widget.active
        ? FiYouColors.navMain
        : FiYouColors.textMuted;
    final activeScale = widget.active ? 1.03 : 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (value) => setState(() => _pressed = value),
        borderRadius: BorderRadius.circular(28),
        splashColor: Colors.white.withValues(alpha: 0.045),
        highlightColor: Colors.white.withValues(alpha: 0.025),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          transform: Matrix4.diagonal3Values(
            activeScale * (_pressed ? 1.024 : 1),
            activeScale * (_pressed ? 0.986 : 1),
            1,
          ),
          transformAlignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 32,
                alignment: Alignment.center,
                child: widget.item.tab == FiYouTab.explore
                    ? SparkNavIcon(color: iconColor, size: 24)
                    : Icon(widget.item.icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 10.5,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.tab, this.icon, this.label);

  final FiYouTab tab;
  final IconData icon;
  final String label;
}

class SparkNavIcon extends StatelessWidget {
  const SparkNavIcon({required this.color, required this.size, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _SparkNavIconPainter(color)),
    );
  }
}

class _SparkNavIconPainter extends CustomPainter {
  const _SparkNavIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    final center = Offset(size.width * 0.48, size.height * 0.52);
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: 0.18);

    final mainSpark = _sparkPath(center, shortest * 0.36, shortest * 0.12);
    canvas.drawPath(mainSpark, fill);
    canvas.drawPath(mainSpark, stroke);

    _drawSmallSpark(
      canvas,
      Offset(size.width * 0.76, size.height * 0.24),
      shortest * 0.12,
      color,
    );
    _drawSmallSpark(
      canvas,
      Offset(size.width * 0.24, size.height * 0.72),
      shortest * 0.09,
      color.withValues(alpha: 0.9),
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

  void _drawSmallSpark(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    canvas.drawPath(
      _sparkPath(center, radius, radius * 0.35),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _SparkNavIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
