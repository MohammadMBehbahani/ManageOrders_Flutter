import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/database/topping_database.dart';
import 'package:manageorders/models/topping.dart';
import 'package:uuid/uuid.dart';

final toppingProvider = AsyncNotifierProvider<ToppingNotifier, List<Topping>>(
  ToppingNotifier.new,
);

class ToppingNotifier extends AsyncNotifier<List<Topping>> {
  @override
  Future<List<Topping>> build() async {
    return await ToppingDatabase.getToppings();
  }

  Future<void> addTopping(String name) async {
    final topping = Topping(id: const Uuid().v4(), name: name);
    await ToppingDatabase.insertTopping(topping);
    state = AsyncData([...state.value ?? [], topping]);
  }

  Future<void> updateTopping(String id, String newName) async {
    final updated = Topping(id: id, name: newName);
    await ToppingDatabase.updateTopping(updated);
    state = AsyncData([
      for (final t in state.value ?? [])
        if (t.id == updated.id) updated else t,
    ]);
  }

  Future<void> deleteTopping(String id) async {
    await ToppingDatabase.deleteTopping(id);
    state = AsyncData((state.value ?? []).where((t) => t.id != id).toList());
  }
}
