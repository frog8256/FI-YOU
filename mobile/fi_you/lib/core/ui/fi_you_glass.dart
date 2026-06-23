import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

enum FiYouGlassV5Preset { large, medium, small, cta, nav }

class FiYouGlass {
  const FiYouGlass._();

  static const background = Color(0xFF050714);
  static const depth = Color(0xFF080D1D);
  static const surface = Color(0xFF0E1325);
  static const surfaceSoft = Color(0xFF141B30);
  static const border = Color(0xFF2D3B62);
  static const text = Color(0xFFFFFFFF);
  static const textSoft = Color(0xFFB7C0D7);
  static const textMuted = Color(0xFF7F8AA6);
  static const primary = Color(0xFF8B5CF6);
  static const primarySoft = Color(0xFFC4B5FD);
  static const cyan = Color(0xFF7DD3FC);
  static const gold = Color(0xFFF7C948);
  static const nativeBarAccent = Color(0xFFA8A0D8);

  static const glassBlurLargeV3 = 24.0;
  static const glassBlurSmallV3 = 20.0;
  static const glassBlurCtaV3 = 24.0;
  static const glassFillLargeV3 = Color(0x2EFFFFFF);
  static const glassFillSmallV3 = Color(0x1AFFFFFF);
  static const glassFillCtaV3 = Color(0x33FFFFFF);

  static const glassLightAngle = 0.75 * math.pi;
  static const glassRefractiveIndex = 1.15;
  static const glassChromaticAberration = 0.5;
  static const glassGlowIntensity = 0.75;
  static const glassThicknessLarge = 30.0;
  static const glassThicknessSmall = 22.0;
  static const glassThicknessCta = 36.0;
  static const glassPressScaleLarge = 0.992;
  static const glassPressScaleSmall = 0.988;

  static const glassBlurLarge = 8.0;
  static const glassBlurMedium = 7.0;
  static const glassBlurSmall = 6.0;
  static const glassBlurCta = 6.0;
  static const glassBlurSigma = glassBlurLarge;
  static const glassFillLarge = Color(0x0AFFFFFF);
  static const glassFillMedium = Color(0x0AFFFFFF);
  static const glassFillSmall = Color(0x09FFFFFF);
  static const glassFillCta = Color(0x0BFFFFFF);
  static const glassFill = glassFillSmall;
  static const glassSmallFill = glassFillSmall;
  static const glassTintViolet = Colors.transparent;
  static const glassTintCyan = Colors.transparent;
  static const glassStrokeTop = Color(0x38FFFFFF);
  static const glassStrokeSide = Color(0x2BFFFFFF);
  static const glassStrokeBottom = Color(0x1FFFFFFF);
  static const glassV3Highlight = glassStrokeTop;
  static const glassV3StrokeSide = glassStrokeSide;
  static const glassV3StrokeBottom = glassStrokeBottom;
  static const glassStrokeTopSmall = Color(0x38FFFFFF);
  static const glassStrokeSideSmall = Color(0x2BFFFFFF);
  static const glassStrokeBottomSmall = Color(0x1FFFFFFF);
  static const glassSmallBorder = glassStrokeTopSmall;
  static const glassStrokeTopCta = Color(0x38FFFFFF);
  static const glassStrokeSideCta = Color(0x2BFFFFFF);
  static const glassInnerGlowCyan = Colors.transparent;
  static const glassInnerGlowViolet = Colors.transparent;
  static const glassSpecularWhite = Colors.transparent;
  static const glassSpecularSmall = Colors.transparent;
  static const glassSpecularCta = Colors.transparent;
  static const glassV3BodyTint = glassFillLarge;
  static const glassV3SmallTint = glassFillSmall;
  static const glassV4BodyTint = glassFillLarge;
  static const glassV4SmallTint = glassFillSmall;
  static const glassShadow = Color(0x0A000000);
  static const glassShadowSmall = Color(0x08000000);
  static const glassShadowCta = Color(0x0A000000);
  static const glassLargeShadow = glassShadow;
  static const glassSmallShadow = glassShadowSmall;
  static const glassShadowBlur = 8.0;
  static const glassShadowOffsetY = 4.0;
  static const glassRadiusCard = 28.0;
  static const glassRadiusSmall = 18.0;
  static const glassV5Blur = glassBlurLarge;
  static const glassV5Fill = Color(0x0AFFFFFF);
  static const glassV5PressFill = Color(0x0CFFFFFF);
  static const glassV5Border = Color(0x36FFFFFF);
  static const glassV5BorderSoft = Color(0x2EFFFFFF);
  static const glassV5Shadow = Color(0x12000000);
  static const buttonTint = Color(0x0BFFFFFF);
  static const buttonTintPressed = Color(0x0DFFFFFF);
  static const buttonBorder = Color(0x38FFFFFF);
  static const buttonBorderSoft = Color(0x33FFFFFF);
  static const liquidButtonSettings = LiquidGlassSettings(
    glassColor: buttonTint,
    thickness: 28,
    blur: 10,
    chromaticAberration: 0.018,
    lightAngle: glassLightAngle,
    lightIntensity: 0.52,
    ambientStrength: 0.06,
    refractiveIndex: 1.16,
    saturation: 1.18,
    glowIntensity: 0,
    shadowElevation: 0,
    backerColor: Color(0x08000000),
  );
  static const glassHighlightShadow = Colors.transparent;
  static const glassV3BlackShadow = glassShadow;
  static const glassV3TopLeftHighlightShadow = glassHighlightShadow;
  static const glassChromaticCyanEdge = Colors.transparent;
  static const glassChromaticVioletEdge = Colors.transparent;
  static const glassPressScaleCta = 0.988;
  static const glassLargeBorder = glassStrokeTopSmall;
  static const glassLargeHighlightShadow = glassHighlightShadow;
  static const glassSmallHighlightShadow = glassSpecularSmall;
  static const nativeBarSurface = Color(0x05FFFFFF);

