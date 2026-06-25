import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: SizedBox(
                height: constraints.maxHeight > 52
                    ? constraints.maxHeight - 52
                    : constraints.maxHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 14),
                    const _BrandMark(),
                    const Spacer(),
                    Text(
                      'MY UNIVERSE',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 28, letterSpacing: 0),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '질문과 Diary 기록을 바탕으로 지금의 자기탐색 흐름을 차분히 보여드릴게요.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 34),
                    FiYouLiquidButton(
                      label: '시작하기',
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: onContinue,
                      height: 58,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '사람을 단정하지 않고, 기록에서 흐름을 발견합니다.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox.square(
        dimension: 104,
        child: Image(
          image: AssetImage('assets/images/my_universe_logo_symbol.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
