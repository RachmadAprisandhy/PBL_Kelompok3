import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/grading_result.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _database;
  Future<Database>? _databaseFuture;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Mencegah beberapa bagian aplikasi membuka database yang sama bersamaan.
    _databaseFuture ??= _openDatabase();

    try {
      return await _databaseFuture!;
    } catch (_) {
      _databaseFuture = null;
      rethrow;
    }
  }

  Future<Database> _openDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, 'bananagrade.db');
    final db = await openDatabase(
      dbPath,
      version: 2,
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
        await db.execute('''
          CREATE TABLE app_settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migrasi database versi 1 ke versi 2 untuk menyimpan pengaturan aplikasi.
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE app_settings (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        }
      },
    );
    _database = db;
    return db;
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

  /// Mengambil status apakah tutorial halaman utama sudah pernah diselesaikan.
  /// Nilai default false berarti tutorial belum pernah ditampilkan/diselesaikan.
  Future<bool> hasSeenHomeTutorial() async {
    final db = await database;
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['has_seen_home_tutorial'],
      limit: 1,
    );

    if (rows.isEmpty) return false;
    return rows.first['value'] == 'true';
  }

  /// Menyimpan bahwa tutorial halaman utama sudah diselesaikan atau dilewati.
  Future<void> markHomeTutorialAsSeen() async {
    final db = await database;
    await db.insert(
      'app_settings',
      {
        'key': 'has_seen_home_tutorial',
        'value': 'true',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