  static double blurSigmaFor({
    double radius = glassRadiusCard,
    bool cta = false,
    bool medium = false,
  }) {
    if (cta) return glassBlurCta;
    if (medium) return glassBlurMedium;
    return radius >= 24 ? glassBlurLarge : glassBlurSmall;
  }

  static double blurSigmaForPreset(FiYouGlassV5Preset preset) {
    return switch (preset) {
      FiYouGlassV5Preset.large => glassBlurLarge,
      FiYouGlassV5Preset.medium => glassBlurMedium,
      FiYouGlassV5Preset.small => glassBlurSmall,
      FiYouGlassV5Preset.cta => glassBlurCta,
      FiYouGlassV5Preset.nav => glassBlurSmall,
    };
  }

  static BoxDecoration decoration({
    Color? tint,
    Color? borderColor,
    double radius = glassRadiusCard,
    double alpha = 1,
    bool cta = false,
    bool medium = false,
  }) {
    final isLarge = !cta && !medium && radius >= 24;
    final fill = cta
        ? glassFillCta
        : medium
        ? glassFillMedium
        : isLarge
        ? glassFillLarge
        : glassFillSmall;
    final shadow = cta
        ? glassShadowCta
        : isLarge
        ? glassShadow
        : glassShadowSmall;
    final borderAlpha = cta
        ? 0.18
        : isLarge
        ? 0.16
        : 0.14;

    return BoxDecoration(
      color: fill.withValues(alpha: fill.a * alpha),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: borderAlpha),
        width: isLarge || cta ? 1.05 : 0.9,
      ),
      boxShadow: [
        BoxShadow(
          color: shadow,
          blurRadius: cta ? 8 : 6,
          offset: Offset(0, cta ? 4 : 3),
        ),
      ],
    );
  }

  static BoxDecoration largeDecoration({
    Color? tint,
    Color? borderColor,
    double radius = glassRadiusCard,
  }) {
    return decoration(tint: tint, borderColor: borderColor, radius: radius);
  }

  static BoxDecoration largeGlassV5({
    Color? tint,
    Color? borderColor,
    double radius = glassRadiusCard,
  }) {
    return transparentGlassV5(radius: radius, preset: FiYouGlassV5Preset.large);
  }

  static BoxDecoration mediumGlassV5({
    Color? tint,
    Color? borderColor,
    double radius = 22,
  }) {
    return transparentGlassV5(
      borderColor: borderColor,
      radius: radius,
      preset: FiYouGlassV5Preset.medium,
    );
  }

  static BoxDecoration smallGlassV5({
    Color? tint,
    Color? borderColor,
    double radius = glassRadiusSmall,
  }) {
    return transparentGlassV5(
      borderColor: borderColor,
      radius: radius,
      preset: FiYouGlassV5Preset.small,
    );
  }

  static BoxDecoration ctaGlassV5({
    Color? tint,
    Color? borderColor,
    double radius = glassRadiusSmall,
    bool pressed = false,
  }) {
    return transparentGlassV5(
      borderColor: borderColor,
      radius: radius,
      pressed: pressed,
      preset: FiYouGlassV5Preset.cta,
    );
  }

  @Deprecated('Use largeGlassV5. v4 glass effects are intentionally disabled.')
  static BoxDecoration largeGlassV4({
    Color? tint,
    Color? borderColor,
    double radius = glassRadiusCard,
  }) {
    return largeGlassV5(tint: tint, borderColor: borderColor, radius: radius);
  }

  @Deprecated('Use mediumGlassV5. v4 glass effects are intentionally disabled.')
  static BoxDecoration mediumGlassV4({
    Color? tint,
    Color? borderColor,
    double radius = 22,
  }) {
    return mediumGlassV5(tint: tint, borderColor: borderColor, radius: radius);
  }

  @Deprecated('Use smallGlassV5. v4 glass effects are intentionally disabled.')
  static BoxDecoration smallGlassV4({
    Color? tint,
    Color? borderColor,
    double radius = glassRadiusSmall,
  }) {
    return smallGlassV5(tint: tint, borderColor: borderColor, radius: radius);
  }

  @Deprecated('Use ctaGlassV5. v4 glass effects are intentionally disabled.')
  static BoxDecoration ctaGlassV4({
    Color? tint,
    Color? borderColor,
    double radius = glassRadiusSmall,
    bool pressed = false,
  }) {
    return ctaGlassV5(
      tint: tint,
      borderColor: borderColor,
      radius: radius,
      pressed: pressed,
    );
  }

  static BoxDecoration transparentGlassV5({
    Color? borderColor,
    double radius = glassRadiusCard,
    bool pressed = false,
    FiYouGlassV5Preset? preset,
    bool goldBorder = false,
  }) {
    final resolvedPreset =
        preset ??
        (radius >= 24 ? FiYouGlassV5Preset.large : FiYouGlassV5Preset.small);
    final fillAlpha = pressed
        ? 0.028
        : switch (resolvedPreset) {
            FiYouGlassV5Preset.large => 0.008,
            FiYouGlassV5Preset.medium => 0.008,
            FiYouGlassV5Preset.small => 0.008,
            FiYouGlassV5Preset.cta => 0.042,
            FiYouGlassV5Preset.nav => 0.02,
          };
    final isButton = resolvedPreset == FiYouGlassV5Preset.cta;
    final borderAlpha = switch (resolvedPreset) {
      FiYouGlassV5Preset.large => 0.2,
      FiYouGlassV5Preset.medium => 0.2,
      FiYouGlassV5Preset.small => 0.2,
      FiYouGlassV5Preset.cta => 0.22,
      FiYouGlassV5Preset.nav => 0.14,
    };
    final resolvedBorder = goldBorder
        ? gold.withValues(alpha: 0.2)
        : borderColor?.withValues(alpha: borderAlpha + 0.02) ??
              Colors.white.withValues(alpha: borderAlpha);
    final shadowAlpha = pressed ? 0.055 : (isButton ? 0.06 : 0.02);
    return BoxDecoration(
      color: isButton
          ? (pressed ? buttonTintPressed : buttonTint)
          : Colors.white.withValues(alpha: fillAlpha),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isButton
            ? (pressed ? buttonBorder : buttonBorderSoft)
            : resolvedBorder,
        width: isButton ? 1.15 : 0.9,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: shadowAlpha),
          blurRadius: pressed ? 10 : (isButton ? 8 : 4),
          offset: Offset(0, isButton ? 4 : 2),
        ),
      ],
    );
  }

  static BoxDecoration largeDecorationV3({
    Color? tint,
    Color? borderColor,
    double radius = glassRadiusCard,
  }) {
    return largeGlassV5(tint: tint, borderColor: borderColor, radius: radius);
  }

  static BoxDecoration smallDecorationV3({
    Color? tint,
    double radius = glassRadiusSmall,
  }) {
    return smallGlassV5(tint: tint, radius: radius);
  }

  static BoxDecoration nativeBarDecoration({double radius = 32}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.045),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.18),
        width: 0.9,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static ButtonStyle filledButtonStyle({
    Color foregroundColor = text,
    double radius = glassRadiusSmall,
  }) {
    return FilledButton.styleFrom(
      backgroundColor: buttonTint,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: Colors.white.withValues(alpha: 0.035),
      disabledForegroundColor: textMuted,
      shadowColor: Colors.transparent,
      overlayColor: buttonTintPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: buttonBorderSoft, width: 1.1),
      ),
    );
  }
}

