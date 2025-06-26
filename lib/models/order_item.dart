import 'package:manageorders/models/order_extra.dart';

import 'order_topping.dart';

class OrderItem {
  final String productId;
  final String subProductName;
  final List<OrderExtra>? extras;
  final List<OrderTopping>? toppings; 
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.subProductName,
    this.extras,
    this.toppings,
    required this.quantity,
    required this.unitPrice
  }): totalPrice = unitPrice * quantity;

   OrderItem copyWith({
    String? productId,
    String? subProductName,
    List<OrderExtra>? extras,
    List<OrderTopping>? toppings,
    int? quantity,
    double? unitPrice,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      subProductName: subProductName ?? this.subProductName,
      extras: extras ?? this.extras,
      toppings: toppings ?? this.toppings,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      subProductName: map['subProductName'],
      extras: (map['extras'] as List<dynamic>?)
              ?.map((e) => OrderExtra.fromMap(e))
              .toList(),
      toppings: (map['toppings'] as List<dynamic>?)
              ?.map((e) => OrderTopping.fromMap(e))
              .toList(),
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'subProductName': subProductName,
      'extras': extras?.map((e) => e.toMap()).toList(),
      'toppings': toppings?.map((e) => e.toMap()).toList(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}
