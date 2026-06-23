import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:flutter/material.dart';

class OnboardingEntryScreen extends StatelessWidget {
  const OnboardingEntryScreen({required this.onRefresh, super.key});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FiYouGlassSurface(
              radius: FiYouGlass.glassRadiusCard,
              v5Preset: FiYouGlassV5Preset.large,
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '첫 기록을 시작할 준비가 필요해요.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '프로필 설정 또는 온보딩 화면으로 연결되면 이 지점에서 이어집니다.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FiYouLiquidButton(
                    label: '상태 다시 확인',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: onRefresh,
                    height: 54,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