class FiYouLiquidButton extends StatelessWidget {
  const FiYouLiquidButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.height = 58,
    this.width = double.infinity,
    this.radius = FiYouGlass.glassRadiusSmall,
    this.fontSize = 16,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 1.05,
    this.accentColor,
    this.accentStrength = 0,
    this.iconSize = 18,
    this.horizontalPadding = 18,
    super.key,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final double height;
  final double? width;
  final double radius;
  final double fontSize;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Color? accentColor;
  final double accentStrength;
  final double iconSize;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final contentColor = enabled
        ? foregroundColor ?? FiYouGlass.text
        : FiYouGlass.textMuted;
    final resolvedAccentStrength = accentStrength.clamp(0.0, 1.0);
    final settings = accentColor == null
        ? FiYouGlass.liquidButtonSettings
        : LiquidGlassSettings(
            glassColor: Color.alphaBlend(
              accentColor!.withValues(alpha: 0.04 * resolvedAccentStrength),
              FiYouGlass.buttonTint,
            ),
            thickness: 28,
            blur: 10,
            chromaticAberration: 0.018,
            lightAngle: FiYouGlass.glassLightAngle,
            lightIntensity: 0.52,
            ambientStrength: 0.06,
            refractiveIndex: 1.16,
            saturation: 1.18,
            glowIntensity: 0,
            shadowElevation: 0,
            backerColor: Color.alphaBlend(
              accentColor!.withValues(alpha: 0.025 * resolvedAccentStrength),
              const Color(0x08000000),
            ),
          );
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.52,
      duration: const Duration(milliseconds: 120),
      child: Stack(
        children: [
          GlassButton.custom(
            label: label,
            onTap: onPressed ?? () {},
            enabled: enabled,
            width: width,
            height: height,
            useOwnLayer: true,
            quality: GlassQuality.standard,
            style: GlassButtonStyle.filled,
            interactionScale: 0.988,
            stretch: 0.18,
            resistance: 0.02,
            glowColor: accentColor ?? FiYouGlass.buttonTintPressed,
            glowBlurRadius: accentColor == null ? 0 : 7,
            glowSpreadRadius: 0,
            glowOpacity: accentColor == null
                ? 0
                : 0.09 * resolvedAccentStrength,
            ambientBaseLight: accentColor == null ? 0.045 : 0.035,
            settings: settings,
            shape: LiquidRoundedRectangle(
              borderRadius: radius,
              side: BorderSide(
                color: borderColor ?? FiYouGlass.buttonBorderSoft,
                width: borderWidth,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconTheme(
                    data: IconThemeData(color: contentColor, size: iconSize),
                    child: icon,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: contentColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? onPressed : null,
            ),
          ),
        ],
      ),
    );
  }
}

