import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bananagrade.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE gradings (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            grade TEXT,
            confidence REAL,
            image_path TEXT,
            created_at TEXT,
            is_synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertGrading(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('gradings', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedGradings() async {
    final db = await database;
    return await db.query('gradings', where: 'is_synced = ?', whereArgs: [0]);
  }

  Future<List<Map<String, dynamic>>> getAllGradings() async {
    final db = await database;
    return await db.query('gradings', orderBy: 'created_at DESC');
  }

  Future<int> markAsSynced(String id) async {
    final db = await database;
    return await db.update(
      'gradings',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGrading(String id) async {
    final db = await database;
    return await db.delete('gradings', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAll() async {
    final db = await database;
    return await db.delete('gradings');
  }
}