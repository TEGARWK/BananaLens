import 'package:fruitlens/data/models/fruit_info.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';

/// Everything the result screen needs for one scan.
class ScanReport {
  const ScanReport({
    required this.imagePath,
    required this.outcome,
    this.fruitInfo,
  });

  final String imagePath;
  final ScanOutcome outcome;

  /// Nutrition data for a successful scan; null if the label is unknown.
  final FruitInfo? fruitInfo;
}
