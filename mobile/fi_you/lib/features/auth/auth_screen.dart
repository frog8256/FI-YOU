import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/fi_you_components.dart';
import '../../core/widgets/glass_card.dart';
import 'session_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FiYouPage(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
            children: [
              const Align(alignment: Alignment.centerLeft, child: BrandMark(size: 72)),
              const SizedBox(height: 26),
              Text(
                'FI-YOU',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 42),
              ),
              const SizedBox(height: 12),
              Text(
                '질문과 Diary를 따라 지금의 나에게 보이는 흐름을 천천히 탐구해요.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              const MiniUMap(size: 230),
              const SizedBox(height: 26),
              GlassCard(
                emphasis: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FiYouPill(label: 'AI Self Discovery', icon: Icons.auto_awesome_outlined),
                    const SizedBox(height: 14),
                    Text('기록을 시작할 이메일', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'FI-YOU는 사람을 유형으로 고정하지 않고, 현재까지의 기록에서 보이는 흐름을 보여줍니다.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: '이메일',
                        hintText: 'you@example.com',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FiYouGradientButton(
                      label: '시작하기',
                      icon: Icons.arrow_forward_rounded,
                      loading: session.isLoading,
                      onPressed: session.isLoading
                          ? null
                          : () => ref
                              .read(appSessionProvider.notifier)
                              .signInWithEmail(_emailController.text.trim()),
                    ),
                    if (session.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        session.errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'FI-YOU는 의료적 진단이나 상담을 제공하지 않는 자기이해 플랫폼입니다.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: FiYouColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
