import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import 'fi_you_components.dart';
import 'glass_card.dart';

class ScreenState extends StatelessWidget {
  const ScreenState.loading({super.key})
      : title = '흐름을 불러오는 중이에요',
        body = null,
        actionLabel = null,
        onAction = null,
        isLoading = true;

  const ScreenState.message({
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : isLoading = false;

  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          emphasis: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading) ...[
                const SizedBox.square(
                  dimension: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.8,
                    color: FiYouColors.cyan,
                  ),
                ),
                const SizedBox(height: 18),
              ] else ...[
                const Icon(Icons.auto_awesome_outlined, color: FiYouColors.cyan),
                const SizedBox(height: 12),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (body != null) ...[
                const SizedBox(height: 8),
                Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                FiYouGradientButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
