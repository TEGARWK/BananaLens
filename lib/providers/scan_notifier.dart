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
  String? _pendingImagePath;

  /// The image path currently being scanned (used by loading UI).
  String? get pendingImagePath => _pendingImagePath;

  @override
  ScanReport? build() => null;

  /// Runs a scan for [imagePath] and publishes the outcome.
  Future<void> scan(String imagePath) async {
    _pendingImagePath = imagePath;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _run(imagePath));
  }

  /// Clears the last result (e.g. when the user retakes the photo).
  void reset() {
    _pendingImagePath = null;
    state = const AsyncData(null);
  }

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
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    final minScanDelay = isTest
        ? Future<void>.value()
        : Future<void>.delayed(const Duration(milliseconds: 1100));

    final raw = await ref.read(scanServiceProvider).scan(imagePath);
    await minScanDelay;
    final outcome = _applyThreshold(raw);
    if (outcome is! ScanSuccess) {
      return ScanReport(imagePath: imagePath, outcome: outcome);
    }
    final info = await ref
        .read(fruitInfoRepositoryProvider)
        .getByLabel(outcome.fruitLabel);

    // Salin foto ke folder dokumen permanen aplikasi agar tidak terhapus cache OS
    final permanentPath = await _persistImage(imagePath);

    // Simpan akurasi kematangan aktual & probabilitas 3 kelas ke riwayat lokal.
    final probs = outcome.classProbabilities;
    final hasRipeSplit =
        probs != null &&
        (probs.containsKey('ripe') || probs.containsKey('overripe'));
    final resultRecord = ScanResult(
      imagePath: permanentPath,
      fruitLabel: outcome.fruitLabel,
      ripenessLabel: outcome.ripenessLabel,
      confidence: outcome.ripenessConfidence,
      createdAt: DateTime.now(),
      unripeProb: probs?['unripe'],
      ripeProb: hasRipeSplit
          ? (probs['ripe'] ?? 0.0) + (probs['overripe'] ?? 0.0)
          : null,
      rottenProb: probs?['rotten'],
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

  /// Rejects genuinely uncertain predictions below [kUncertainThreshold] while
  /// allowing mid-confidence (`0.35..0.59`) predictions through with UI warning.
  ScanOutcome _applyThreshold(ScanOutcome outcome) {
    if (outcome is ScanSuccess &&
        (outcome.fruitConfidence < kUncertainThreshold ||
            outcome.ripenessConfidence < kUncertainThreshold)) {
      return const ScanUncertain();
    }
    return outcome;
  }
}
