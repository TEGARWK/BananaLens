import 'package:flutter/material.dart';

/// Corner radius scale for cards, buttons, dialogs, and sheets.
abstract final class AppRadius {
  /// 4pt - Subtle rounding
  static const double xs = 4.0;

  /// 8pt - Small components (badges, tags)
  static const double sm = 8.0;

  /// 12pt - Medium components (input fields, small cards)
  static const double md = 12.0;

  /// 16pt - Standard cards & dialogs
  static const double lg = 16.0;

  /// 24pt - Bottom sheets & large cards
  static const double xl = 24.0;

  /// 999pt - Full pill rounding (FAB, chips, pills)
  static const double full = 999.0;

  // BorderRadius helpers
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedFull = BorderRadius.all(
    Radius.circular(full),
  );

  static const BorderRadius sheetTopRadius = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
