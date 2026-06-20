import 'package:fi_you/features/my/my_models.dart';
import 'package:fi_you/features/my/my_theme.dart';
import 'package:fi_you/features/my/settings_screen.dart';
import 'package:flutter/material.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({
    this.profile = const MyProfileData(),
    this.insights = myDefaultInsights,
    this.onOpenStore,
    this.onOpenSettings,
    super.key,
  });

  final MyProfileData profile;
  final List<MyInsightData> insights;
  final VoidCallback? onOpenStore;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return MyPageScaffold(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
        children: [
          const _Header(),
          const SizedBox(height: 20),
          _ProfileCard(profile: profile),
          const SizedBox(height: 24),
          const MySectionTitle(
            title: '분석내용',
            subtitle: '진단 결과가 아니라 지금까지의 기록에서 보이는 자기탐색 흐름입니다.',
          ),
          const SizedBox(height: 12),
          _InsightList(insights: insights),
          const SizedBox(height: 22),
          _SettingsButton(onTap: () => _openSettings(context)),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    if (onOpenSettings != null) {
      onOpenSettings!();
      return;
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => SettingsScreen(profile: profile)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: MyColors.surfaceSoft.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MyColors.borderStrong),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: MyColors.primarySoft,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'My',
          style: TextStyle(
            color: MyColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final MyProfileData profile;

  @override
  Widget build(BuildContext context) {
    return MySurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      borderColor: MyColors.gold.withValues(alpha: 0.34),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF171A2D), Color(0xFF090D1C)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.profileLine,
            style: const TextStyle(
              color: MyColors.primarySoft,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${profile.name} 님',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MyColors.text,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _MetricBox(label: 'Level', value: '${profile.level}'),
              const SizedBox(width: 10),
              _MetricBox(label: 'Star', value: '${profile.starBalance}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: MyColors.borderStrong.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: MyColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: MyColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightList extends StatelessWidget {
  const _InsightList({required this.insights});

  final List<MyInsightData> insights;

  @override
  Widget build(BuildContext context) {
    return MySurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          for (var index = 0; index < insights.length; index++) ...[
            _InsightRow(insight: insights[index]),
            if (index != insights.length - 1)
              Divider(
                height: 1,
                color: MyColors.border.withValues(alpha: 0.8),
                indent: 50,
              ),
          ],
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.insight});

  final MyInsightData insight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: insight.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: insight.icon == Icons.auto_awesome_rounded
                ? MySparkIcon(color: insight.color, size: 21)
                : Icon(insight.icon, color: insight.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    color: MyColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  insight.description,
                  style: const TextStyle(
                    color: MyColors.textSoft,
                    fontSize: 12.3,
                    height: 1.42,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MySparkIcon extends StatelessWidget {
  const MySparkIcon({required this.color, required this.size, super.key});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MySparkIconPainter(color)),
    );
  }
}

class _MySparkIconPainter extends CustomPainter {
  const _MySparkIconPainter(this.color);

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
  bool shouldRepaint(covariant _MySparkIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MySurface(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: const Row(
        children: [
          Icon(Icons.settings_outlined, color: MyColors.primarySoft, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '설정',
              style: TextStyle(
                color: MyColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: MyColors.textMuted,
            size: 22,
          ),
        ],
      ),
    );
  }
}
