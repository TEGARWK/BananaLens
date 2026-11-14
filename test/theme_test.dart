import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    test('lightTheme has Material 3 enabled and HarvestColors extension', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);

      final harvest = theme.extension<HarvestColors>();
      expect(harvest, isNotNull);
      expect(harvest!.unripe, equals(const Color(0xFF7CB342)));
      expect(harvest.ripe, equals(const Color(0xFFF5B700)));
      expect(harvest.overripe, equals(const Color(0xFFFF8A3D)));
      expect(harvest.rotten, equals(const Color(0xFFE5484D)));
    });

    test('darkTheme has Material 3 enabled and HarvestColors extension', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);

      final harvest = theme.extension<HarvestColors>();
      expect(harvest, isNotNull);
      expect(harvest!.unripe, equals(const Color(0xFF9CCC65)));
      expect(harvest.ripe, equals(const Color(0xFFFACC15)));
    });

    test('Spacing and Radius scales follow design tokens', () {
      expect(AppSpacing.xs, equals(4.0));
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.md, equals(16.0));
      expect(AppSpacing.lg, equals(24.0));

      expect(AppRadius.sm, equals(8.0));
      expect(AppRadius.md, equals(12.0));
      expect(AppRadius.lg, equals(16.0));
      expect(AppRadius.full, equals(999.0));

      expect(AppDimens.rCard, equals(20.0));
      expect(AppDimens.rButton, equals(14.0));
      expect(AppDimens.rHero, equals(22.0));
    });
  });
}
