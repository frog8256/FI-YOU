import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/features/auth/dna_studio_footer.dart';
import 'package:flutter/material.dart';

class AuthReturnScreen extends StatelessWidget {
  const AuthReturnScreen({
    this.title = '로그인 상태를 확인하고 있어요.',
    this.message = '잠시만 기다려 주세요. My Universe로 돌아오는 중입니다.',
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FiYouGlassSurface(
                    radius: FiYouGlass.glassRadiusCard,
                    v5Preset: FiYouGlassV5Preset.large,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 26,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: FiYouGlass.cyan,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const DnaStudioFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
