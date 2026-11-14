import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ServerConnectionStatus { initial, checking, online, offline }

class ServerConfigState {
  const ServerConfigState({
    required this.serverAddress,
    this.useFallback = true,
    this.status = ServerConnectionStatus.initial,
    this.statusMessage,
  });

  /// Address in format IP:PORT (e.g. 10.0.2.2:8000 or 192.168.1.15:8000)
  final String serverAddress;
  final bool useFallback;
  final ServerConnectionStatus status;
  final String? statusMessage;

  String get baseUrl {
    final cleaned = serverAddress
        .trim()
        .replaceAll('http://', '')
        .replaceAll('https://', '');
    return 'http://$cleaned';
  }

  ServerConfigState copyWith({
    String? serverAddress,
    bool? useFallback,
    ServerConnectionStatus? status,
    String? statusMessage,
  }) {
    return ServerConfigState(
      serverAddress: serverAddress ?? this.serverAddress,
      useFallback: useFallback ?? this.useFallback,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class ServerConfigNotifier extends Notifier<ServerConfigState> {
  static const _keyAddress = 'server_config_address';
  static const _keyFallback = 'server_config_fallback';
  static const defaultAddress = '10.0.2.2:8000';

  @override
  ServerConfigState build() {
    _loadFromPrefs();
    return const ServerConfigState(serverAddress: defaultAddress);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString(_keyAddress) ?? defaultAddress;
    final fallback = prefs.getBool(_keyFallback) ?? true;
    state = state.copyWith(serverAddress: address, useFallback: fallback);
  }

  Future<void> updateAddress(String address) async {
    final cleaned = address.trim();
    if (cleaned.isEmpty) return;
    state = state.copyWith(
      serverAddress: cleaned,
      status: ServerConnectionStatus.initial,
      statusMessage: null,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAddress, cleaned);
  }

  Future<void> setUseFallback(bool value) async {
    state = state.copyWith(useFallback: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFallback, value);
  }

  Future<bool> testConnection([Dio? client]) async {
    state = state.copyWith(
      status: ServerConnectionStatus.checking,
      statusMessage: null,
    );

    final dio =
        client ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 4),
            receiveTimeout: const Duration(seconds: 4),
          ),
        );
    final url = state.baseUrl;

    try {
      final res = await dio.get<dynamic>(url);
      if (res.statusCode == 200) {
        final dynamic rawData = res.data;
        final decoded = rawData is String ? jsonDecode(rawData) : rawData;
        if (decoded is Map<String, dynamic>) {
          final isServerAktif =
              decoded['status'] == 'Server Aktif' || decoded['service'] != null;
          if (isServerAktif) {
            final modelName =
                decoded['model']?.toString() ??
                decoded['architecture']?.toString() ??
                decoded['model_file']?.toString() ??
                'Hybrid AI';
            state = state.copyWith(
              status: ServerConnectionStatus.online,
              statusMessage: 'Server Aktif: $modelName',
            );
            return true;
          }
        }
      }
      state = state.copyWith(
        status: ServerConnectionStatus.offline,
        statusMessage: 'Server merespons kode: ${res.statusCode}',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: ServerConnectionStatus.offline,
        statusMessage: 'Tidak dapat menjangkau ${state.baseUrl}',
      );
      return false;
    }
  }
}

final serverConfigProvider =
    NotifierProvider<ServerConfigNotifier, ServerConfigState>(
      ServerConfigNotifier.new,
    );
