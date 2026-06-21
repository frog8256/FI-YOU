import 'package:fi_you/features/my/my_models.dart';
import 'package:fi_you/features/my/my_theme.dart';
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
          const MySectionTitle(
            title: '설정',
            subtitle: '계정, 알림, 개인정보 항목을 바로 확인하고 관리합니다.',
          ),
          const SizedBox(height: 12),
          _InlineSettingsList(profile: profile),
        ],
      ),
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: MyColors.surface.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: MyColors.primarySoft,
            size: 23,
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
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      radius: 28,
      alpha: 0.8,
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
          color: MyColors.surface.withValues(alpha: 0.76),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
      radius: 24,
      alpha: 0.78,
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
              color: MyColors.surface.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
    final main = _sparkPath(center, shortest * 0.36, shortest * 0.12);
    canvas.drawPath(main, Paint()..color = color);
    _drawSmall(
      canvas,
      Offset(size.width * 0.76, size.height * 0.24),
      shortest * 0.12,
      color,
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

class _InlineSettingsList extends StatefulWidget {
  const _InlineSettingsList({required this.profile});

  final MyProfileData profile;

  @override
  State<_InlineSettingsList> createState() => _InlineSettingsListState();
}

class _InlineSettingsListState extends State<_InlineSettingsList> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MySurface(
          padding: EdgeInsets.zero,
          radius: 24,
          alpha: 0.78,
          child: Column(
            children: [
              _SettingsListTile(
                icon: Icons.person_outline_rounded,
                title: '프로필',
                subtitle: '${widget.profile.name} · ${widget.profile.email}',
                onTap: () => _showMockMessage('프로필 편집'),
              ),
              const _SettingsDivider(),
              _SettingsListTile(
                icon: Icons.notifications_none_rounded,
                title: '알림 설정',
                subtitle: '질문, Diary, 탐구 흐름 업데이트 알림',
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeThumbColor: MyColors.gold,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        MySurface(
          padding: EdgeInsets.zero,
          radius: 24,
          alpha: 0.78,
          child: Column(
            children: [
              _SettingsListTile(
                icon: Icons.folder_delete_outlined,
                title: '개인정보 / 데이터 삭제',
                subtitle: '기록과 U-Map 데이터 삭제 요청',
                onTap: () => _showMockMessage('데이터 삭제 요청'),
              ),
              const _SettingsDivider(),
              _SettingsListTile(
                icon: Icons.description_outlined,
                title: '이용약관',
                subtitle: 'FI-YOU 서비스 이용 기준',
                onTap: () => _showMockMessage('이용약관'),
              ),
              const _SettingsDivider(),
              _SettingsListTile(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보처리방침',
                subtitle: '기록 데이터 처리와 보관 기준',
                onTap: () => _showMockMessage('개인정보처리방침'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        MySurface(
          onTap: () => _showMockMessage('로그아웃'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          radius: 18,
          alpha: 0.76,
          borderColor: MyColors.danger.withValues(alpha: 0.24),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: MyColors.danger, size: 20),
              SizedBox(width: 10),
              Text(
                '로그아웃',
                style: TextStyle(
                  color: MyColors.danger,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMockMessage(String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label 기능은 연결 준비 중입니다.')));
  }
}

class _SettingsListTile extends StatelessWidget {
  const _SettingsListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minLeadingWidth: 28,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Icon(icon, color: MyColors.primarySoft, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: MyColors.text,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: MyColors.textMuted,
          fontSize: 12,
          letterSpacing: 0,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: MyColors.textMuted),
      onTap: onTap,
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: MyColors.border.withValues(alpha: 0.75),
      indent: 58,
    );
  }
}