class FiYouLiquidIconButton extends StatelessWidget {
  const FiYouLiquidIconButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.size = 44,
    this.radius = FiYouGlass.glassRadiusSmall,
    super.key,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: label,
      child: GlassButton.custom(
        label: label,
        onTap: onPressed ?? () {},
        enabled: enabled,
        width: size,
        height: size,
        useOwnLayer: true,
        quality: GlassQuality.standard,
        style: GlassButtonStyle.filled,
        interactionScale: 0.988,
        stretch: 0.12,
        resistance: 0.02,
        glowColor: FiYouGlass.buttonTintPressed,
        glowBlurRadius: 7,
        glowSpreadRadius: 0.06,
        glowOpacity: 0.4,
        ambientBaseLight: 0.04,
        settings: FiYouGlass.liquidButtonSettings,
        shape: LiquidRoundedRectangle(
          borderRadius: radius,
          side: const BorderSide(color: FiYouGlass.buttonBorderSoft, width: 1),
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: enabled ? FiYouGlass.text : FiYouGlass.textMuted,
              size: 20,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}

class FiYouControlTokens {
  const FiYouControlTokens._();

  static const chevronButtonSize = 32.0;
  static const chevronIconSize = 20.0;

  static const iconTileMedium = 42.0;
  static const iconTileMediumIcon = 20.0;
  static const iconTileMediumSpark = 22.0;

  static const iconTileSmall = 32.0;
  static const iconTileSmallIcon = 17.0;

  static const iconTileXSmall = 22.0;
  static const iconTileXSmallIcon = 13.0;

  static const iconTileList = 38.0;
  static const iconTileListIcon = 20.0;

  static const buttonRegularHeight = 52.0;
  static const buttonRegularFont = 14.0;
  static const buttonCtaHeight = 58.0;
  static const buttonCtaFont = 16.0;
  static const buttonPillHeight = 38.0;
  static const buttonPillFont = 13.0;
}

class FiYouSettingsActionButton extends StatelessWidget {
  const FiYouSettingsActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return FiYouLiquidButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      height: FiYouControlTokens.buttonRegularHeight,
      fontSize: FiYouControlTokens.buttonRegularFont,
      foregroundColor: foregroundColor,
    );
  }
}

