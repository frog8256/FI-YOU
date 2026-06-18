import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/fi_you_components.dart';
import '../../core/widgets/glass_card.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({required this.type, super.key});

  final String type;

  @override
  Widget build(BuildContext context) {
    final content = _contentFor(type);
    return FiYouPage(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: '뒤로',
              onPressed: () => context.canPop() ? context.pop() : context.go('/settings'),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(content.title, style: Theme.of(context).textTheme.titleLarge)),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          emphasis: true,
          child: Text(
            content.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }

  _LegalContent _contentFor(String type) {
    return switch (type) {
      'disclaimer' => const _LegalContent(
          title: '주의 및 면책',
          body:
              'FI-YOU는 AI 기반 자기이해 플랫폼입니다. FI-YOU는 의료적 진단, 심리상담, 치료, 긴급 지원을 제공하지 않습니다. 위험하거나 긴급한 상황이라면 지역의 전문 기관이나 긴급 연락처를 이용해 주세요.',
        ),
      _ => const _LegalContent(
          title: '약관',
          body:
              'FI-YOU는 사용자가 자신의 기록을 바탕으로 생각과 경향을 탐구하도록 돕는 서비스입니다. 사용자는 자신의 기록을 관리할 수 있으며, 서비스는 안정적인 제공을 위해 필요한 범위에서 데이터를 처리합니다.',
        ),
    };
  }
}

class _LegalContent {
  const _LegalContent({required this.title, required this.body});

  final String title;
  final String body;
}
