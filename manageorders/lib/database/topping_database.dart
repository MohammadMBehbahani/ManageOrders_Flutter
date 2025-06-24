import 'package:manageorders/models/topping.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ToppingDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'topping.db');

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE toppings(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
      ''');
    });
  }

  static Future<List<Topping>> getToppings() async {
    final db = await database;
    final maps = await db.query('toppings');
    return maps.map((map) => Topping.fromMap(map)).toList();
  }

  static Future<void> insertTopping(Topping topping) async {
    final db = await database;
    await db.insert(
      'toppings',
      topping.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateTopping(Topping topping) async {
    final db = await database;
    await db.update(
      'toppings',
      topping.toMap(),
      where: 'id = ?',
      whereArgs: [topping.id],
    );
  }

  static Future<void> deleteTopping(String id) async {
    final db = await database;
    await db.delete('toppings', where: 'id = ?', whereArgs: [id]);
  }
}
