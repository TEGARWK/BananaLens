import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'harvest_colors.dart';

/// Central theme provider generating Material 3 themes for FruitLens:
/// - Light: Fresh Harvest
/// - Dark: Night Harvest
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

  static TextTheme _buildTextTheme(Color textColor, Color mutedColor) {
    return TextTheme(
      headlineLarge: _font(
        GoogleFonts.poppins,
        TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textColor,
          fontFamily: 'Poppins',
        ),
      ),
      headlineMedium: _font(
        GoogleFonts.poppins,
        TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Poppins',
        ),
      ),
      titleLarge: _font(
        GoogleFonts.poppins,
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Poppins',
        ),
      ),
      titleMedium: _font(
        GoogleFonts.poppins,
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Poppins',
        ),
      ),
      bodyLarge: _font(
        GoogleFonts.inter,
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
          fontFamily: 'Inter',
        ),
      ),
      bodyMedium: _font(
        GoogleFonts.inter,
        TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          color: textColor,
          fontFamily: 'Inter',
        ),
      ),
      labelLarge: _font(
        GoogleFonts.inter,
        TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Inter',
        ),
      ),
      labelSmall: _font(
        GoogleFonts.inter,
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: mutedColor,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  /// Builds Fresh Harvest (Light) [ThemeData].
  static ThemeData get lightTheme => light();

  /// Builds Fresh Harvest (Light) [ThemeData].
  static ThemeData light() {
    const primary = AppColors.lPrimary;
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
        onPrimaryContainer: primary,
        secondary: AppColors.lAccent,
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
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.mdSm,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          borderSide: const BorderSide(color: error, width: 1),
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
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
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
        foregroundColor: AppColors.lOnPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedFull),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lText,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.lSurface,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rCard),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTopRadius),
      ),
    );
  }

  /// Builds Night Harvest (Dark) [ThemeData].
  static ThemeData get darkTheme => dark();

  /// Builds Night Harvest (Dark) [ThemeData].
  static ThemeData dark() {
    const primary = AppColors.dPrimary;
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
        secondary: AppColors.dAccent,
        onSecondary: AppColors.onAccent,
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
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.mdSm,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.rPill),
          borderSide: const BorderSide(color: error, width: 1),
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
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
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
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedFull),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rButton),
          side: const BorderSide(color: border, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rCard),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTopRadius),
      ),
    );
  }
}
