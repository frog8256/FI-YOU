import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:flutter/material.dart';

class MyColors {
  const MyColors._();

  static const background = FiYouGlass.background;
  static const depth = FiYouGlass.depth;
  static const surface = FiYouGlass.surface;
  static const surfaceSoft = FiYouGlass.surfaceSoft;
  static const border = Color(0xFF1E2945);
  static const borderStrong = FiYouGlass.border;
  static const primarySoft = FiYouGlass.primarySoft;
  static const cyan = FiYouGlass.cyan;
  static const mint = Color(0xFF6EE7B7);
  static const gold = FiYouGlass.gold;
  static const danger = Color(0xFFFFA8A8);
  static const text = FiYouGlass.text;
  static const textSoft = FiYouGlass.textSoft;
  static const textMuted = FiYouGlass.textMuted;
  static final glassFill = FiYouGlass.glassFill;
  static final glassStrokeSide = FiYouGlass.glassStrokeSide;
  static final glassStrokeBottom = FiYouGlass.glassStrokeBottom;
  static final glassSpecularWhite = FiYouGlass.glassSpecularWhite;
}

class MyPageScaffold extends StatelessWidget {
  const MyPageScaffold({
    required this.child,
    this.appBar,
    this.bottomPadding = 122,
    super.key,
  });

  final PreferredSizeWidget? appBar;
  final Widget child;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: child,
        ),
      ),
    );
  }
}

class MySurface extends StatelessWidget {
  const MySurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderColor,
    this.onTap,
    this.radius = FiYouGlass.glassRadiusCard,
    this.blurSigma = FiYouGlass.glassBlurSigma,
    this.v5Preset = FiYouGlassV5Preset.large,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double radius;
  final double blurSigma;
  final FiYouGlassV5Preset v5Preset;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: padding,
      radius: radius,
      borderColor: borderColor,
      onTap: onTap,
      v5Preset: v5Preset,
      transparent: true,
      blurSigma: blurSigma,
      child: child,
    );
  }
}

class MySectionTitle extends StatelessWidget {
  const MySectionTitle({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: MyColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: MyColors.textMuted,
            fontSize: 12.5,
            height: 1.35,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

AppBar myPlainAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.transparent,
    foregroundColor: MyColors.text,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    title: Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
    ),
  );
}
