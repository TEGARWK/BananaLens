import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/harvest_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.s16),
    this.margin,
    this.onTap,
    Color? color,
    Color? backgroundColor,
    this.borderColor,
    this.radius = AppDimens.rCard,
  }) : color = color ?? backgroundColor;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final harvest = context.harvest;
    final isDark = theme.brightness == Brightness.dark;

    final resolvedBorderColor = borderColor ?? harvest.border;
    final resolvedColor = color ?? theme.colorScheme.surface;

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: resolvedBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    if (margin != null) {
      return Padding(padding: margin!, child: _wrapInk(cardContent));
    }

    return _wrapInk(cardContent);
  }

  Widget _wrapInk(Widget content) {
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}