class FiYouChevronButton extends StatelessWidget {
  const FiYouChevronButton({
    this.onPressed,
    this.size = FiYouControlTokens.chevronButtonSize,
    this.iconSize = FiYouControlTokens.chevronIconSize,
    this.color = FiYouGlass.textSoft,
    this.label = 'open',
    this.showBorder = true,
    super.key,
  });

  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color color;
  final String label;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    if (!showBorder) {
      return Tooltip(
        message: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: Icon(
                Icons.chevron_right_rounded,
                color: color,
                size: iconSize,
              ),
            ),
          ),
        ),
      );
    }

    return FiYouLiquidIconButton(
      icon: Icon(Icons.chevron_right_rounded, color: color, size: iconSize),
      label: label,
      onPressed: onPressed,
      size: size,
      radius: FiYouGlass.glassRadiusSmall,
    );
  }
}

class FiYouIconTile extends StatelessWidget {
  const FiYouIconTile({
    required this.child,
    required this.color,
    this.size = FiYouControlTokens.iconTileMedium,
    this.radius = FiYouGlass.glassRadiusSmall,
    super.key,
  });

  final Widget child;
  final Color color;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: FiYouGlass.smallGlassV5(borderColor: color, radius: radius),
      child: child,
    );
  }
}

class FiYouCtaGlassButtonV4 extends StatelessWidget {
  const FiYouCtaGlassButtonV4({
    required this.label,
    required this.icon,
    this.onPressed,
    this.accent = FiYouGlass.cyan,
    this.height = 58,
    super.key,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final Color accent;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FiYouCtaGlassButtonV5(
      label: label,
      icon: icon,
      onPressed: onPressed,
      height: height,
    );
  }
}

class FiYouCtaGlassButtonV5 extends StatefulWidget {
  const FiYouCtaGlassButtonV5({
    required this.label,
    required this.icon,
    this.onPressed,
    this.height = 58,
    super.key,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final double height;

  @override
  State<FiYouCtaGlassButtonV5> createState() => _FiYouCtaGlassButtonV5State();
}

class _FiYouCtaGlassButtonV5State extends State<FiYouCtaGlassButtonV5> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onPressed == null) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(covariant FiYouCtaGlassButtonV5 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed == null && _pressed) {
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FiYouLiquidButton(
      label: widget.label,
      icon: widget.icon,
      onPressed: widget.onPressed,
      height: widget.height,
    );
  }

