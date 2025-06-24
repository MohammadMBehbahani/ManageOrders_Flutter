import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/database/Extra_database.dart';
import 'package:manageorders/models/extra.dart';
import 'package:uuid/uuid.dart';

final extraProvider =
    AsyncNotifierProvider<ExtraNotifier, List<Extra>>(ExtraNotifier.new);

class ExtraNotifier extends AsyncNotifier<List<Extra>> {
  @override
  Future<List<Extra>> build() async {
    return await ExtraDatabase.getExtras();
  }

  Future<void> addExtra(String title) async {
    final newExtra = Extra(id: const Uuid().v4(), title: title);
    await ExtraDatabase.insertExtra(newExtra);
    state = AsyncData([...state.value ?? [], newExtra]);
  }

  Future<void> updateExtra(String id, String newtitle) async {
    final updated = Extra(id: id, title: newtitle);
    await ExtraDatabase.updateExtra(updated);
    state = AsyncData([
      for (final c in state.value ?? [])
        if (c.id == id) updated else c,
    ]);
  }

  Future<void> deleteExtra(String id) async {
    await ExtraDatabase.deleteExtra(id);
    state = AsyncData((state.value ?? []).where((c) => c.id != id).toList());
  }
}
