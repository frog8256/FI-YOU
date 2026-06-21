import 'dart:ui';

import 'package:flutter/material.dart';

class MyColors {
  const MyColors._();

  static const background = Color(0xFF050714);
  static const depth = Color(0xFF080D1D);
  static const surface = Color(0xFF0E1325);
  static const surfaceSoft = Color(0xFF141B30);
  static const border = Color(0xFF1E2945);
  static const borderStrong = Color(0xFF2D3B62);
  static const primarySoft = Color(0xFFC4B5FD);
  static const cyan = Color(0xFF7DD3FC);
  static const mint = Color(0xFF6EE7B7);
  static const gold = Color(0xFFF7C948);
  static const danger = Color(0xFFFFA8A8);
  static const text = Color(0xFFFFFFFF);
  static const textSoft = Color(0xFFB7C0D7);
  static const textMuted = Color(0xFF7F8AA6);
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
    this.radius = 22,
    this.blurSigma = 20,
    this.alpha = 0.78,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double radius;
  final double blurSigma;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: 0.12),
      ),
      color: MyColors.surface.withValues(alpha: alpha),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.22),
          blurRadius: 22,
          offset: const Offset(0, 12),
        ),
      ],
    );

    final content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Ink(
          decoration: decoration,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
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
