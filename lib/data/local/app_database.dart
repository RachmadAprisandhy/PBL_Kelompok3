import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/grading_result.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, 'bananagrade.db');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE grading_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT NOT NULL,
            grade TEXT NOT NULL,
            confidence REAL NOT NULL,
            createdAt TEXT NOT NULL,
            note TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<int> insertResult(GradingResult result) async {
    final db = await database;
    final values = result.toMap()..remove('id');
    return db.insert('grading_results', values);
  }

  Future<List<GradingResult>> getResults() async {
    final db = await database;
    final rows = await db.query('grading_results', orderBy: 'createdAt DESC');
    return rows.map(GradingResult.fromMap).toList();
  }

  Future<int> deleteResult(int id) async {
    final db = await database;
    return db.delete('grading_results', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllResults() async {
    final db = await database;
    return db.delete('grading_results');
  }
}
