import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'harvest_colors.dart';

/// Central theme provider generating Material 3 themes for BananaLens:
/// - Light: Warm Cream Paper + Ripe Banana Gold + Roasted Cocoa Brown (Editorial Flat)
/// - Dark: Roasted Espresso + Ripe Banana Gold + Toasted Caramel
abstract final class AppTheme {
  static TextStyle _font(
    TextStyle Function({TextStyle? textStyle}) fontLoader,
    TextStyle baseStyle,
  ) {
    if (_isTestEnvironment) {
      return baseStyle;
    }
    try {
      return fontLoader(textStyle: baseStyle);
    } catch (_) {
      return baseStyle;
    }
  }

  static bool get _isTestEnvironment {
    final binding = WidgetsBinding.instance;
    return binding.runtimeType.toString().contains('TestWidgetsFlutterBinding');
  }

  /// Bold editorial display typography for hero headings and numeric KPI readouts.
  static TextStyle pixelDisplayStyle(
    BuildContext context, {
    double fontSize = 36,
    Color? color,
  }) {
    final ink = color ?? Theme.of(context).colorScheme.onSurface;
    return _font(
      GoogleFonts.spaceGrotesk,
      TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: ink,
        letterSpacing: -0.8,
        height: 1.05,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  static TextTheme _buildTextTheme(Color textColor, Color mutedColor) {
    return TextTheme(
      displaySmall: _font(
        GoogleFonts.spaceGrotesk,
        TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.9,
          height: 1.05,
          color: textColor,
        ),
      ),
      headlineLarge: _font(
        GoogleFonts.spaceGrotesk,
        TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          height: 1.12,
          color: textColor,
        ),
      ),
      headlineMedium: _font(
        GoogleFonts.spaceGrotesk,
        TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          height: 1.15,
          color: textColor,
        ),
      ),
      headlineSmall: _font(
        GoogleFonts.spaceGrotesk,
        TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: textColor,
        ),
      ),
      titleLarge: _font(
        GoogleFonts.spaceGrotesk,
        TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: textColor,
        ),
      ),
      titleMedium: _font(
        GoogleFonts.spaceGrotesk,
        TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
          color: textColor,
        ),
      ),
      bodyLarge: _font(
        GoogleFonts.inter,
        TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          height: 1.45,
          color: textColor,
        ),
      ),
      bodyMedium: _font(
        GoogleFonts.inter,
        TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
          height: 1.45,
          color: textColor,
        ),
      ),
      bodySmall: _font(
        GoogleFonts.inter,
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: mutedColor,
        ),
      ),
      labelLarge: _font(
        GoogleFonts.spaceGrotesk,
        TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: textColor,
        ),
      ),
      labelMedium: _font(
        GoogleFonts.jetBrainsMono,
        TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: textColor,
        ),
      ),
      labelSmall: _font(
        GoogleFonts.jetBrainsMono,
        TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.9,
          color: mutedColor,
        ),
      ),
    );
  }

  /// Builds Light Editorial Flat [ThemeData].
  static ThemeData get lightTheme => light();

  /// Builds Light Editorial Flat [ThemeData].
  static ThemeData light() {
    const primary = AppColors.lPrimary;
    const secondary = AppColors.lAccent;
    const surface = AppColors.lSurface;
    const background = AppColors.lBackground;
    const textPrimary = AppColors.lText;
    const textMuted = AppColors.lMuted;
    const border = AppColors.lBorder;
    const error = AppColors.lError;

    final textTheme = _buildTextTheme(textPrimary, textMuted);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: AppColors.lOnPrimary,
        primaryContainer: AppColors.lPrimarySoft,
        onPrimaryContainer: secondary,
        secondary: secondary,
        onSecondary: AppColors.onAccent,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: Colors.white,
        outline: border,
        outlineVariant: border,
      ),
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[
        HarvestColors.light,
        RipenessColors.light,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rCard),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lPrimarySoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.mdSm,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          borderSide: const BorderSide(color: secondary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          borderSide: const BorderSide(color: error, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.lOnPrimary,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.rButton),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondary,
          minimumSize: const Size(88, 48),
          side: const BorderSide(color: border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.rButton),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: AppColors.onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lSurfaceDark,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.lBackground,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
        ),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rCard),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTopRadius),
      ),
    );
  }

  /// Builds Dark Roasted Espresso [ThemeData].
  static ThemeData get darkTheme => dark();

  /// Builds Dark Roasted Espresso [ThemeData].
  static ThemeData dark() {
    const primary = AppColors.dPrimary;
    const secondary = AppColors.dAccent;
    const surface = AppColors.dSurface;
    const background = AppColors.dBackground;
    const textPrimary = AppColors.dText;
    const textMuted = AppColors.dMuted;
    const border = AppColors.dBorder;
    const error = AppColors.dError;

    final textTheme = _buildTextTheme(textPrimary, textMuted);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: AppColors.dOnPrimary,
        primaryContainer: AppColors.dPrimarySoft,
        onPrimaryContainer: primary,
        secondary: secondary,
        onSecondary: AppColors.dOnPrimary,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: AppColors.dOnPrimary,
        outline: border,
        outlineVariant: border,
      ),
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[
        HarvestColors.dark,
        RipenessColors.dark,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rCard),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.dPrimarySoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.mdSm,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          borderSide: const BorderSide(color: error, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.dOnPrimary,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.rButton),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(88, 48),
          side: const BorderSide(color: border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.rButton),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: AppColors.dOnPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.dPrimarySoft,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
        ),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rCard),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTopRadius),
      ),
    );
  }
}
