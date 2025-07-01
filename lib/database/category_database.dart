import 'package:manageorders/models/category.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CategoryDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    return await _initDB();
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'category.db');

    return await openDatabase(
      path,
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE categories ADD COLUMN priority INTEGER',
          );
          await db.execute('ALTER TABLE categories ADD COLUMN color TEXT');
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            priority INTEGER,
            color TEXT
          )
        ''');
      },
    );
  }

  static Future<List<Category>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  static Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateCategory(Category category) async {
    final db = await database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
