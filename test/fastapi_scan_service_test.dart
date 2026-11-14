import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/data/models/scan_outcome.dart';
import 'package:fruitlens/services/fastapi_scan_service.dart';

Dio _mockDio(Future<Response<dynamic>> Function(RequestOptions options) fn) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final res = await fn(options);
          handler.resolve(res);
        } on DioException catch (e) {
          handler.reject(e);
        } catch (e) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: e,
              type: DioExceptionType.unknown,
            ),
          );
        }
      },
    ),
  );
  return dio;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File testImageFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fastapi_test_');
    testImageFile = File('${tempDir.path}/test_banana.jpg');
    await testImageFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FastApiScanService (Dio)', () {
    test(
      'returns ScanSuccess with probabilities when FastAPI returns 200 success',
      () async {
        final mockClient = _mockDio((options) async {
          expect(options.path, contains('/predict'));
          expect(options.method, 'POST');
          return Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': 'success',
              'fruit_label': 'banana',
              'raw_class': 'ripe',
              'prediction': 'Matang',
              'confidence': 94.5,
              'details': {
                'unripe': 2.1,
                'ripe': 94.5,
                'overripe': 3.2,
                'rotten': 0.2,
              },
            },
          );
        });

        final service = FastApiScanService(
          baseUrl: 'http://10.0.2.2:8000',
          useFallback: false,
          client: mockClient,
        );

        final outcome = await service.scan(testImageFile.path);

        expect(outcome, isA<ScanSuccess>());
        final success = outcome as ScanSuccess;
        expect(success.fruitLabel, 'banana');
        expect(success.ripenessLabel, 'ripe');
        expect(success.ripenessConfidence, closeTo(0.945, 0.001));
        expect(success.classProbabilities, isNotNull);
        expect(success.classProbabilities!['ripe'], closeTo(0.945, 0.001));
        expect(success.classProbabilities!['unripe'], closeTo(0.021, 0.001));
      },
    );

    test('returns ScanUncertain when confidence < 25%', () async {
      final mockClient = _mockDio((options) async {
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'status': 'success',
            'fruit_label': 'banana',
            'raw_class': 'unripe',
            'confidence': 22.0,
            'details': {
              'unripe': 22.0,
              'ripe': 26.0,
              'overripe': 26.0,
              'rotten': 26.0,
            },
          },
        );
      });

      final service = FastApiScanService(
        baseUrl: 'http://10.0.2.2:8000',
        useFallback: false,
        client: mockClient,
      );

      final outcome = await service.scan(testImageFile.path);
      expect(outcome, isA<ScanUncertain>());
    });

    test(
      'returns ScanSuccess for 3-class model and ScanUncertain below 35%',
      () async {
        final mockSuccess = _mockDio((options) async {
          return Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': 'success',
              'fruit_label': 'banana',
              'raw_class': 'unripe',
              'prediction': 'Mentah',
              'confidence': 88.4,
              'details': {'ripe': 8.2, 'rotten': 3.4, 'unripe': 88.4},
            },
          );
        });

        final successOutcome = await FastApiScanService(
          baseUrl: 'http://10.0.2.2:8000',
          useFallback: false,
          client: mockSuccess,
        ).scan(testImageFile.path);

        expect(successOutcome, isA<ScanSuccess>());
        final success = successOutcome as ScanSuccess;
        expect(success.classProbabilities!.length, 3);
        expect(success.classProbabilities!['unripe'], closeTo(0.884, 0.001));

        final mockUncertain = _mockDio((options) async {
          return Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': 'success',
              'fruit_label': 'banana',
              'raw_class': 'ripe',
              'confidence': 34.0,
              'details': {'ripe': 34.0, 'rotten': 33.0, 'unripe': 33.0},
            },
          );
        });

        final uncertainOutcome = await FastApiScanService(
          baseUrl: 'http://10.0.2.2:8000',
          useFallback: false,
          client: mockUncertain,
        ).scan(testImageFile.path);
        expect(uncertainOutcome, isA<ScanUncertain>());
      },
    );

    test(
      'delegates to fallback when server returns error and useFallback is true',
      () async {
        final mockClient = _mockDio((options) async {
          throw DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 500,
              data: 'Internal Server Error',
            ),
            type: DioExceptionType.badResponse,
          );
        });

        final service = FastApiScanService(
          baseUrl: 'http://10.0.2.2:8000',
          useFallback: true,
          client: mockClient,
        );

        final outcome = await service.scan(testImageFile.path);
        // Fallback FakeScanService produces ScanSuccess
        expect(outcome, isA<ScanSuccess>());
      },
    );

    test(
      'returns ScanSuccess and normalizes fruit "Pisang" to "banana"',
      () async {
        final mockClient = _mockDio((options) async {
          return Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': 'success',
              'fruit': 'Pisang',
              'prediction': 'Mentah',
              'raw_class': 'unripe',
              'confidence': 91.2,
              'details': {'unripe': 91.2, 'ripe': 7.3, 'rotten': 1.5},
            },
          );
        });

        final service = FastApiScanService(
          baseUrl: 'http://10.0.2.2:8000',
          useFallback: false,
          client: mockClient,
        );

        final outcome = await service.scan(testImageFile.path);

        expect(outcome, isA<ScanSuccess>());
        final success = outcome as ScanSuccess;
        expect(success.fruitLabel, 'banana');
        expect(success.ripenessLabel, 'unripe');
        expect(success.ripenessConfidence, closeTo(0.912, 0.001));
      },
    );

    test(
      'returns ScanFailure when server fails and useFallback is false',
      () async {
        final mockClient = _mockDio((options) async {
          throw DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 503,
              data: 'Service Unavailable',
            ),
            type: DioExceptionType.badResponse,
          );
        });

        final service = FastApiScanService(
          baseUrl: 'http://10.0.2.2:8000',
          useFallback: false,
          client: mockClient,
        );

        final outcome = await service.scan(testImageFile.path);
        expect(outcome, isA<ScanFailure>());
      },
    );

    test('returns ScanFailure immediately when file does not exist', () async {
      final service = FastApiScanService(
        baseUrl: 'http://10.0.2.2:8000',
        useFallback: false,
      );

      final outcome = await service.scan('/non/existent/image.jpg');
      expect(outcome, isA<ScanFailure>());
      expect(
        (outcome as ScanFailure).message,
        contains('File foto tidak ditemukan'),
      );
    });
  });
}
