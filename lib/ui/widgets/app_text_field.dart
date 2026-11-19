import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_radius.dart';
import 'package:fruitlens/core/theme/app_spacing.dart';

/// Standardized, tactile form input field with a clear top label,
/// high-visibility yellow active border, and smooth tilt animation on focus.
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
    final inkColor = widget.prefixIconColor ?? colorScheme.onSurface;
    final activeYellow = colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: _isFocused ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double t, Widget? child) {
            return Transform.rotate(
              angle: -0.014 * t,
              child: Transform.scale(scale: 1.0 + (0.012 * t), child: child),
            );
          },
          child: Focus(
            onFocusChange: (bool focused) {
              if (_isFocused != focused) {
                setState(() => _isFocused = focused);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md + 2),
                border: Border.all(
                  color: _isFocused ? activeYellow : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: _isFocused
                    ? <BoxShadow>[
                        BoxShadow(
                          color: activeYellow,
                          offset: const Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                onFieldSubmitted: widget.onFieldSubmitted,
                obscureText: widget.obscureText,
                textCapitalization: widget.textCapitalization,
                validator: widget.validator,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
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
                    vertical: 13,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 10, right: 8),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: activeYellow.withValues(
                                alpha: _isFocused ? 0.85 : 0.35,
                              ),
                              borderRadius: AppRadius.roundedSm,
                              border: Border.all(
                                color: inkColor.withValues(
                                  alpha: _isFocused ? 1.0 : 0.7,
                                ),
                                width: _isFocused ? 1.4 : 1,
                              ),
                            ),
                            child: Icon(
                              widget.prefixIcon,
                              size: 17,
                              color: inkColor,
                            ),
                          ),
                        )
                      : null,
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 36,
                  ),
                  suffixIcon: widget.suffixIcon,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.roundedMd,
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.roundedMd,
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.roundedMd,
                    borderSide: BorderSide(color: inkColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: AppRadius.roundedMd,
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: AppRadius.roundedMd,
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
