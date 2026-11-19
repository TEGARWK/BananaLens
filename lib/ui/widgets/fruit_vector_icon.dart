import 'package:flutter/material.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';

/// Renders a BananaLens industrial-style banana illustration matching the
/// ripeness state (`unripe`, `ripe`, or `rotten`).
class FruitVectorIcon extends StatelessWidget {
  const FruitVectorIcon({
    required this.fruitLabel,
    this.ripeness,
    this.size = 48,
    this.iconSize,
    this.isCircular = true,
    super.key,
  });

  final String fruitLabel;
  final String? ripeness;
  final double size;
  final double? iconSize;
  final bool isCircular;

  static _BananaIconStyle _styleFor(String? rawRipeness) {
    final norm = rawRipeness?.trim().toLowerCase() ?? 'ripe';
    return switch (norm) {
      'unripe' || 'mentah' => const _BananaIconStyle(
        assetPath: 'assets/images/fruits/banana_unripe.png',
        lightBg: Color(0xFFE6EED8),
        darkBg: Color(0xFF242F1B),
        accentColor: Color(0xFF4E7A27),
      ),
      'rotten' || 'busuk' => const _BananaIconStyle(
        assetPath: 'assets/images/fruits/banana_rotten.png',
        lightBg: Color(0xFFF1E2DC),
        darkBg: Color(0xFF33221D),
        accentColor: Color(0xFF7A4E2D),
      ),
      _ => const _BananaIconStyle(
        assetPath: 'assets/images/fruits/banana_ripe.png',
        lightBg: Color(0xFFF6EBB0),
        darkBg: Color(0xFF302B16),
        accentColor: Color(0xFFDEC010),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(ripeness);
    final innerSize = iconSize ?? (size * 0.74);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final resolvedBg = isDark ? style.darkBg : style.lightBg;
    final resolvedBorder = isDark
        ? style.accentColor.withValues(alpha: 0.7)
        : theme.colorScheme.onSurface;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: resolvedBg,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular
            ? null
            : BorderRadius.circular(AppDimens.rSharp),
        border: Border.all(color: resolvedBorder, width: 1.3),
      ),
      child: Center(
        child: Image.asset(
          style.assetPath,
          width: innerSize,
          height: innerSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, _, _) => Icon(
            Icons.eco_rounded,
            size: innerSize * 0.72,
            color: style.accentColor,
          ),
        ),
      ),
    );
  }
}

class _BananaIconStyle {
  const _BananaIconStyle({
    required this.assetPath,
    required this.lightBg,
    required this.darkBg,
    required this.accentColor,
  });

  final String assetPath;
  final Color lightBg;
  final Color darkBg;
  final Color accentColor;
}
