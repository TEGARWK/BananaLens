import 'package:flutter/material.dart';

import 'package:fruitlens/core/theme/app_radius.dart';
import 'package:fruitlens/core/theme/app_spacing.dart';

/// Clean placeholder view used for tab screens during setup.
class TabPlaceholderView extends StatelessWidget {
  const TabPlaceholderView({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: AppRadius.roundedXl,
              ),
              child: Icon(icon, size: 40, color: colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonal(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
