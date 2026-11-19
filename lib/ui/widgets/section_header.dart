import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';

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
    final ink = theme.colorScheme.onSurface;

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
              ),
            ),
          ),
          if (actionText != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(AppDimens.rSharp),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppDimens.rSharp),
                  border: Border.all(color: ink, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 13, color: ink),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