  Widget buildLegacy(BuildContext context) {
    final enabled = widget.onPressed != null;
    final radius = BorderRadius.circular(FiYouGlass.glassRadiusSmall);
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedScale(
        scale: enabled && _pressed ? FiYouGlass.glassPressScaleCta : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: enabled ? (_pressed ? 0.9 : 1) : 0.52,
          duration: const Duration(milliseconds: 120),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: FiYouGlass.blurSigmaFor(
                  radius: FiYouGlass.glassRadiusSmall,
                  cta: true,
                ),
                sigmaY: FiYouGlass.blurSigmaFor(
                  radius: FiYouGlass.glassRadiusSmall,
                  cta: true,
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOutCubic,
                decoration: FiYouGlass.ctaGlassV5(pressed: _pressed),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    onHighlightChanged: _setPressed,
                    borderRadius: radius,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconTheme(
                            data: const IconThemeData(
                              color: Colors.white,
                              size: 18,
                            ),
                            child: widget.icon,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FiYouGlassSurfaceV5 extends StatelessWidget {
  const FiYouGlassSurfaceV5({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = FiYouGlass.glassRadiusCard,
    this.onTap,
    this.blurSigma = FiYouGlass.glassV5Blur,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: FiYouGlass.glassV5Fill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: FiYouGlass.glassV5Border),
            boxShadow: const [
              BoxShadow(
                color: FiYouGlass.glassV5Shadow,
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
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
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}

class FiYouGlassSurface extends StatefulWidget {
  const FiYouGlassSurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = FiYouGlass.glassRadiusCard,
    this.borderColor,
    this.bodyTint,
    this.onTap,
    this.cta = false,
    this.large = false,
    this.v5Preset,
    this.blurSigma,
    this.transparent = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;
  final Color? bodyTint;
  final VoidCallback? onTap;
  final bool cta;
  final bool large;
  final FiYouGlassV5Preset? v5Preset;
  final double? blurSigma;
  final bool transparent;

  @override
  State<FiYouGlassSurface> createState() => _FiYouGlassSurfaceState();
}

class _FiYouGlassSurfaceState extends State<FiYouGlassSurface> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final useCta = widget.cta || widget.v5Preset == FiYouGlassV5Preset.cta;
    final useLarge =
        widget.v5Preset == FiYouGlassV5Preset.large ||
        (widget.v5Preset == null &&
            (widget.large || (!useCta && widget.radius >= 24)));
    final effectiveBlur =
        widget.blurSigma ??
        FiYouGlass.blurSigmaFor(
          radius: widget.radius,
          cta: useCta,
          medium: widget.v5Preset == FiYouGlassV5Preset.medium,
        );
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: _decorationForPreset(
                  radius: widget.radius,
                  tint: widget.bodyTint,
                  borderColor: widget.borderColor,
                  useLarge: useLarge,
                  useCta: useCta,
                  transparent: widget.transparent,
                ),
              ),
            ),
            Padding(padding: widget.padding, child: widget.child),
          ],
        ),
      ),
    );

    if (widget.onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: AnimatedScale(
        scale: _pressed
            ? (useLarge
                  ? FiYouGlass.glassPressScaleLarge
                  : FiYouGlass.glassPressScaleSmall)
            : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            if (mounted) {
              setState(() => _pressed = value);
            }
          },
          splashColor: widget.transparent
              ? Colors.transparent
              : FiYouGlass.glassInnerGlowCyan,
          highlightColor: widget.transparent
              ? Colors.transparent
              : FiYouGlass.glassHighlightShadow,
          borderRadius: BorderRadius.circular(widget.radius),
          child: content,
        ),
      ),
    );
  }

  BoxDecoration _decorationForPreset({
    required double radius,
    required Color? tint,
    required Color? borderColor,
    required bool useLarge,
    required bool useCta,
    required bool transparent,
  }) {
    if (transparent || widget.v5Preset != null) {
      return FiYouGlass.transparentGlassV5(
        borderColor: borderColor,
        radius: radius,
        preset: widget.v5Preset,
      );
    }
    switch (widget.v5Preset) {
      case FiYouGlassV5Preset.medium:
        return FiYouGlass.mediumGlassV5(
          radius: radius,
          tint: tint,
          borderColor: borderColor,
        );
      case FiYouGlassV5Preset.large:
        return FiYouGlass.largeGlassV5(
          radius: radius,
          tint: tint,
          borderColor: borderColor,
        );
      case FiYouGlassV5Preset.small:
        return FiYouGlass.smallGlassV5(
          radius: radius,
          tint: tint,
          borderColor: borderColor,
        );
      case FiYouGlassV5Preset.cta:
        return FiYouGlass.ctaGlassV5(
          radius: radius,
          tint: tint,
          borderColor: borderColor,
        );
      case FiYouGlassV5Preset.nav:
        return FiYouGlass.transparentGlassV5(
          borderColor: borderColor,
          radius: radius,
          preset: FiYouGlassV5Preset.nav,
        );
      case null:
        return useCta
            ? FiYouGlass.ctaGlassV5(
                radius: radius,
                tint: tint,
                borderColor: borderColor,
              )
            : useLarge
            ? FiYouGlass.largeGlassV5(
                radius: radius,
                tint: tint,
                borderColor: borderColor,
              )
            : FiYouGlass.smallGlassV5(
                radius: radius,
                tint: tint,
                borderColor: borderColor,
              );
    }
  }
}

