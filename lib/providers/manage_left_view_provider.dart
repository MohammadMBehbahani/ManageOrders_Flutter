import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/database/manage_left_view_database.dart';
import 'package:manageorders/models/manageleftview.dart';

class ManageLeftViewNotifier extends StateNotifier<AsyncValue<ManageLeftView?>> {
  ManageLeftViewNotifier() : super(const AsyncValue.loading()) {
    _loadView();
  }

  Future<void> _loadView() async {
    try {
      final views = await ManageLeftViewDatabase.getAllViews();
      // Get the first view only, since only one exists
      state = AsyncValue.data(views.isNotEmpty ? views.first : null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addOrUpdateView(ManageLeftView view) async {
    try {
      await ManageLeftViewDatabase.insertView(view);
      await _loadView();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteView(String id) async {
    try {
      await ManageLeftViewDatabase.deleteView(id);
      await _loadView();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ManageLeftView?> getViewById(String id) async {
    return await ManageLeftViewDatabase.getViewById(id);
  }
}
final manageLeftViewProvider =
    StateNotifierProvider<ManageLeftViewNotifier, AsyncValue<ManageLeftView?>>(
  (ref) => ManageLeftViewNotifier(),
);
