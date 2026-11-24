import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';

/// Flat, borderless editorial primary CTA button in Ripe Banana Gold
/// with Deep Espresso ink — zero Saweria hard drop-shadows or double strokes.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 48,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      disabledBackgroundColor: theme.colorScheme.primary.withValues(
        alpha: 0.45,
      ),
      disabledForegroundColor: theme.colorScheme.onPrimary.withValues(
        alpha: 0.55,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.rButton),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      minimumSize: Size(
        fullWidth ? double.infinity : 88,
        height < 48 ? 48 : height,
      ),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );

    final Widget labelWidget = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onPrimary,
              ),
            ),
          )
        : Text(text);

    if (icon != null && !isLoading) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        icon: Icon(icon, size: 18),
        label: labelWidget,
      );
    }
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: labelWidget,
    );
  }
}
