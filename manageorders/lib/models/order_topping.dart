class OrderTopping {
  final String toppingId; // refer to Topping.id
  final String name;
  final double price;

  OrderTopping({
    required this.toppingId,
    required this.name,
    required this.price,
  });

  factory OrderTopping.fromMap(Map<String, dynamic> map) {
    return OrderTopping(
      toppingId: map['toppingId'],
      name: map['name'],
      price: map['price'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toppingId': toppingId,
      'name': name,
      'price': price,
    };
  }
}
