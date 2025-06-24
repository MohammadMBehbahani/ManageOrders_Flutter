import 'package:manageorders/models/extra.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ExtraDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'manageorders.db');

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE extras(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL
      )
      ''');
    });
  }

  static Future<List<Extra>> getExtras() async {
    final db = await database;
    final maps = await db.query('extras');
    return maps.map((map) => Extra.fromMap(map)).toList();
  }

  static Future<void> insertExtra(Extra extra) async {
    final db = await database;
    await db.insert('extras', extra.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateExtra(Extra extra) async {
    final db = await database;
    await db.update('extras', extra.toMap(), where: 'id = ?', whereArgs: [extra.id]);
  }

  static Future<void> deleteExtra(String id) async {
    final db = await database;
    await db.delete('extras', where: 'id = ?', whereArgs: [id]);
  }
}
