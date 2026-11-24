import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

/// Clean editorial section header with bold title and borderless Cocoa Brown
/// action link (`Lihat semua →`).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.s4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (actionText != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(AppDimens.rButton),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s8,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: harvest.accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: harvest.accent,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
