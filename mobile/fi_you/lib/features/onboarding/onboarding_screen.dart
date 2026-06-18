import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_background.dart';
import '../../core/widgets/fi_you_components.dart';
import '../../core/widgets/glass_card.dart';
import '../auth/session_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            children: [
              const BrandMark(size: 62),
              const SizedBox(height: 24),
              const FiYouHeader(
                overline: '처음 여는 U-Map',
                title: '나를 분류하지 않고\n흐름을 살펴볼게요',
                subtitle: '몇 가지 기록이 쌓이면 U-Map과 Signature가 조금씩 선명해집니다.',
              ),
              GlassCard(
                emphasis: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FiYouInfoRow(text: '고정된 유형으로 판단하지 않아요.'),
                    const FiYouInfoRow(text: '현재까지의 기록을 바탕으로 보이는 흐름만 보여줘요.'),
                    const FiYouInfoRow(text: '답하기 어려운 질문은 건너뛰어도 괜찮아요.'),
                    const FiYouInfoRow(text: '결과는 시간이 지나며 달라질 수 있어요.'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: '앱에서 부를 이름',
                        hintText: '예: FI-YOU',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FiYouGradientButton(
                      label: '오늘의 질문 보기',
                      icon: Icons.auto_awesome_outlined,
                      loading: session.isLoading,
                      onPressed: session.isLoading
                          ? null
                          : () => ref
                              .read(appSessionProvider.notifier)
                              .completeOnboarding(_nameController.text.trim()),
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
            ],
          ),
        ),
      ),
    );
  }
}
