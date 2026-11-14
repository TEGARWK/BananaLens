import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

class SoftButton extends StatelessWidget {
  const SoftButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.height = 48,
    this.fullWidth = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    final childWidget = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: AppDimens.s8),
        ],
        Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Material(
      color: harvest.primarySoft,
      borderRadius: BorderRadius.circular(AppDimens.rButton),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.rButton),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.s16),
          alignment: Alignment.center,
          child: childWidget,
        ),
      ),
    );
  }
}

class AccentButton extends StatelessWidget {
  const AccentButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.height = 48,
    this.fullWidth = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;

    final childWidget = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: harvest.onAccent),
          const SizedBox(width: AppDimens.s8),
        ],
        Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: harvest.onAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return Material(
      color: harvest.accent,
      borderRadius: BorderRadius.circular(AppDimens.rButton),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.rButton),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.s20),
          alignment: Alignment.center,
          child: childWidget,
        ),
      ),
    );
  }
}
