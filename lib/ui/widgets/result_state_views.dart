import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import '../../data/models/scan_report.dart';
import 'app_card.dart';
import 'fruit_image.dart';
import 'primary_button.dart';
import 'shimmer_box.dart';

/// Shimmer skeleton placeholder during active fruit ripeness inspection.
class ResultLoadingView extends StatelessWidget {
  const ResultLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        const ShimmerBox(height: 180, radius: AppDimens.rHero),
        const SizedBox(height: AppDimens.s16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBox(width: 140, height: 32, radius: AppDimens.s8),
            ShimmerBox(width: 72, height: 32, radius: AppDimens.s8),
          ],
        ),
        const SizedBox(height: AppDimens.s16),
        const ShimmerBox(height: 120, radius: AppDimens.rCard),
        const SizedBox(height: AppDimens.s16),
        const Row(
          children: [
            Expanded(child: ShimmerBox(height: 48, radius: AppDimens.rButton)),
            SizedBox(width: AppDimens.s12),
            Expanded(child: ShimmerBox(height: 48, radius: AppDimens.rButton)),
          ],
        ),
        const SizedBox(height: AppDimens.s16),
        const ShimmerBox(height: 88, radius: AppDimens.rCard),
        const SizedBox(height: AppDimens.s12),
        Center(
          child: Text(
            'Sedang memeriksa kondisi buah…',
            style: theme.textTheme.bodySmall?.copyWith(color: harvest.muted),
          ),
        ),
      ],
    );
  }
}

/// Fallback view when a fruit is not confidently recognized or detected.
class ResultUncertainView extends StatelessWidget {
  const ResultUncertainView({super.key, required this.report});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return ListView(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      children: [
        FruitImage(
          imagePath: report.imagePath,
          height: 160,
          radius: AppDimens.rHero,
        ),
        const SizedBox(height: AppDimens.s16),
        AppCard(
          child: Column(
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: 44,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppDimens.s12),
              Text(
                AppStrings.resultUncertainTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.s8),
              Text(
                AppStrings.resultUncertainBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: harvest.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.s20),
        PrimaryButton(
          text: AppStrings.resultRetake,
          icon: Icons.refresh_rounded,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}

/// Generic error view when scan processing fails unexpectedly.
class ResultErrorView extends StatelessWidget {
  const ResultErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppDimens.s16),
            Text(
              AppStrings.resultErrorTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimens.s8),
            Text(
              message.isNotEmpty ? message : AppStrings.resultErrorBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.s20),
            PrimaryButton(
              text: AppStrings.resultRetry,
              onPressed: onRetry,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
