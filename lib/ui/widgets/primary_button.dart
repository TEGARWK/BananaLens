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
    final isDark = theme.brightness == Brightness.dark;
    final borderInk = isDark
        ? theme.colorScheme.primary
        : const Color(0xFF181A16);
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.rButton),
        side: BorderSide(color: borderInk, width: 1.5),
      ),
      elevation: 0,
      minimumSize: Size(
        fullWidth ? double.infinity : 88,
        height < 48 ? 48 : height,
      ),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
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
        icon: Icon(icon, size: 18),
        label: labelWidget,
      );
    } else {
      btn = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: labelWidget,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.rButton),
        boxShadow: onPressed != null && !isLoading
            ? <BoxShadow>[
                BoxShadow(
                  color: borderInk,
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF181A16).withValues(alpha: 0.14),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.55),
            width: 1.2,
          ),
        ),
        child: btn,
      ),
    );
  }
}
