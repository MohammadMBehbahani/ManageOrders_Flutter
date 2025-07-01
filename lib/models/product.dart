import 'dart:convert';
import 'package:manageorders/models/topping.dart';

import 'extra.dart';
import 'sub_product_option.dart';

class Product {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double basePrice;
  final List<SubProductOption> availableSubProducts;
  final List<Topping> availableToppings;
  final List<Extra> availableExtras;
  final int? priority; // nullable
  final int? color;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.basePrice,
    List<SubProductOption>? availableSubProducts,
    List<Topping>? availableToppings,
    List<Extra>? availableExtras,
    this.color,
    this.priority,
  }) : availableSubProducts = availableSubProducts ?? [],
       availableToppings = availableToppings ?? [],
       availableExtras = availableExtras ?? [];

  Product copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    double? basePrice,
    List<SubProductOption>? availableSubProducts,
    List<Topping>? availableToppings,
    List<Extra>? availableExtras,
    int? priority,
    int? color,
  }) {
    return Product(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      availableSubProducts: availableSubProducts ?? this.availableSubProducts,
      availableToppings: availableToppings ?? this.availableToppings,
      availableExtras: availableExtras ?? this.availableExtras,
      color: color ?? this.color,
      priority: priority ?? this.priority,
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      categoryId: map['categoryId'],
      name: map['name'],
      description: map['description'],
      basePrice: (map['basePrice'] ?? 0).toDouble(),
      availableSubProducts: map['availableSubProducts'] != null
          ? (jsonDecode(map['availableSubProducts']) as List<dynamic>)
                .map((e) => SubProductOption.fromMap(e))
                .toList()
          : [],
      availableToppings: map['availableToppings'] != null
          ? (jsonDecode(map['availableToppings']) as List<dynamic>)
                .map((e) => Topping.fromMap(e))
                .toList()
          : [],
      availableExtras: map['availableExtras'] != null
          ? (jsonDecode(map['availableExtras']) as List<dynamic>)
                .map((e) => Extra.fromMap(e))
                .toList()
          : [],
      priority: map['priority'],
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'availableSubProducts': jsonEncode(
        availableSubProducts.map((e) => e.toMap()).toList(),
      ),
      'availableToppings': jsonEncode(
        availableToppings.map((e) => e.toMap()).toList(),
      ),
      'availableExtras': jsonEncode(
        availableExtras.map((e) => e.toMap()).toList(),
      ),
      'priority': priority,
      'color': color,
    };
  }
}
