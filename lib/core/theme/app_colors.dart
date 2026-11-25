import 'package:flutter/material.dart';

/// Central color definitions for BananaLens following a strict 60-30-10 rule:
/// - 60% Primary Base: Warm Banana White (`#FFFDF7`), Crisp White (`#FFFFFF`), Soft Banana Cream (`#FFF6DC`)
/// - 30% Secondary Brand: Ripe Banana Gold (`#F4C418`) + Dark Chocolate Brown (`#3B2112`) — ZERO BLACK
/// - 10% Accent: Fresh Banana Leaf Green (`#5D9412` / `#A3D955` / `#EEF7DF`)
abstract final class AppColors {
  // ── Light Mode (Banana Yellow, Brown, Cream, Soft Beige, Leaf Green, Ripe Orange) ──
  static const Color lBackground = Color(0xFFFFF9ED); // Banana Cream
  static const Color lSurface = Color(0xFFFFFFFF); // Crisp White Card
  static const Color lPrimarySoft = Color(0xFFFAF8F5); // Clean Warm Off-White
  static const Color lBorder = Color(
    0xFFF0EDE6,
  ); // Soft Off-White Border & Divider

  static const Color lPrimary = Color(0xFFFFC914); // Banana Yellow
  static const Color lOnPrimary = Color(0xFF3B2417); // Banana Brown Ink
  static const Color lAccent = Color(0xFF3B2417); // Banana Brown Secondary
  static const Color lAccentWarm = Color(0xFF543422); // Warm Banana Brown
  static const Color lSurfaceDark = Color(
    0xFF3B2417,
  ); // Banana Brown Dark Block
  static const Color lText = Color(0xFF3B2417); // Banana Brown Primary Text
  static const Color lMuted = Color(0xFF6E5240); // Soft Cocoa Muted

  static const Color lLeafGreen = Color(0xFFA3D955); // Light Leaf Tint
  static const Color lLeafStrong = Color(0xFF2F7D46); // Leaf Green Success
  static const Color lLeafSoft = Color(0xFFE9F4EC); // Soft Leaf Green Tint
  static const Color lError = Color(0xFFC43E2B); // Semantic Brick Red

  // ── Dark Mode (Banana Brown Night) ──
  static const Color dBackground = Color(0xFF26160D); // Deep Banana Brown
  static const Color dSurface = Color(0xFF3B2417); // Banana Brown Dark Surface
  static const Color dPrimarySoft = Color(0xFF4A2E1E); // Warm Espresso Surface
  static const Color dSurfaceDark = Color(0xFF1D110A); // Deepest Brown Block
  static const Color dPrimary = Color(0xFFFFC914); // Banana Yellow
  static const Color dOnPrimary = Color(0xFF3B2417); // Banana Brown Ink
  static const Color dAccent = Color(
    0xFFC48B5C,
  ); // Warm Cocoa Accent (dark mode contrast)
  static const Color dAccentWarm = Color(0xFF8C5A34); // Deep Caramel
  static const Color dLeafGreen = Color(0xFF4CAF6A); // Leaf Green Dark Mode
  static const Color dLeafStrong = Color(0xFF66C782); // Bright Leaf Green
  static const Color dLeafSoft = Color(0xFF1E3524); // Dark Leaf Tint
  static const Color dText = Color(0xFFFFF9ED); // Banana Cream Ink
  static const Color dMuted = Color(0xFFC8B09A); // Warm Latte Muted
  static const Color dBorder = Color(0xFF523424); // Banana Brown Hairline
  static const Color dError = Color(0xFFFF6B57); // Soft Coral Red

  static const Color onAccent = Color(0xFFFFF9ED); // Banana Cream on Brown
  static const Color instrumentInk = Color(0xFF3B2417);
  static const Color trackInactive = Color(0xFFF0EDE6);

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
    unripe: Color(0xFF2F7D46),
    unripeContainer: Color(0xFFE9F4EC),
    onUnripeContainer: Color(0xFF1D522D),
    ripe: Color(0xFFFFC914),
    ripeContainer: Color(0xFFFFF9ED),
    onRipeContainer: Color(0xFF3B2417),
    overripe: Color(0xFFC66A28),
    overripeContainer: Color(0xFFFBECE0),
    onOverripeContainer: Color(0xFF3B2417),
    rotten: Color(0xFFC43E2B),
    rottenContainer: Color(0xFFFCE9E6),
    onRottenContainer: Color(0xFF7D2215),
  );

  static const RipenessColors dark = RipenessColors(
    unripe: Color(0xFF4CAF6A),
    unripeContainer: Color(0xFF1E3524),
    onUnripeContainer: Color(0xFFD5F2DD),
    ripe: Color(0xFFFFC914),
    ripeContainer: Color(0xFF44320F),
    onRipeContainer: Color(0xFFFFF9ED),
    overripe: Color(0xFFE38A47),
    overripeContainer: Color(0xFF452815),
    onOverripeContainer: Color(0xFFFFE1C7),
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
