import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/database/order_database.dart';
import 'package:manageorders/models/discount.dart';
import 'package:manageorders/models/order.dart';
import 'package:manageorders/models/order_item.dart';
import 'package:uuid/uuid.dart';

final orderProvider = NotifierProvider<OrderNotifier, List<OrderItem>>(
  OrderNotifier.new,
);

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

  void increaseQuantity(int index) {
    final newList = [...state];
    final item = newList[index];
    newList[index] = item.copyWith(quantity: item.quantity + 1);
    state = newList;
  }

  void decreaseQuantity(int index) {
    final newList = [...state];
    final item = newList[index];
    if (item.quantity <= 1) {
      return;
    }
    newList[index] = item.copyWith(quantity: item.quantity - 1);
    state = newList;
  }

  void updateItems(List<OrderItem> items) {
    state = items;
  }

  void clearOrder() {
    state = [];
  }

  void applyItemDiscount(int index, Discount discount) {
    final newList = [...state];
    final item = newList[index];

    double discountValue = 0.0;

    if (discount.type == "percentage") {
      discountValue = item.unitPrice * (discount.value / 100);
    } else if (discount.type == "flat") {
      discountValue = discount.value;
    }

    newList[index] = item.copyWith(itemDiscount: discountValue);
    state = newList;
  }

  void removeItemDiscount(int index) {
    final newList = [...state];
    final item = newList[index];

    // reset itemDiscount back to 0
    newList[index] = item.copyWith(itemDiscount: 0.0);
    state = newList;
  }

  /// Updated to accept payment method
  Order getDraftOrder({Discount? discount, required String paymentMethod}) {
    final total = calculateTotal(state, discount);
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

  double calculateTotal(List<OrderItem> items, Discount? discount) {
    double subtotal = items.fold(0.0, (sum, item) {
      final toppingTotal = (item.toppings ?? []).fold(
        0.0,
        (prev, t) => prev + t.price,
      );
      final extraTotal = (item.extras ?? []).fold(
        0.0,
        (prev, e) => prev + e.amount,
      );
      // apply per-item discount (absolute)
      final itemBasePrice = item.unitPrice + toppingTotal + extraTotal;
      final itemTotal =
          (itemBasePrice - item.itemDiscount).clamp(0, double.infinity) *
          item.quantity;

      return sum + itemTotal;
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
