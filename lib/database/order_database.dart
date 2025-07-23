import 'dart:convert';
import 'package:manageorders/models/order.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OrderDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    return await _initDB();
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'order.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE orders (
            id TEXT PRIMARY KEY,
            items TEXT,
            discount TEXT,
            finalTotal REAL,
            paymentMethod TEXT,
            createdAt TEXT,
            status TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add new column createdAt to existing table
          await db.execute('ALTER TABLE orders ADD COLUMN createdAt TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE orders ADD COLUMN paymentMethod TEXT');
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE orders ADD COLUMN status TEXT');
        }
        // Handle future upgrades here if needed
      },
    );
  }

  static Future<void> insertOrder(Order order) async {
    try {
      final db = await database;
      await db.insert('orders', {
        'id': order.id,
        'items': jsonEncode(order.items.map((e) => e.toMap()).toList()),
        'discount': jsonEncode(order.discount?.toMap()),
        'finalTotal': order.finalTotal,
        'paymentMethod': order.paymentMethod,
        'createdAt': order.createdAt.toIso8601String(),
        'status': order.status
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      //print('Error submitting order: $e');
      rethrow;
    }
  }

  static Future<List<Order>> getAllOrders() async {
    final db = await database;
    final result = await db.query('orders');
    return result
        .map(
          (e) => Order.fromMap({
            ...e,
            'items': jsonDecode(e['items'] as String),
            'discount': e['discount'] != null
                ? jsonDecode(e['discount'] as String)
                : null,
          }),
        )
        .toList();
  }

  static Future<void> deleteOrder(String id) async {
    final db = await database;
    await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clear() async {
    final db = await database;
    await db.delete('orders');
  }

  static Future<void> updateOrderStatus(String id, String status) async {
    final db = await database;
    await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
