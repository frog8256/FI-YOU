import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/features/auth/dna_studio_footer.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.onGoogleSignIn, super.key});

  final VoidCallback onGoogleSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              FiYouGlassSurface(
                radius: FiYouGlass.glassRadiusCard,
                v5Preset: FiYouGlassV5Preset.large,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '기록을 이어서 보기 위해 로그인해 주세요.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'My Universe는 질문 응답과 Diary 기록을 안전하게 연결해 현재의 자기탐색 흐름을 보여드립니다.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    FiYouLiquidButton(
                      label: 'Google로 계속하기',
                      icon: const Icon(Icons.login_rounded),
                      onPressed: onGoogleSignIn,
                      height: 56,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '로그인 후 돌아오면 세션을 확인합니다.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              const DnaStudioFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
