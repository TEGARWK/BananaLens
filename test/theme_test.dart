import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/core/theme/app_colors.dart';
import 'package:fruitlens/core/theme/app_dimens.dart';
import 'package:fruitlens/core/theme/app_radius.dart';
import 'package:fruitlens/core/theme/app_spacing.dart';
import 'package:fruitlens/core/theme/app_theme.dart';
import 'package:fruitlens/core/theme/harvest_colors.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AppTheme & Tokens', () {
    test(
      'lightTheme follows 60-30-10 Banana White, Yellow/Cocoa, & Leaf Green',
      () {
        final theme = AppTheme.lightTheme;
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.primary, equals(AppColors.lPrimary));
        expect(theme.colorScheme.secondary, equals(AppColors.lAccent));
        expect(theme.scaffoldBackgroundColor, equals(AppColors.lBackground));

        final harvest = theme.extension<HarvestColors>();
        expect(harvest, isNotNull);
        expect(harvest!.accent, equals(const Color(0xFF3B2112)));
        expect(harvest.unripe, equals(const Color(0xFF5D9412)));
        expect(harvest.ripe, equals(const Color(0xFFE6B00E)));
        expect(harvest.overripe, equals(const Color(0xFFB86B27)));
        expect(harvest.rotten, equals(const Color(0xFFC43E2B)));
      },
    );

    test('darkTheme has Material 3 enabled and Warm Cocoa Night tokens', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, equals(AppColors.dPrimary));
      expect(theme.colorScheme.secondary, equals(AppColors.dAccent));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.dBackground));

      final harvest = theme.extension<HarvestColors>();
      expect(harvest, isNotNull);
      expect(harvest!.unripe, equals(const Color(0xFFA3D955)));
      expect(harvest.ripe, equals(const Color(0xFFF4C418)));
    });

    test('Spacing and crisp editorial Radius scales follow design tokens', () {
      expect(AppSpacing.xs, equals(4.0));
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.md, equals(16.0));
      expect(AppSpacing.lg, equals(24.0));

      expect(AppRadius.xs, equals(2.0));
      expect(AppRadius.sm, equals(4.0));
      expect(AppRadius.md, equals(6.0));
      expect(AppRadius.lg, equals(8.0));
      expect(AppRadius.xl, equals(16.0));
      expect(AppRadius.full, equals(999.0));

      expect(AppDimens.rSharp, equals(2.0));
      expect(AppDimens.rButton, equals(6.0));
      expect(AppDimens.rCard, equals(8.0));
      expect(AppDimens.rHero, equals(10.0));
    });
  });
}
