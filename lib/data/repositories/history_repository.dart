import 'package:fruitlens/data/models/scan_result.dart';
import 'package:fruitlens/data/sources/app_database.dart';
import 'package:sqflite/sqflite.dart';

/// Contract for managing scan history records.
abstract class HistoryRepository {
  Future<List<ScanResult>> getAll({String? userId});
  Future<List<ScanResult>> getUnsynced({String? userId});
  Future<ScanResult> insert(ScanResult item);
  Future<void> markAsSynced(int id);
  Future<void> delete(int id);
  Future<void> toggleFavorite(int id, bool isFavorite);
  Future<void> clearAll({String? userId});
}

/// SQLite-backed implementation of [HistoryRepository].
class SqfliteHistoryRepository implements HistoryRepository {
  SqfliteHistoryRepository({Database? db, AppDatabase? appDatabase})
    : _db = db,
      _appDatabase = appDatabase ?? AppDatabase.instance;

  static const String tableName = AppDatabase.scanResultsTable;
  final AppDatabase _appDatabase;
  Database? _db;

  Future<Database> get database async => _db ??= await _appDatabase.database;

  @override
  Future<List<ScanResult>> getAll({String? userId}) async {
    final db = await database;
    final List<Map<String, Object?>> maps;
    if (userId != null) {
      maps = await db.query(
        tableName,
        where: 'user_id = ?',
        whereArgs: <Object>[userId],
        orderBy: 'created_at DESC',
      );
    } else {
      maps = await db.query(tableName, orderBy: 'created_at DESC');
    }
    return maps.map(ScanResult.fromMap).toList();
  }

  @override
  Future<List<ScanResult>> getUnsynced({String? userId}) async {
    final db = await database;
    final List<Map<String, Object?>> maps;
    if (userId != null) {
      maps = await db.query(
        tableName,
        where: 'synced = ? AND user_id = ?',
        whereArgs: <Object>[0, userId],
        orderBy: 'created_at ASC',
      );
    } else {
      maps = await db.query(
        tableName,
        where: 'synced = ?',
        whereArgs: <Object>[0],
        orderBy: 'created_at ASC',
      );
    }
    return maps.map(ScanResult.fromMap).toList();
  }

  @override
  Future<ScanResult> insert(ScanResult item) async {
    final db = await database;
    final id = await db.insert(tableName, item.toMap());
    return item.copyWith(id: id);
  }

  @override
  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      tableName,
      <String, Object?>{'synced': 1},
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: <Object>[id]);
  }

  @override
  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      tableName,
      <String, Object?>{'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  @override
  Future<void> clearAll({String? userId}) async {
    final db = await database;
    if (userId != null) {
      await db.delete(
        tableName,
        where: 'user_id = ?',
        whereArgs: <Object>[userId],
      );
    } else {
      await db.delete(tableName);
    }
  }
}

/// In-memory implementation used for fast, reproducible tests.
class InMemoryHistoryRepository implements HistoryRepository {
  final List<ScanResult> _items = <ScanResult>[];
  int _nextId = 1;

  @override
  Future<List<ScanResult>> getAll({String? userId}) async {
    var list = List<ScanResult>.from(_items);
    if (userId != null) {
      list = list.where((item) => item.userId == userId).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<ScanResult>> getUnsynced({String? userId}) async {
    return _items.where((item) {
      if (item.synced) return false;
      if (userId != null && item.userId != userId) return false;
      return true;
    }).toList();
  }

  @override
  Future<ScanResult> insert(ScanResult item) async {
    final withId = item.copyWith(id: _nextId++);
    _items.add(withId);
    return withId;
  }

  @override
  Future<void> markAsSynced(int id) async {
    final idx = _items.indexWhere((item) => item.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(synced: true);
    }
  }

  @override
  Future<void> delete(int id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final idx = _items.indexWhere((item) => item.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(isFavorite: isFavorite);
    }
  }

  @override
  Future<void> clearAll({String? userId}) async {
    if (userId != null) {
      _items.removeWhere((item) => item.userId == userId);
    } else {
      _items.clear();
    }
  }
}
