import 'package:flutter/material.dart';

/// Central color definitions for BananaLens following a strict 60-30-10 rule:
/// - 60% Primary Base: Warm Banana White (`#FFFDF7`), Crisp White (`#FFFFFF`), Soft Banana Cream (`#FFF6DC`)
/// - 30% Secondary Brand: Ripe Banana Gold (`#F4C418`) + Dark Chocolate Brown (`#3B2112`) — ZERO BLACK
/// - 10% Accent: Fresh Banana Leaf Green (`#5D9412` / `#A3D955` / `#EEF7DF`)
abstract final class AppColors {
  // ── Light Mode (60% Warm White/Cream · 30% Yellow & Dark Brown · 10% Green) ──
  static const Color lBackground = Color(0xFFFFFDF7); // 60%: Warm Banana White
  static const Color lSurface = Color(0xFFFFFFFF); // 60%: Pure Crisp White
  static const Color lPrimarySoft = Color(0xFFFFF6DC); // 60%: Soft Banana Cream
  static const Color lBorder = Color(0xFFEADCC5); // Subtle Warm Sand Hairline

  static const Color lPrimary = Color(0xFFF4C418); // 30%: Ripe Banana Gold
  static const Color lOnPrimary = Color(0xFF3B2112); // 30%: Dark Chocolate Ink
  static const Color lAccent = Color(0xFF3B2112); // 30%: Dark Chocolate Brown
  static const Color lAccentWarm = Color(
    0xFF54321D,
  ); // 30%: Deep Espresso Brown
  static const Color lSurfaceDark = Color(
    0xFF3B2112,
  ); // 30%: Dark Chocolate Block (no black)
  static const Color lText = Color(
    0xFF3B2112,
  ); // 30%: Dark Chocolate Ink (WCAG AAA)
  static const Color lMuted = Color(0xFF6E5240); // Dark Cocoa Muted

  static const Color lLeafGreen = Color(
    0xFFA3D955,
  ); // 10%: Fresh Light Leaf Green
  static const Color lLeafStrong = Color(
    0xFF5D9412,
  ); // 10%: Leaf Green for text/icons
  static const Color lLeafSoft = Color(0xFFEEF7DF); // 10%: Soft Leaf Green Tint
  static const Color lError = Color(0xFFC43E2B); // Semantic Brick Red

  // ── Dark Mode (Dark Chocolate Night — zero pure black) ──
  static const Color dBackground = Color(0xFF21130B); // Deep Dark Chocolate
  static const Color dSurface = Color(0xFF2E1B10); // Dark Chocolate Card
  static const Color dPrimarySoft = Color(0xFF3B2315); // Espresso Surface
  static const Color dSurfaceDark = Color(
    0xFF1A0F08,
  ); // Deepest Chocolate Block
  static const Color dPrimary = Color(0xFFF4C418); // Ripe Banana Gold
  static const Color dOnPrimary = Color(0xFF3B2112); // Dark Chocolate Ink
  static const Color dAccent = Color(
    0xFFC48B5C,
  ); // Warm Cocoa Accent (dark mode contrast)
  static const Color dAccentWarm = Color(0xFF8C5A34); // Deep Caramel
  static const Color dLeafGreen = Color(0xFFA3D955); // Fresh Light Leaf Green
  static const Color dLeafStrong = Color(0xFF9CCC65); // Leaf Green Dark Mode
  static const Color dLeafSoft = Color(0xFF273618); // Dark Leaf Tint
  static const Color dText = Color(0xFFFFF9EC); // Warm Banana Cream Ink
  static const Color dMuted = Color(0xFFC8B09A); // Warm Latte Muted
  static const Color dBorder = Color(0xFF4A2E1D); // Dark Chocolate Hairline
  static const Color dError = Color(0xFFFF6B57); // Soft Coral Red

  static const Color onAccent = Color(
    0xFFFFFDF7,
  ); // Warm White on Dark Chocolate
  static const Color instrumentInk = Color(0xFF3B2112);
  static const Color trackInactive = Color(0xFFF0E4CF);

  // Backward compatibility aliases
  static const Color primarySeed = lPrimary;
  static const Color secondarySeed = lAccent;
  static const Color tertiarySeed = lLeafStrong;
  static const Color lightBackground = lBackground;
  static const Color lightSurface = lSurface;
  static const Color lightSurfaceVariant = lPrimarySoft;
  static const Color darkBackground = dBackground;
  static const Color darkSurface = dSurface;
  static const Color darkSurfaceVariant = dPrimarySoft;
}

/// Semantic colors for fruit ripeness status.
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
    unripe: Color(0xFF5D9412),
    unripeContainer: Color(0xFFEEF7DF),
    onUnripeContainer: Color(0xFF335409),
    ripe: Color(0xFFE6B00E),
    ripeContainer: Color(0xFFFFF6DC),
    onRipeContainer: Color(0xFF3B2112),
    overripe: Color(0xFFB86B27),
    overripeContainer: Color(0xFFFAEAD9),
    onOverripeContainer: Color(0xFF3B2112),
    rotten: Color(0xFFC43E2B),
    rottenContainer: Color(0xFFFCE9E6),
    onRottenContainer: Color(0xFF7D2215),
  );

  static const RipenessColors dark = RipenessColors(
    unripe: Color(0xFFA3D955),
    unripeContainer: Color(0xFF273618),
    onUnripeContainer: Color(0xFFDDF2BE),
    ripe: Color(0xFFF4C418),
    ripeContainer: Color(0xFF3D2E0E),
    onRipeContainer: Color(0xFFFFF5CC),
    overripe: Color(0xFFE0964F),
    overripeContainer: Color(0xFF3E2614),
    onOverripeContainer: Color(0xFFFFE1C2),
    rotten: Color(0xFFFF6B57),
    rottenContainer: Color(0xFF421C17),
    onRottenContainer: Color(0xFFFFD1CA),
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
