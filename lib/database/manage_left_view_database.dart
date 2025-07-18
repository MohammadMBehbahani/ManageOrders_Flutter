import 'package:manageorders/models/manageleftview.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ManageLeftViewDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    return await _initDB();
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'manage_left_view.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createDB(db);
      },
    );
  }

  static Future<void> _createDB(Database db) async {
    await db.execute('''
      CREATE TABLE manage_left_views (
        id TEXT PRIMARY KEY,
        fontsizecategory INTEGER,
        fontsizeproduct INTEGER,
        boxwidthproduct INTEGER,
        boxheightcategory INTEGER,
        boxwidthcategory INTEGER,
        boxheightproduct INTEGER
      )
    ''');
  }

  static Future<List<ManageLeftView>> getAllViews() async {
    final db = await database;
    final result = await db.query('manage_left_views');
    return result.map((e) => ManageLeftView.fromMap(e)).toList();
  }

  static Future<void> insertView(ManageLeftView view) async {
    final db = await database;
    await db.insert(
      'manage_left_views',
      view.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateView(ManageLeftView view) async {
    final db = await database;
    await db.update(
      'manage_left_views',
      view.toMap(),
      where: 'id = ?',
      whereArgs: [view.id],
    );
  }

  static Future<void> deleteView(String id) async {
    final db = await database;
    await db.delete(
      'manage_left_views',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<ManageLeftView?> getViewById(String id) async {
    final db = await database;
    final result = await db.query(
      'manage_left_views',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return ManageLeftView.fromMap(result.first);
    }
    return null;
  }
}
