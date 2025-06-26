import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:manageorders/models/product.dart';

class ProductDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    return await _initDB();
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'product.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id TEXT PRIMARY KEY,
            categoryId TEXT,
            name TEXT,
            description TEXT,
            basePrice REAL,
            availableSubProducts TEXT,
            availableToppings TEXT,
            availableExtras TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  static Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  static Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Product>> getProductsByCategoryId(
    String categoryId,
  ) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return maps.map((e) => Product.fromMap(e)).toList();
  }
}
