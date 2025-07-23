import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/database/drawer_logs_database.dart';
import 'package:manageorders/models/drawerlogs.dart';

final drawerLogsProvider =
    AutoDisposeAsyncNotifierProvider<DrawerLogsNotifier, List<DrawerLog>>(
      DrawerLogsNotifier.new,
    );

class DrawerLogsNotifier extends AutoDisposeAsyncNotifier<List<DrawerLog>> {
  @override
  Future<List<DrawerLog>> build() async {
    return _loadLogs();
  }

  Future<List<DrawerLog>> _loadLogs() async {
    final rawLogs = await DrawerLogsDatabase.getLogs();
    return rawLogs.map((json) => DrawerLog.fromJson(json)).toList();
  }

  Future<void> refreshLogs() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadLogs());
  }

  Future<void> addLog(DrawerLog log) async {
    await DrawerLogsDatabase.insertLog(
      dateTime: log.dateTime,
      reason: log.reason,
    );
    await refreshLogs();
  }

  Future<void> clearOldLogs({int days = 2}) async {
    await DrawerLogsDatabase.clearOldLogs(days: days);
    await refreshLogs();
  }

  Future<void> addLogFromReason(String reason) async {
    final log = DrawerLog(dateTime: DateTime.now(), reason: reason);
    await addLog(log);
  }
}
