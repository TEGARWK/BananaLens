import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_radius.dart';
import 'package:fruitlens/core/theme/app_spacing.dart';

/// Clean, flat editorial form input field with tonal Soft Oat idle fill
/// and crisp Roasted Cocoa focus state — zero double strokes or hard shadows.
class AppTextField extends StatefulWidget {
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
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final focusColor = widget.prefixIconColor ?? colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 6),
        Focus(
          onFocusChange: (bool focused) {
            if (_isFocused != focused) {
              setState(() => _isFocused = focused);
            }
          },
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            obscureText: widget.obscureText,
            textCapitalization: widget.textCapitalization,
            validator: widget.validator,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                fontWeight: FontWeight.w400,
                fontSize: 13.5,
              ),
              suffixText: widget.suffixText,
              suffixStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              filled: true,
              fillColor: _isFocused
                  ? colorScheme.surface
                  : colorScheme.primaryContainer,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: _isFocused
                            ? focusColor
                            : colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 36,
              ),
              suffixIcon: widget.suffixIcon,
              border: const OutlineInputBorder(
                borderRadius: AppRadius.roundedMd,
                borderSide: BorderSide.none,
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: AppRadius.roundedMd,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.roundedMd,
                borderSide: BorderSide(color: focusColor, width: 1.4),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppRadius.roundedMd,
                borderSide: BorderSide(color: colorScheme.error, width: 1.2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppRadius.roundedMd,
                borderSide: BorderSide(color: colorScheme.error, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
