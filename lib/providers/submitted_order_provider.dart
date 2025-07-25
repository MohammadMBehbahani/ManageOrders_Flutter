import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/database/order_database.dart';
import 'package:manageorders/models/order.dart';

final submittedOrdersProvider =
    AutoDisposeAsyncNotifierProvider<SubmittedOrdersNotifier, List<Order>>(
      SubmittedOrdersNotifier.new,
    );

class SubmittedOrdersNotifier extends AutoDisposeAsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    return await OrderDatabase.getAllOrders();
  }

  Future<void> refreshOrders() async {
    state = const AsyncLoading();
    state = AsyncData(await OrderDatabase.getAllOrders());
  }

  Future<void> deleteOrder(String id) async {
    await OrderDatabase.deleteOrder(id);
    await refreshOrders();
  }

  Future<void> refundOrder(String id) async {
    await OrderDatabase.updateOrderStatus(id, 'refunded');
    await refreshOrders();
  }

  Future<void> clearAll() async {
    await OrderDatabase.clear();
    await refreshOrders();
  }
}
