import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:manageorders/models/shop_details.dart';

class ShopDetailsDatabase {
  static Database? _db;

  static Future<Database> _getDb() async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'shop_details.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE shop_details(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            shopName TEXT,
            address1 TEXT,
            address2 TEXT,
            address3 TEXT,
            address4 TEXT,
            postcode TEXT,
            phone TEXT
          )
        ''');
      },
    );

    return _db!;
  }

  static Future<void> save(ShopDetails details) async {
    final db = await _getDb();
    await db.delete('shop_details');
    await db.insert('shop_details', details.toMap());
  }

  static Future<ShopDetails?> load() async {
    final db = await _getDb();
    final maps = await db.query('shop_details', limit: 1);
    if (maps.isNotEmpty) {
      return ShopDetails.fromMap(maps.first);
    }
    return null;
  }
}
