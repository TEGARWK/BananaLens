import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlens/providers/server_config_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('ServerConfigNotifier (Dio)', () {
    test('loads defaults and persists address and fallback toggle', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(serverConfigProvider).serverAddress,
        ServerConfigNotifier.defaultAddress,
      );
      expect(container.read(serverConfigProvider).useFallback, isTrue);

      final notifier = container.read(serverConfigProvider.notifier);
      await notifier.updateAddress('http://192.168.1.50:8000/');
      await notifier.setUseFallback(false);

      final updated = container.read(serverConfigProvider);
      expect(updated.serverAddress, 'http://192.168.1.50:8000/');
      expect(updated.baseUrl, 'http://192.168.1.50:8000/');
      expect(updated.useFallback, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('server_config_address'),
        'http://192.168.1.50:8000/',
      );
      expect(prefs.getBool('server_config_fallback'), isFalse);
    });

    test('sets online status with backend model info on valid GET /', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mockClient = _mockDio((options) async {
        expect(options.method, 'GET');
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'status': 'Server Aktif',
            'service': 'FruitLens AI Backend',
            'model': 'Hybrid MobileNetV3Small (576) + HSV (30) -> PCA + SVM',
            'classes': ['ripe', 'rotten', 'unripe'],
          },
        );
      });

      final notifier = container.read(serverConfigProvider.notifier);
      final ok = await notifier.testConnection(mockClient);

      expect(ok, isTrue);
      final state = container.read(serverConfigProvider);
      expect(state.status, ServerConnectionStatus.online);
      expect(state.statusMessage, contains('Hybrid MobileNetV3Small'));
    });

    test('sets offline status when server is unreachable or errors', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final offlineClient = _mockDio((options) async {
        throw DioException(
          requestOptions: options,
          error: 'Connection refused',
          type: DioExceptionType.connectionError,
        );
      });

      final notifier = container.read(serverConfigProvider.notifier);
      final ok = await notifier.testConnection(offlineClient);

      expect(ok, isFalse);
      final state = container.read(serverConfigProvider);
      expect(state.status, ServerConnectionStatus.offline);
      expect(state.statusMessage, contains('Tidak dapat menjangkau'));
    });
  });
}
