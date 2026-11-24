import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

/// Compact active scan context banner displayed above the chat transcript.
class ChatContextBanner extends StatelessWidget {
  const ChatContextBanner({
    super.key,
    required this.scanContext,
    required this.onDismiss,
  });

  final String scanContext;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final ink = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    final leafBg = isDark ? AppColors.dLeafSoft : AppColors.lLeafSoft;
    final leafStrong = isDark ? AppColors.dLeafGreen : AppColors.lLeafStrong;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimens.screenPadding,
        AppDimens.s12,
        AppDimens.screenPadding,
        AppDimens.s4,
      ),
      decoration: BoxDecoration(
        color: leafBg,
        borderRadius: BorderRadius.circular(AppDimens.rCard),
        border: Border.all(color: harvest.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3.5, color: leafStrong),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.s12,
                  vertical: AppDimens.s8 + 2,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: leafStrong,
                        borderRadius: BorderRadius.circular(AppDimens.rButton),
                      ),
                      child: Icon(
                        Icons.center_focus_strong_rounded,
                        size: 17,
                        color: isDark ? AppColors.dOnPrimary : Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppDimens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'KONTEKS PINDAI AKTIF',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: leafStrong,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.9,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Konteks: $scanContext',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.s8),
                    InkWell(
                      onTap: onDismiss,
                      borderRadius: BorderRadius.circular(AppDimens.rButton),
                      child: Tooltip(
                        message: 'Lepas konteks',
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimens.rButton,
                            ),
                            border: Border.all(color: harvest.border, width: 1),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
