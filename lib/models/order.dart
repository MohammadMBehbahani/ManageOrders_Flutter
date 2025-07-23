import 'discount.dart';
import 'order_item.dart';

class Order {
  final String id;
  final List<OrderItem> items;
  final Discount? discount;
  final double finalTotal;
  final String paymentMethod; // "cash" or "card"
  final DateTime createdAt;
  final String? status;

  Order({
    required this.id,
    this.items = const [],
    this.discount,
    required this.finalTotal,
    required this.paymentMethod,
    DateTime? createdAt,
    this.status,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      items:
          (map['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromMap(e))
              .toList() ??
          [],
      discount: map['discount'] != null
          ? Discount.fromMap(map['discount'])
          : null,
      finalTotal: map['finalTotal'] ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'cash',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((e) => e.toMap()).toList(),
      'discount': discount?.toMap(),
      'finalTotal': finalTotal,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'status': status
    };
  }
}
