import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import 'glass_card.dart';

class FiYouPage extends StatelessWidget {
  const FiYouPage({
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 24),
    this.onRefresh,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView(
      padding: padding,
      children: children,
    );
    if (onRefresh == null) return list;
    return RefreshIndicator(onRefresh: onRefresh!, child: list);
  }
}

class FiYouHeader extends StatelessWidget {
  const FiYouHeader({
    required this.title,
    required this.subtitle,
    this.overline,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final String? overline;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (overline != null) ...[
                  FiYouPill(label: overline!),
                  const SizedBox(height: 12),
                ],
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class FiYouPill extends StatelessWidget {
  const FiYouPill({
    required this.label,
    this.icon,
    this.color = FiYouColors.cyan,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class FiYouGradientButton extends StatelessWidget {
  const FiYouGradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C5CFF), Color(0xFFB55CFF)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: FiYouColors.violet.withValues(alpha: 0.42),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Center(
                child: loading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, size: 19),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
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
    );
  }
}

class FiYouMetricCard extends StatelessWidget {
  const FiYouMetricCard({
    required this.title,
    required this.value,
    required this.caption,
    this.icon = Icons.auto_awesome_outlined,
    this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: FiYouColors.cyan, size: 20),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: FiYouColors.text)),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class FiYouInfoRow extends StatelessWidget {
  const FiYouInfoRow({required this.text, this.icon = Icons.check_circle_outline, super.key});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: FiYouColors.cyan, size: 19),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class MiniUMap extends StatelessWidget {
  const MiniUMap({this.axes = const [], this.size = 180, super.key});

  final List<double> axes;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.68,
      child: CustomPaint(painter: _MiniUMapPainter(axes)),
    );
  }
}

class _MiniUMapPainter extends CustomPainter {
  _MiniUMapPainter(this.axes);

  final List<double> axes;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.48);
    final radius = min(size.width, size.height) * 0.38;
    final grid = Paint()
      ..color = FiYouColors.blue.withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final glow = Paint()
      ..color = Colors.black.withValues(alpha: 0.42)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final fill = Paint()
      ..shader = RadialGradient(
        colors: [
          FiYouColors.violet.withValues(alpha: 0.42),
          FiYouColors.cyan.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    final line = Paint()
      ..color = FiYouColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, size.height * 0.76), width: size.width * 0.66, height: 22),
      glow,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1, 0.42);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(Offset.zero, radius * i / 4, grid);
    }
    canvas.drawCircle(Offset.zero, radius, fill);
    canvas.restore();

    final values = axes.isEmpty ? const [58, 72, 46, 64, 52] : axes;
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final angle = -pi / 2 + i * pi * 2 / values.length;
      final projected = Offset(cos(angle) * radius * values[i].clamp(0, 100) / 100,
          sin(angle) * radius * 0.42 * values[i].clamp(0, 100) / 100);
      points.add(center + projected);
    }
    final shape = Path()..addPolygon(points, true);
    canvas.drawPath(
      shape,
      Paint()..color = FiYouColors.violet.withValues(alpha: 0.24),
    );
    canvas.drawPath(shape, line);

    for (final point in points) {
      canvas.drawCircle(point, 4.5, Paint()..color = FiYouColors.cyan);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniUMapPainter oldDelegate) => oldDelegate.axes != axes;
}
