import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fruitlens/data/models/fruit_info.dart';

/// Read access to static fruit nutrition data.
abstract class FruitInfoRepository {
  /// Returns info for a model [label], or null when the fruit is unknown.
  Future<FruitInfo?> getByLabel(String label);

  Future<List<FruitInfo>> getAll();
}

/// Loads `assets/data/fruits.json` once and caches it.
class AssetFruitInfoRepository implements FruitInfoRepository {
  AssetFruitInfoRepository({Future<String> Function(String key)? loadString})
    : _loadString = loadString ?? rootBundle.loadString;

  static const String assetPath = 'assets/data/fruits.json';

  final Future<String> Function(String key) _loadString;
  Future<List<FruitInfo>>? _cache;

  @override
  Future<List<FruitInfo>> getAll() => _cache ??= _load();

  @override
  Future<FruitInfo?> getByLabel(String label) async {
    final all = await getAll();
    for (final info in all) {
      if (info.label == label) {
        return info;
      }
    }
    return null;
  }

  Future<List<FruitInfo>> _load() async {
    final raw = await _loadString(assetPath);
    final decoded = jsonDecode(raw) as List<Object?>;
    return decoded
        .map((e) => FruitInfo.fromJson(e! as Map<String, Object?>))
        .toList(growable: false);
  }
}
