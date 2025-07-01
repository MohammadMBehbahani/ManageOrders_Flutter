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
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE categories ADD COLUMN priority INTEGER',
          );
          await db.execute('ALTER TABLE categories ADD COLUMN color TEXT');
        }
        if (oldVersion < 3) {
          // Step 1: Rename old table
          await db.execute('ALTER TABLE categories RENAME TO categories_old');

          // Step 2: Create new table with correct schema
          await _createDB(db, newVersion);

          // Step 3: Copy data into new table (convert color if needed)
          final oldData = await db.query('categories_old');

          for (final row in oldData) {
            await db.insert('categories', {
              'id': row['id'],
              'name': row['name'],
              'priority': row['priority'],
              'color': row['color']!= null 
                  ?row['color'] is int
                  ? row['color']
                  : row['color'] != null
                  ? int.tryParse(row['color'].toString()) ?? 0
                  : null
                  : null,
            });
          }
          // Step 4: Drop old table
          await db.execute('DROP TABLE categories_old');
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

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      priority INTEGER,
      color INTEGER
    )
  ''');
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
