import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';
import 'industrial_art.dart';
import 'primary_button.dart';

/// Displays an eco-friendly handling and food safety modal sheet for rotten fruit.
void showRottenGuidanceSheet(BuildContext context, String fruitTitle) {
  final theme = Theme.of(context);
  final harvest = context.harvest;
  final ink = theme.colorScheme.onSurface;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimens.rHero),
          ),
          border: Border(top: BorderSide(color: ink, width: 1.6)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.s20,
          AppDimens.s12,
          AppDimens.s20,
          AppDimens.s24,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: AppDimens.s16),
                  decoration: BoxDecoration(
                    color: ink.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const IndustrialTagChip(label: 'KEAMANAN // DAUR ULANG'),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(
                        AppDimens.rButton - 2,
                      ),
                      border: Border.all(
                        color: theme.colorScheme.error,
                        width: 1.4,
                      ),
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.s12),
              Text(
                AppStrings.rottenSheetTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$fruitTitle terdeteksi dalam kondisi busuk.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: harvest.muted,
                ),
              ),
              const SizedBox(height: AppDimens.s16),
              IndustrialSpecimenCard(
                padding: const EdgeInsets.all(AppDimens.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.rottenSheetStepsTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: AppDimens.s8),
                    Text(
                      AppStrings.rottenSheetStepsBody,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: ink.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.s20),
              PrimaryButton(
                text: AppStrings.rottenSheetAcknowledge,
                height: 48,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
