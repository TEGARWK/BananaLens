import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'primary_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title = 'Terjadi Kesalahan',
    this.onRetry,
    this.retryText = 'Coba Lagi',
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.screenPadding,
        vertical: AppDimens.s32,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppDimens.s16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimens.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: harvest.muted),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimens.s20),
              PrimaryButton(
                text: retryText,
                onPressed: onRetry,
                fullWidth: false,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
