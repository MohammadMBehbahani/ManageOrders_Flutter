import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/database/category_database.dart';
import 'package:manageorders/models/category.dart';
import 'package:uuid/uuid.dart';

final categoryProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(CategoryNotifier.new);

class CategoryNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    return await CategoryDatabase.getAllCategories();
  }

  Future<void> addCategory(String name) async {
    final newCategory = Category(id: const Uuid().v4(), name: name);
    await CategoryDatabase.insertCategory(newCategory);
    state = AsyncData([...state.value ?? [], newCategory]);
  }

  Future<void> updateCategory(String id, String newName) async {
    final updated = Category(id: id, name: newName);
    await CategoryDatabase.updateCategory(updated);
    state = AsyncData([
      for (final c in state.value ?? [])
        if (c.id == id) updated else c,
    ]);
  }

  Future<void> deleteCategory(String id) async {
    await CategoryDatabase.deleteCategory(id);
    state = AsyncData((state.value ?? []).where((c) => c.id != id).toList());
  }
}
