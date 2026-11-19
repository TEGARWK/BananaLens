import 'package:flutter/material.dart';

/// Central color definitions and brand seeds for BananaLens
/// "Instrument-Panel / Tactile Industrial Minimalism" (Light & Night).
abstract final class AppColors {
  // Light: Technical Paper + Banana Volt Yellow
  static const Color lPrimary = Color(0xFFF5D51E);
  static const Color lOnPrimary = Color(0xFF181A16);
  static const Color lPrimarySoft = Color(0xFFEAECE2);
  static const Color lAccent = Color(0xFFDEC010);
  static const Color lBackground = Color(0xFFF5F6F1);
  static const Color lSurface = Color(0xFFEBEDE3);
  static const Color lText = Color(0xFF181A16);
  static const Color lMuted = Color(0xFF6B7062);
  static const Color lBorder = Color(0xFFD8DBD0);
  static const Color lError = Color(0xFFC43E2B);

  // Dark: Night Instrument + Banana Volt Yellow
  static const Color dPrimary = Color(0xFFF5D51E);
  static const Color dOnPrimary = Color(0xFF181A16);
  static const Color dPrimarySoft = Color(0xFF262821);
  static const Color dAccent = Color(0xFFDEC010);
  static const Color dBackground = Color(0xFF121310);
  static const Color dSurface = Color(0xFF1B1D18);
  static const Color dText = Color(0xFFF2F3EE);
  static const Color dMuted = Color(0xFF9A9F90);
  static const Color dBorder = Color(0xFF31342B);
  static const Color dError = Color(0xFFFF6B57);

  static const Color onAccent = Color(0xFF181A16);
  static const Color instrumentInk = Color(0xFF181A16);
  static const Color trackInactive = Color(0xFFD4D7CC);

  // Backward compatibility alias
  static const Color primarySeed = lPrimary;
  static const Color secondarySeed = lAccent;
  static const Color tertiarySeed = Color(0xFF00796B);
  static const Color lightBackground = lBackground;
  static const Color lightSurface = lSurface;
  static const Color lightSurfaceVariant = lPrimarySoft;
  static const Color darkBackground = dBackground;
  static const Color darkSurface = dSurface;
  static const Color darkSurfaceVariant = dPrimarySoft;
}

/// Semantic colors for fruit ripeness status (backward compatibility).
@immutable
class RipenessColors extends ThemeExtension<RipenessColors> {
  const RipenessColors({
    required this.unripe,
    required this.unripeContainer,
    required this.onUnripeContainer,
    required this.ripe,
    required this.ripeContainer,
    required this.onRipeContainer,
    required this.overripe,
    required this.overripeContainer,
    required this.onOverripeContainer,
    required this.rotten,
    required this.rottenContainer,
    required this.onRottenContainer,
  });

  final Color unripe;
  final Color unripeContainer;
  final Color onUnripeContainer;

  final Color ripe;
  final Color ripeContainer;
  final Color onRipeContainer;

  final Color overripe;
  final Color overripeContainer;
  final Color onOverripeContainer;

  final Color rotten;
  final Color rottenContainer;
  final Color onRottenContainer;

  static const RipenessColors light = RipenessColors(
    unripe: Color(0xFF7CB342),
    unripeContainer: Color(0xFFE8F5E9),
    onUnripeContainer: Color(0xFF1B5E20),
    ripe: Color(0xFFF5B700),
    ripeContainer: Color(0xFFFFF9C4),
    onRipeContainer: Color(0xFFF57F17),
    overripe: Color(0xFFFF8A3D),
    overripeContainer: Color(0xFFFFE0B2),
    onOverripeContainer: Color(0xFFBF360C),
    rotten: Color(0xFFE5484D),
    rottenContainer: Color(0xFFFFEBEE),
    onRottenContainer: Color(0xFFB71C1C),
  );

  static const RipenessColors dark = RipenessColors(
    unripe: Color(0xFF9CCC65),
    unripeContainer: Color(0xFF1B3326),
    onUnripeContainer: Color(0xFFC8E6C9),
    ripe: Color(0xFFFACC15),
    ripeContainer: Color(0xFF332900),
    onRipeContainer: Color(0xFFFFFDE7),
    overripe: Color(0xFFFFA24D),
    overripeContainer: Color(0xFF381A05),
    onOverripeContainer: Color(0xFFFFE0B2),
    rotten: Color(0xFFFF6B70),
    rottenContainer: Color(0xFF3B1012),
    onRottenContainer: Color(0xFFFFCDD2),
  );

  @override
  RipenessColors copyWith({
    Color? unripe,
    Color? unripeContainer,
    Color? onUnripeContainer,
    Color? ripe,
    Color? ripeContainer,
    Color? onRipeContainer,
    Color? overripe,
    Color? overripeContainer,
    Color? onOverripeContainer,
    Color? rotten,
    Color? rottenContainer,
    Color? onRottenContainer,
  }) {
    return RipenessColors(
      unripe: unripe ?? this.unripe,
      unripeContainer: unripeContainer ?? this.unripeContainer,
      onUnripeContainer: onUnripeContainer ?? this.onUnripeContainer,
      ripe: ripe ?? this.ripe,
      ripeContainer: ripeContainer ?? this.ripeContainer,
      onRipeContainer: onRipeContainer ?? this.onRipeContainer,
      overripe: overripe ?? this.overripe,
      overripeContainer: overripeContainer ?? this.overripeContainer,
      onOverripeContainer: onOverripeContainer ?? this.onOverripeContainer,
      rotten: rotten ?? this.rotten,
      rottenContainer: rottenContainer ?? this.rottenContainer,
      onRottenContainer: onRottenContainer ?? this.onRottenContainer,
    );
  }

  @override
  RipenessColors lerp(ThemeExtension<RipenessColors>? other, double t) {
    if (other is! RipenessColors) {
      return this;
    }
    return RipenessColors(
      unripe: Color.lerp(unripe, other.unripe, t)!,
      unripeContainer: Color.lerp(unripeContainer, other.unripeContainer, t)!,
      onUnripeContainer: Color.lerp(
        onUnripeContainer,
        other.onUnripeContainer,
        t,
      )!,
      ripe: Color.lerp(ripe, other.ripe, t)!,
      ripeContainer: Color.lerp(ripeContainer, other.ripeContainer, t)!,
      onRipeContainer: Color.lerp(onRipeContainer, other.onRipeContainer, t)!,
      overripe: Color.lerp(overripe, other.overripe, t)!,
      overripeContainer: Color.lerp(
        overripeContainer,
        other.overripeContainer,
        t,
      )!,
      onOverripeContainer: Color.lerp(
        onOverripeContainer,
        other.onOverripeContainer,
        t,
      )!,
      rotten: Color.lerp(rotten, other.rotten, t)!,
      rottenContainer: Color.lerp(rottenContainer, other.rottenContainer, t)!,
      onRottenContainer: Color.lerp(
        onRottenContainer,
        other.onRottenContainer,
        t,
      )!,
    );
  }
}
