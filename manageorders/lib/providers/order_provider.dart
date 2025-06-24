import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/database/order_database.dart';
import 'package:manageorders/models/discount.dart';
import 'package:manageorders/models/order.dart';
import 'package:manageorders/models/order_item.dart';
import 'package:uuid/uuid.dart';

final orderProvider =
    NotifierProvider<OrderNotifier, List<OrderItem>>(OrderNotifier.new);

class OrderNotifier extends Notifier<List<OrderItem>> {
  @override
  List<OrderItem> build() => [];

  void addItem(OrderItem item) {
    state = [...state, item];
  }

  void removeItem(int index) {
    final newList = [...state]..removeAt(index);
    state = newList;
  }

  void updateItems(List<OrderItem> items) {
    state = items;
  }

  void clearOrder() {
    state = [];
  }

  /// Updated to accept payment method
  Order getDraftOrder({
    Discount? discount,
    required String paymentMethod,
  }) {
    final total = _calculateTotal(state, discount);
    return Order(
      id: const Uuid().v4(),
      items: state,
      discount: discount,
      finalTotal: total,
      paymentMethod: paymentMethod,
    );
  }

  /// Updated to accept payment method
  Future<Order> submitOrder({
    Discount? discount,
    required String paymentMethod,
  }) async {
    final newOrder = getDraftOrder(
      discount: discount,
      paymentMethod: paymentMethod,
    );
    // ✅ Save order to SQLite
    await OrderDatabase.insertOrder(newOrder);

    clearOrder();
    return newOrder;
  }

  double _calculateTotal(List<OrderItem> items, Discount? discount) {
    double subtotal = items.fold(0.0, (sum, item) {
      final toppingTotal = (item.toppings ?? [])
          .fold(0.0, (prev, t) => prev + t.price);
      final extraTotal = (item.extras ?? [])
          .fold(0.0, (prev, e) => prev + e.amount);
      return sum + (item.unitPrice + toppingTotal + extraTotal) * item.quantity;
    });

    if (discount != null) {
      if (discount.type == 'percentage') {
        return subtotal * (1 - discount.value / 100);
      } else if (discount.type == 'flat') {
        return (subtotal - discount.value).clamp(0, double.infinity);
      }
    }

    return subtotal;
  }
}
