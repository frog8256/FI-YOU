import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_theme.dart';
import '../../core/config/app_config.dart';
import '../../core/widgets/fi_you_components.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/repositories/repository_providers.dart';
import '../auth/session_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FiYouPage(
      children: [
        const FiYouHeader(
          overline: 'Settings',
          title: '앱과 기록 관리',
          subtitle: '내 기록과 결제, 정책 문서를 한곳에서 확인합니다.',
        ),
        GlassCard(
          child: Column(
            children: [
              _RowButton(label: '관계 흐름', icon: Icons.hub_outlined, onTap: () => context.push('/relations')),
              _RowButton(label: '리포트', icon: Icons.article_outlined, onTap: () => context.push('/reports')),
              _RowButton(label: 'Star와 결제', icon: Icons.stars_rounded, onTap: () => context.push('/store')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            children: [
              _RowButton(label: '약관', icon: Icons.description_outlined, onTap: () => context.push('/legal/terms')),
              _RowButton(
                label: '개인정보처리방침',
                icon: Icons.privacy_tip_outlined,
                onTap: () => launchUrl(Uri.parse(AppConfig.privacyPolicyUrl)),
              ),
              _RowButton(label: '주의 및 면책', icon: Icons.info_outline, onTap: () => context.push('/legal/disclaimer')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            children: [
              _RowButton(
                label: '로그아웃',
                icon: Icons.logout_outlined,
                onTap: () => ref.read(appSessionProvider.notifier).signOut(),
              ),
              _RowButton(
                label: '계정 삭제 요청',
                icon: Icons.delete_outline,
                danger: true,
                onTap: () => _confirmDeletion(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeletion(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제 요청'),
        content: const Text('계정과 개인 데이터 삭제 요청을 보낼까요? 이 요청은 되돌리기 어렵습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('요청하기'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(selfDiscoveryRepositoryProvider).requestAccountDeletion();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계정 삭제 요청을 보냈어요.')),
      );
    }
  }
}

class _RowButton extends StatelessWidget {
  const _RowButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Row(
          children: [
            Icon(icon, color: danger ? Theme.of(context).colorScheme.error : FiYouColors.cyan),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: danger ? Theme.of(context).colorScheme.error : null),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