class FiYouStarryBackground extends StatefulWidget {
  const FiYouStarryBackground({super.key});

  @override
  State<FiYouStarryBackground> createState() => _FiYouStarryBackgroundState();
}

class _FiYouStarryBackgroundState extends State<FiYouStarryBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(
          child: CustomPaint(
            isComplex: true,
            willChange: false,
            painter: _StaticStarryNightPainter(),
          ),
        ),
        if (!disableAnimations)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  isComplex: false,
                  willChange: true,
                  painter: _TwinklePainter(_controller.value),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _StaticStarryNightPainter extends CustomPainter {
  const _StaticStarryNightPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101936), Color(0xFF070D20), Color(0xFF030511)],
        ).createShader(rect),
    );

    _drawNebula(canvas, size, const Offset(0.16, 0.08), FiYouGlass.primary);
    _drawNebula(canvas, size, const Offset(0.84, 0.62), FiYouGlass.cyan);
    _drawMilkyWay(canvas, size);
    _drawCoreSystem(canvas, size);

    for (var i = 0; i < 320; i++) {
      final x = _unit(i, 12.9898);
      final y = _unit(i, 78.233);
      final depth = _unit(i, 7.137);
      final baseSize = 0.24 + depth * 0.78;
      final alpha = 0.026 + _unit(i, 41.42) * 0.105;
      final center = Offset(size.width * x, size.height * y);
      canvas.drawCircle(
        center,
        baseSize,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  void _drawCoreSystem(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.52, size.height * 0.5);
    final shortest = size.shortestSide;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.16 * math.pi);

    final outerDisk = Rect.fromCenter(
      center: Offset.zero,
      width: shortest * 1.08,
      height: shortest * 0.32,
    );
    canvas.drawOval(
      outerDisk,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.052),
            FiYouGlass.cyan.withValues(alpha: 0.04),
            FiYouGlass.primary.withValues(alpha: 0.024),
            Colors.transparent,
          ],
          stops: const [0, 0.28, 0.62, 1],
        ).createShader(outerDisk),
    );

    final midDisk = Rect.fromCenter(
      center: Offset.zero,
      width: shortest * 0.78,
      height: shortest * 0.21,
    );
    canvas.drawOval(
      midDisk,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.055),
            FiYouGlass.primarySoft.withValues(alpha: 0.032),
            Colors.transparent,
          ],
          stops: const [0, 0.48, 1],
        ).createShader(midDisk),
    );

    final coreDisk = Rect.fromCenter(
      center: Offset.zero,
      width: shortest * 0.32,
      height: shortest * 0.105,
    );
    canvas.drawOval(
      coreDisk,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.095),
            FiYouGlass.primarySoft.withValues(alpha: 0.042),
            Colors.transparent,
          ],
          stops: const [0, 0.56, 1],
        ).createShader(coreDisk),
    );

    final ringSpecs = [
      (
        width: shortest * 0.78,
        height: shortest * 0.25,
        alpha: 0.062,
        stroke: 0.75,
      ),
      (
        width: shortest * 1.02,
        height: shortest * 0.34,
        alpha: 0.044,
        stroke: 0.65,
      ),
      (
        width: shortest * 1.22,
        height: shortest * 0.43,
        alpha: 0.03,
        stroke: 0.55,
      ),
    ];

    for (final spec in ringSpecs) {
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: spec.width,
        height: spec.height,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..blendMode = BlendMode.screen
          ..strokeWidth = spec.stroke
          ..color = Colors.white.withValues(alpha: spec.alpha),
      );
    }

    canvas.restore();
  }

  void _drawMilkyWay(Canvas canvas, Size size) {
    _drawMilkyWayBand(canvas, size);

    final paint = Paint()..blendMode = BlendMode.screen;
    for (var i = 0; i < 34; i++) {
      final t = i / 33;
      final driftX = (_unit(i, 91.7) - 0.5) * 0.2;
      final driftY = (_unit(i, 51.3) - 0.5) * 0.16;
      final center = Offset(
        size.width * (0.02 + t * 0.98 + driftX),
        size.height * (0.88 - t * 0.72 + driftY),
      );
      final radius = size.shortestSide * (0.045 + _unit(i, 11.31) * 0.07);
      final color = i.isEven ? FiYouGlass.cyan : FiYouGlass.primarySoft;
      canvas.drawCircle(
        center,
        radius,
        paint
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.022),
              color.withValues(alpha: 0.006),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    for (var i = 0; i < 150; i++) {
      final t = _unit(i, 17.71);
      final driftX = (_unit(i, 83.11) - 0.5) * 0.32;
      final driftY = (_unit(i, 29.73) - 0.5) * 0.22;
      final center = Offset(
        size.width * (0.02 + t * 0.98 + driftX),
        size.height * (0.88 - t * 0.72 + driftY),
      );
      final alpha = 0.024 + _unit(i, 13.37) * 0.064;
      canvas.drawCircle(
        center,
        0.22 + _unit(i, 43.91) * 0.58,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  void _drawMilkyWayBand(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final start = Offset(size.width * -0.12, size.height * 0.78);
    final end = Offset(size.width * 1.12, size.height * 0.18);
    final shader = const LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        Colors.transparent,
        Color(0x188B5CF6),
        Color(0x167DD3FC),
        Color(0x10FFFFFF),
        Colors.transparent,
      ],
      stops: [0, 0.22, 0.5, 0.68, 1],
    ).createShader(rect);

    canvas.drawLine(
      start,
      end,
      Paint()
        ..shader = shader
        ..strokeWidth = size.shortestSide * 0.34
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.026)
        ..strokeWidth = size.shortestSide * 0.11
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
  }

  double _unit(int index, double salt) {
    return (math.sin(index * salt) * 43758.5453).abs() % 1;
  }

  void _drawNebula(Canvas canvas, Size size, Offset anchor, Color color) {
    final center = Offset(size.width * anchor.dx, size.height * anchor.dy);
    final radius = size.shortestSide * 0.74;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.04),
            color.withValues(alpha: 0.01),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _StaticStarryNightPainter oldDelegate) {
    return false;
  }
}

