import 'dart:io';
import 'package:dio/dio.dart';
import '../data/models/scan_outcome.dart';
import 'fake_scan_service.dart';
import 'scan_service.dart';

/// Calls the Python FastAPI server running MobileNetV3 + SVM using Dio.
/// If server is unreachable and [useFallback] is true, delegates to [fallbackService].
class FastApiScanService implements ScanService {
  FastApiScanService({
    required this.baseUrl,
    this.useFallback = true,
    Dio? client,
    ScanService? fallbackService,
  }) : client =
           client ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 15),
             ),
           ),
       fallbackService = fallbackService ?? FakeScanService();

  final String baseUrl;
  final bool useFallback;
  final Dio client;
  final ScanService fallbackService;

  @override
  Future<ScanOutcome> scan(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      return const ScanFailure('File foto tidak ditemukan di penyimpanan.');
    }

    try {
      final fileName = imagePath.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath, filename: fileName),
      });

      final url = '$baseUrl/predict';
      final response = await client.post<dynamic>(url, data: formData);

      if (response.statusCode != 200) {
        if (useFallback) {
          return await fallbackService.scan(imagePath);
        }
        return ScanFailure(
          'Server merespons galat status ${response.statusCode}: ${response.data}',
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic> || data['status'] != 'success') {
        if (useFallback) {
          return await fallbackService.scan(imagePath);
        }
        final message = data is Map<String, dynamic>
            ? data['message']?.toString()
            : null;
        return ScanFailure(message ?? 'Gagal memproses gambar');
      }

      final rawFruit = (data['fruit_label'] ?? data['fruit'] ?? 'banana')
          .toString();
      final fruitLabel = rawFruit.toLowerCase() == 'pisang'
          ? 'banana'
          : rawFruit;
      final rawRipeness = (data['raw_class'] ?? 'ripe').toString();
      final confidencePercent = (data['confidence'] as num?)?.toDouble() ?? 0.0;
      final ripenessConfidence = (confidencePercent / 100.0).clamp(0.0, 1.0);

      Map<String, double>? classProbabilities;
      if (data['details'] is Map) {
        final rawDetails = data['details'] as Map;
        classProbabilities = {};
        for (final entry in rawDetails.entries) {
          final val = (entry.value as num?)?.toDouble() ?? 0.0;
          classProbabilities[entry.key.toString()] = (val / 100.0).clamp(
            0.0,
            1.0,
          );
        }
      }

      // Scale uncertainty floor by active class count (~35% for 3-class, 25% for 4-class).
      final classCount = classProbabilities?.length ?? 4;
      final uncertaintyThreshold = classCount <= 3 ? 0.35 : 0.25;
      if (ripenessConfidence < uncertaintyThreshold) {
        return const ScanUncertain();
      }

      return ScanSuccess(
        fruitLabel: fruitLabel,
        ripenessLabel: rawRipeness,
        fruitConfidence: 0.98,
        ripenessConfidence: ripenessConfidence,
        classProbabilities: classProbabilities,
      );
    } catch (e) {
      if (useFallback) {
        return await fallbackService.scan(imagePath);
      }
      return ScanFailure(
        'Gagal menghubungi server AI di $baseUrl. Periksa koneksi Wi-Fi/Hotspot.',
      );
    }
  }
}
