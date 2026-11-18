import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fruitlens/data/models/fruit_info.dart';
import 'package:fruitlens/data/models/recipe.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Centralized SQLite database helper for `fruitlens.db` (v3).
/// Manages `scan_results`, `fruits`, and `recipes` tables plus initial seed data.
class AppDatabase {
  AppDatabase({Future<String> Function(String key)? loadString, Database? db})
    : _loadString = loadString ?? rootBundle.loadString,
      _db = db;

  static final AppDatabase instance = AppDatabase();

  static const int currentVersion = 4;
  static const String dbFileName = 'fruitlens.db';
  static const String scanResultsTable = 'scan_results';
  static const String fruitsTable = 'fruits';
  static const String recipesTable = 'recipes';

  static const String fruitsAssetPath = 'assets/data/fruits.json';
  static const String recipesAssetPath = 'assets/data/recipes.json';

  final Future<String> Function(String key) _loadString;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    await ensureSeeded(_db!);
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbFileName);

    return openDatabase(
      path,
      version: currentVersion,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (Database db, int version) async {
        await _createScanResultsTable(db);
        await _createFruitsAndRecipesTables(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $scanResultsTable ADD COLUMN user_id TEXT NOT NULL DEFAULT "guest"',
          );
        }
        if (oldVersion < 3) {
          await _createFruitsAndRecipesTables(db);
        }
        if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE $scanResultsTable ADD COLUMN unripe_prob REAL',
          );
          await db.execute(
            'ALTER TABLE $scanResultsTable ADD COLUMN ripe_prob REAL',
          );
          await db.execute(
            'ALTER TABLE $scanResultsTable ADD COLUMN rotten_prob REAL',
          );
        }
      },
    );
  }

  static Future<void> _createScanResultsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $scanResultsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL DEFAULT 'guest',
        image_path TEXT NOT NULL,
        fruit_label TEXT NOT NULL,
        ripeness_label TEXT NOT NULL,
        confidence REAL NOT NULL,
        created_at TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        synced INTEGER NOT NULL DEFAULT 0,
        unripe_prob REAL,
        ripe_prob REAL,
        rotten_prob REAL
      )
    ''');
  }

  static Future<void> _createFruitsAndRecipesTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $fruitsTable (
        label TEXT PRIMARY KEY,
        name_id TEXT NOT NULL,
        calories REAL NOT NULL,
        carbs REAL NOT NULL,
        sugar REAL NOT NULL,
        fiber REAL NOT NULL,
        vitamins TEXT NOT NULL,
        benefits TEXT NOT NULL,
        storage_tips TEXT NOT NULL,
        allergen_note TEXT NOT NULL,
        edible_when_unripe INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $recipesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fruit_id TEXT NOT NULL,
        ripeness_bucket TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'food',
        ingredients TEXT NOT NULL,
        steps TEXT NOT NULL,
        safety_notes TEXT,
        is_reviewed INTEGER NOT NULL DEFAULT 0,
        prep_time TEXT NOT NULL DEFAULT '15 menit',
        difficulty TEXT NOT NULL DEFAULT 'Mudah',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (fruit_id) REFERENCES $fruitsTable (label) ON DELETE CASCADE
      )
    ''');
  }

  /// Seeds `fruits` and `recipes` tables from bundled JSON if they are empty.
  Future<void> ensureSeeded(Database db) async {
    final fruitsCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $fruitsTable'),
        ) ??
        0;

    if (fruitsCount == 0) {
      final rawFruits = await _loadString(fruitsAssetPath);
      final decodedFruits = jsonDecode(rawFruits) as List<Object?>;
      final batch = db.batch();
      for (final item in decodedFruits) {
        final fruit = FruitInfo.fromJson(item! as Map<String, Object?>);
        batch.insert(
          fruitsTable,
          fruit.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }

    final recipesCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $recipesTable'),
        ) ??
        0;

    if (recipesCount == 0) {
      final rawRecipes = await _loadString(recipesAssetPath);
      final decodedRecipes = jsonDecode(rawRecipes) as List<Object?>;
      final batch = db.batch();
      for (final item in decodedRecipes) {
        final recipe = Recipe.fromJson(item! as Map<String, Object?>);
        batch.insert(
          recipesTable,
          recipe.toMap(includeId: true),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }
}
