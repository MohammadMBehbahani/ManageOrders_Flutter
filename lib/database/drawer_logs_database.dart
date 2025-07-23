import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DrawerLogsDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'drawer_logs.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE drawer_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dateTime TEXT NOT NULL,
            reason TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Insert a new drawer log entry
  static Future<void> insertLog({
    required DateTime dateTime,
    required String reason,
  }) async {
    final db = await database;
    await db.insert('drawer_logs', {
      'dateTime': dateTime.toIso8601String(),
      'reason': reason,
    });
  }

  /// Fetch all drawer logs ordered by newest first
  static Future<List<Map<String, dynamic>>> getLogs() async {
    final db = await database;
    return await db.query('drawer_logs', orderBy: 'dateTime DESC');
  }

  /// Delete logs older than [days] days (default 2 days)
  static Future<void> clearOldLogs({int days = 2}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    await db.delete(
      'drawer_logs',
      where: 'dateTime < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }
}
//await DrawerLogsDatabase.clearOldLogs();