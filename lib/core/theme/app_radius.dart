import 'package:flutter/material.dart';

/// Corner radius scale for crisp editorial flat cards, buttons, dialogs, and sheets.
abstract final class AppRadius {
  /// 2pt - Crisp editorial tags & micro-bars
  static const double xs = 2.0;

  /// 4pt - Small chips & icon boxes
  static const double sm = 4.0;

  /// 6pt - Buttons & input fields
  static const double md = 6.0;

  /// 8pt - Standard editorial cards & dialogs
  static const double lg = 8.0;

  /// 16pt - Bottom sheets & hero panels
  static const double xl = 16.0;

  /// 999pt - Full pill rounding (FAB / circular badges)
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
