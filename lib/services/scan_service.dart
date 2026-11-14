import 'package:fruitlens/data/models/scan_outcome.dart';

/// Detects fruit type and ripeness from an image.
///
/// Real implementation (TFLite) is owned by track B, see
/// INTEGRATION_CONTRACT.md.
abstract class ScanService {
  /// Runs inference off the UI thread. Must never throw; failures are
  /// returned as [ScanFailure].
  Future<ScanOutcome> scan(String imagePath);
}
