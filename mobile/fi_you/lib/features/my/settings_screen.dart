import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/features/my/my_models.dart';
import 'package:fi_you/features/my/my_theme.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    this.profile = const MyProfileData(),
    this.notificationsEnabled = true,
    this.onProfileTap,
    this.onNotificationChanged,
    this.onDeleteDataTap,
    this.onTermsTap,
    this.onPrivacyPolicyTap,
    this.onLogout,
    super.key,
  });

  final MyProfileData profile;
  final bool notificationsEnabled;
  final VoidCallback? onProfileTap;
  final ValueChanged<bool>? onNotificationChanged;
  final VoidCallback? onDeleteDataTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyPolicyTap;
  final VoidCallback? onLogout;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.notificationsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return MyPageScaffold(
      appBar: myPlainAppBar(context, '설정'),
      bottomPadding: 0,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          _SettingsSection(
            title: '계정',
            children: [
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                title: '프로필',
                subtitle: '${widget.profile.name} · ${widget.profile.email}',
                onTap: widget.onProfileTap ?? () => _showMockMessage('프로필 편집'),
              ),
              _SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: '알림 설정',
                subtitle: '질문, Diary, 탐구 흐름 업데이트 알림',
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeThumbColor: MyColors.primarySoft,
                  activeTrackColor: MyColors.primarySoft.withValues(
                    alpha: 0.18,
                  ),
                  inactiveThumbColor: MyColors.textSoft,
                  inactiveTrackColor: FiYouGlass.glassSmallFill,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    widget.onNotificationChanged?.call(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: '개인정보',
            children: [
              _SettingsTile(
                icon: Icons.folder_delete_outlined,
                title: '개인정보 / 데이터 삭제',
                subtitle: '기록과 U-Map 데이터 삭제 요청',
                onTap:
                    widget.onDeleteDataTap ??
                    () => _showMockMessage('데이터 삭제 요청'),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: '이용약관',
                subtitle: 'My Universe 서비스 이용 기준',
                onTap: widget.onTermsTap ?? () => _showMockMessage('이용약관'),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보처리방침',
                subtitle: '기록 데이터 처리와 보관 기준',
                onTap:
                    widget.onPrivacyPolicyTap ??
                    () => _showMockMessage('개인정보처리방침'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          MySurface(
            onTap: widget.onLogout ?? () => _showMockMessage('로그아웃'),
            radius: FiYouGlass.glassRadiusSmall,
            borderColor: FiYouGlass.glassStrokeSide,
            v5Preset: FiYouGlassV5Preset.cta,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
      ),
    );
  }

  void _showMockMessage(String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label 기능은 연결 준비 중입니다.')));
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: MyColors.textSoft,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        MySurface(
          padding: EdgeInsets.zero,
          radius: 22,
          v5Preset: FiYouGlassV5Preset.medium,
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1)
                  Divider(
                    height: 1,
                    color: FiYouGlass.glassStrokeBottom,
                    indent: 58,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            FiYouIconTile(
              color: MyColors.primarySoft,
              size: 34,
              child: Icon(icon, color: MyColors.primarySoft, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: MyColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: MyColors.textMuted,
                      fontSize: 11.5,
                      height: 1.35,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: MyColors.textMuted,
                size: 21,
              ),
          ],
        ),
      ),
    );
  }
}
