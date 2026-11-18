import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fruitlens/data/models/fruit_info.dart';
import 'package:fruitlens/data/sources/app_database.dart';

/// Read access to fruit nutrition and unripe-edibility data.
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
    final normalized = label.trim().toLowerCase();
    for (final info in all) {
      if (info.label.toLowerCase() == normalized) {
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

/// SQLite-backed implementation of [FruitInfoRepository] reading from `fruits` table.
class SqfliteFruitInfoRepository implements FruitInfoRepository {
  SqfliteFruitInfoRepository({
    AppDatabase? appDatabase,
    AssetFruitInfoRepository? fallbackAssetRepo,
  }) : _appDatabase = appDatabase ?? AppDatabase.instance,
       _fallbackAssetRepo = fallbackAssetRepo ?? AssetFruitInfoRepository();

  final AppDatabase _appDatabase;
  final AssetFruitInfoRepository _fallbackAssetRepo;

  @override
  Future<List<FruitInfo>> getAll() async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(AppDatabase.fruitsTable);
      return rows.map(FruitInfo.fromMap).toList(growable: false);
    } on MissingPluginException {
      return _fallbackAssetRepo.getAll();
    } on StateError {
      return _fallbackAssetRepo.getAll();
    }
  }

  @override
  Future<FruitInfo?> getByLabel(String label) async {
    try {
      final db = await _appDatabase.database;
      final rows = await db.query(
        AppDatabase.fruitsTable,
        where: 'LOWER(label) = ?',
        whereArgs: <Object>[label.trim().toLowerCase()],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return FruitInfo.fromMap(rows.first);
    } on MissingPluginException {
      return _fallbackAssetRepo.getByLabel(label);
    } on StateError {
      return _fallbackAssetRepo.getByLabel(label);
    }
  }
}
