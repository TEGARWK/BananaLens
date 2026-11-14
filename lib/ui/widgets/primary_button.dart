import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.rButton),
      ),
      elevation: 0,
      minimumSize: Size(fullWidth ? double.infinity : 88, height),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
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

    Widget btn;
    if (icon != null && !isLoading) {
      btn = ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        icon: Icon(icon, size: 20),
        label: labelWidget,
      );
    } else {
      btn = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: labelWidget,
      );
    }

    return btn;
  }
}
