import 'package:flutter/material.dart';

class ScreenState extends StatelessWidget {
  const ScreenState.loading({super.key})
      : title = '불러오는 중이에요',
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) const CircularProgressIndicator(),
            if (isLoading) const SizedBox(height: 18),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