class _TwinklePainter extends CustomPainter {
  const _TwinklePainter(this.phase);

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 40; i++) {
      final x = _unit(i, 27.31);
      final y = _unit(i, 63.79);
      final baseSize = 0.42 + _unit(i, 9.17) * 0.9;
      final delay = _unit(i, 19.19);
      final speed = 0.85 + _unit(i, 31.7) * 1.35;
      final wave = math.sin((phase * speed + delay) * math.pi * 2);
      final twinkle = math.pow((wave + 1) / 2, 4).toDouble();
      final alpha = 0.021 + twinkle * 0.27;
      final center = Offset(size.width * x, size.height * y);
      canvas.drawCircle(
        center,
        baseSize + 0.9 + twinkle * 2.0,
        Paint()
          ..blendMode = BlendMode.screen
          ..color = Colors.white.withValues(alpha: alpha * 0.16),
      );
      canvas.drawCircle(
        center,
        baseSize * (0.85 + twinkle * 0.45),
        Paint()
          ..blendMode = BlendMode.screen
          ..color = Colors.white.withValues(alpha: alpha * 0.82),
      );

      if (i % 5 == 0 && twinkle > 0.62) {
        final glint = (twinkle - 0.62) / 0.38;
        final length = 2.4 + twinkle * 4.0;
        final diagonalLength = length * 0.58;
        final stroke = Paint()
          ..blendMode = BlendMode.screen
          ..color = Colors.white.withValues(alpha: alpha * 0.5 * glint)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 0.58;
        canvas.drawLine(
          center.translate(-length, 0),
          center.translate(length, 0),
          stroke,
        );
        canvas.drawLine(
          center.translate(0, -length),
          center.translate(0, length),
          stroke,
        );
        canvas.drawLine(
          center.translate(-diagonalLength, -diagonalLength),
          center.translate(diagonalLength, diagonalLength),
          stroke..strokeWidth = 0.5,
        );
        canvas.drawLine(
          center.translate(-diagonalLength, diagonalLength),
          center.translate(diagonalLength, -diagonalLength),
          stroke,
        );
      }
    }
  }

  double _unit(int index, double salt) {
    return (math.sin(index * salt) * 43758.5453).abs() % 1;
  }

  @override
  bool shouldRepaint(covariant _TwinklePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
