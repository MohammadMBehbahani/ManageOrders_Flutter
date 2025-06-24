class Discount {
  final String type; // "percentage" or "flat"
  final double value;

  Discount({required this.type, required this.value});

  factory Discount.fromMap(Map<String, dynamic> map) {
    return Discount(
      type: map['type'],
      value: map['value'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'type': type, 'value': value};
  }
}
