import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_radius.dart';
import 'package:fruitlens/core/theme/app_spacing.dart';

/// Standardized, clean form input field with a clear top label, rounded border,
/// prefix icon badge, and focus state.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.suffixText,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = prefixIconColor ?? colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.85),
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          validator: validator,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
              fontWeight: FontWeight.w400,
              fontSize: 13.5,
            ),
            suffixText: suffixText,
            suffixStyle: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 13,
            ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 10, right: 8),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Icon(prefixIcon, size: 17, color: iconColor),
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 36,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide(color: colorScheme.error, width: 1.3),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedMd,
              borderSide: BorderSide(color: colorScheme.error, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
