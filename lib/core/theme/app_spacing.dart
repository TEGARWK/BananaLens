import 'package:flutter/material.dart';

/// Spacing scale based on 4pt/8pt system.
abstract final class AppSpacing {
  /// 2pt - Minimal micro-spacing
  static const double xxs = 2.0;

  /// 4pt - Extra small spacing
  static const double xs = 4.0;

  /// 8pt - Small spacing
  static const double sm = 8.0;

  /// 12pt - Medium-small spacing
  static const double mdSm = 12.0;

  /// 16pt - Standard/Medium spacing
  static const double md = 16.0;

  /// 20pt - Medium-large spacing
  static const double lgSm = 20.0;

  /// 24pt - Large spacing
  static const double lg = 24.0;

  /// 32pt - Extra large spacing
  static const double xl = 32.0;

  /// 48pt - Double extra large spacing
  static const double xxl = 48.0;

  /// 64pt - Hero/Section spacing
  static const double xxxl = 64.0;

  // Insets helpers
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets compactCardPadding = EdgeInsets.all(sm);
}
