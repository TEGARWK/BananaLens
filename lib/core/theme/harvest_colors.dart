import 'package:flutter/material.dart';
import '../../data/models/ripeness.dart';
import 'app_colors.dart';

@immutable
class HarvestColors extends ThemeExtension<HarvestColors> {
  final Color primarySoft;
  final Color accent;
  final Color onAccent;
  final Color muted;
  final Color border;
  final Color unripe;
  final Color ripe;
  final Color overripe;
  final Color rotten;

  const HarvestColors({
    required this.primarySoft,
    required this.accent,
    required this.onAccent,
    required this.muted,
    required this.border,
    required this.unripe,
    required this.ripe,
    required this.overripe,
    required this.rotten,
  });

  static const light = HarvestColors(
    primarySoft: AppColors.lPrimarySoft,
    accent: AppColors.lAccent,
    onAccent: AppColors.onAccent,
    muted: AppColors.lMuted,
    border: AppColors.lBorder,
    unripe: Color(0xFF7CB342),
    ripe: Color(0xFFF5B700),
    overripe: Color(0xFFFF8A3D),
    rotten: Color(0xFFE5484D),
  );

  static const dark = HarvestColors(
    primarySoft: AppColors.dPrimarySoft,
    accent: AppColors.dAccent,
    onAccent: AppColors.onAccent,
    muted: AppColors.dMuted,
    border: AppColors.dBorder,
    unripe: Color(0xFF9CCC65),
    ripe: Color(0xFFFACC15),
    overripe: Color(0xFFFFA24D),
    rotten: Color(0xFFFF6B70),
  );

  Color forRipeness(Ripeness r) {
    switch (r) {
      case Ripeness.unripe:
        return unripe;
      case Ripeness.ripe:
        return ripe;
      case Ripeness.overripe:
        return overripe;
      case Ripeness.rotten:
        return rotten;
    }
  }

  @override
  HarvestColors copyWith({
    Color? primarySoft,
    Color? accent,
    Color? onAccent,
    Color? muted,
    Color? border,
    Color? unripe,
    Color? ripe,
    Color? overripe,
    Color? rotten,
  }) => HarvestColors(
    primarySoft: primarySoft ?? this.primarySoft,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    muted: muted ?? this.muted,
    border: border ?? this.border,
    unripe: unripe ?? this.unripe,
    ripe: ripe ?? this.ripe,
    overripe: overripe ?? this.overripe,
    rotten: rotten ?? this.rotten,
  );

  @override
  HarvestColors lerp(ThemeExtension<HarvestColors>? other, double t) {
    if (other is! HarvestColors) return this;
    return HarvestColors(
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      unripe: Color.lerp(unripe, other.unripe, t)!,
      ripe: Color.lerp(ripe, other.ripe, t)!,
      overripe: Color.lerp(overripe, other.overripe, t)!,
      rotten: Color.lerp(rotten, other.rotten, t)!,
    );
  }
}

extension HarvestColorsX on BuildContext {
  HarvestColors get harvest =>
      Theme.of(this).extension<HarvestColors>() ?? HarvestColors.light;
}
