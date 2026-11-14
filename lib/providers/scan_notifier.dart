import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fruitlens/core/constants/app_constants.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/data/models/scan_report.dart';
import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/providers/auth_providers.dart';
import 'package:fruitlens/providers/history_providers.dart';
import 'package:fruitlens/providers/service_providers.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Holds the latest scan. `null` data means nothing scanned yet.
///
/// Loading / error / data map to the loading, failure and result states
/// of the result screen.
final scanProvider = AsyncNotifierProvider<ScanNotifier, ScanReport?>(
  ScanNotifier.new,
);

class ScanNotifier extends AsyncNotifier<ScanReport?> {
  @override
  ScanReport? build() => null;

  /// Runs a scan for [imagePath] and publishes the outcome.
  Future<void> scan(String imagePath) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _run(imagePath));
  }

  /// Clears the last result (e.g. when the user retakes the photo).
  void reset() => state = const AsyncData(null);

  Future<String> _persistImage(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!sourceFile.existsSync()) return sourcePath;

      final appDir = await getApplicationDocumentsDirectory();
      final scansDir = Directory(p.join(appDir.path, 'scans'));
      if (!scansDir.existsSync()) {
        await scansDir.create(recursive: true);
      }

      final ext = p.extension(sourcePath).isEmpty
          ? '.jpg'
          : p.extension(sourcePath);
      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}$ext';
      final permanentFile = await sourceFile.copy(
        p.join(scansDir.path, fileName),
      );
      return permanentFile.path;
    } catch (_) {
      return sourcePath;
    }
  }

  Future<ScanReport> _run(String imagePath) async {
    final raw = await ref.read(scanServiceProvider).scan(imagePath);
    final outcome = _applyThreshold(raw);
    if (outcome is! ScanSuccess) {
      return ScanReport(imagePath: imagePath, outcome: outcome);
    }
    final info = await ref
        .read(fruitInfoRepositoryProvider)
        .getByLabel(outcome.fruitLabel);

    // Salin foto ke folder dokumen permanen aplikasi agar tidak terhapus cache OS
    final permanentPath = await _persistImage(imagePath);

    // Simpan akurasi kematangan aktual ke riwayat lokal (bukan label jenis statis).
    final resultRecord = ScanResult(
      imagePath: permanentPath,
      fruitLabel: outcome.fruitLabel,
      ripenessLabel: outcome.ripenessLabel,
      confidence: outcome.ripenessConfidence,
      createdAt: DateTime.now(),
    );
    await ref.read(historyListProvider.notifier).add(resultRecord);

    final currentUser = ref.read(authNotifierProvider).asData?.value;
    if (currentUser != null) {
      unawaited(
        ref
            .read(cloudSyncServiceProvider)
            .syncPendingScans(
              currentUser.uid,
              ref.read(historyRepositoryProvider),
            ),
      );
    }

    return ScanReport(
      imagePath: permanentPath,
      outcome: outcome,
      fruitInfo: info,
    );
  }

  /// FR-11: below the threshold the app asks for a new photo.
  ScanOutcome _applyThreshold(ScanOutcome outcome) {
    if (outcome is ScanSuccess &&
        (outcome.fruitConfidence < kConfidenceThreshold ||
            outcome.ripenessConfidence < kConfidenceThreshold)) {
      return const ScanUncertain();
    }
    return outcome;
  }
}
