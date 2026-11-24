import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_colors.dart';
import 'package:fruitlens/core/theme/app_radius.dart';
import 'package:fruitlens/core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';

/// Unified, refined AppBar for FruitLens screens with subtle bottom divider,
/// rounded icon buttons, and clean typography.
class FruitLensAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FruitLensAppBar({
    required this.title,
    this.subtitle,
    this.showOnlineDot = false,
    this.showBackButton = false,
    this.onBackPressed,
    this.leadingIcon,
    this.actions,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool showOnlineDot;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final IconData? leadingIcon;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget? leadingWidget;
    if (showBackButton) {
      leadingWidget = Padding(
        padding: const EdgeInsets.only(left: AppSpacing.md),
        child: Center(
          child: Material(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
            borderRadius: AppRadius.roundedMd,
            child: InkWell(
              borderRadius: AppRadius.roundedMd,
              onTap:
                  onBackPressed ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.roundedMd,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      );
    } else if (leadingIcon != null) {
      leadingWidget = Padding(
        padding: const EdgeInsets.only(left: AppSpacing.md),
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: AppRadius.roundedMd,
            ),
            child: Icon(leadingIcon, color: colorScheme.onPrimary, size: 20),
          ),
        ),
      );
    }

    return AppBar(
      toolbarHeight: 61,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: (showBackButton || leadingIcon != null) ? 54 : 0,
      leading: leadingWidget,
      titleSpacing: (showBackButton || leadingIcon != null)
          ? AppSpacing.sm
          : AppSpacing.md,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              fontSize: 17,
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (showOnlineDot) ...<Widget>[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.dLeafGreen
                          : AppColors.lLeafStrong,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Flexible(
                  child: Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: actions != null
          ? <Widget>[...actions!, const SizedBox(width: AppSpacing.xs)]
          : null,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
