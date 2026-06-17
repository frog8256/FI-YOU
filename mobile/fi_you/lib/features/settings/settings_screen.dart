import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/repositories/repository_providers.dart';
import '../auth/session_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(
          '설정',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            children: [
              _RowButton(label: '관계 탐험', onTap: () => context.push('/relations')),
              _RowButton(label: '리포트', onTap: () => context.push('/reports')),
              _RowButton(label: 'Star와 결제', onTap: () => context.push('/store')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            children: [
              _RowButton(label: '약관', onTap: () => context.push('/legal/terms')),
              _RowButton(
                label: '개인정보처리방침',
                onTap: () => launchUrl(Uri.parse(AppConfig.privacyPolicyUrl)),
              ),
              _RowButton(label: '주의 및 면책', onTap: () => context.push('/legal/disclaimer')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            children: [
              _RowButton(
                label: '로그아웃',
                onTap: () => ref.read(appSessionProvider.notifier).signOut(),
              ),
              _RowButton(
                label: '탈퇴하기',
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
        title: const Text('탈퇴 요청'),
        content: const Text('계정과 개인 데이터 삭제 요청을 보낼까요?'),
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
        const SnackBar(content: Text('탈퇴 요청을 보냈어요.')),
      );
    }
  }
}

class _RowButton extends StatelessWidget {
  const _RowButton({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: danger ? Theme.of(context).colorScheme.error : null,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
