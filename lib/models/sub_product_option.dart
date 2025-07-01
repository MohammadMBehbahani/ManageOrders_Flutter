class SubProductOption {
  final String id;
  final String name;
  final double additionalPrice;
  final int? priority;
  final int? color;

  SubProductOption({
    required this.id,
    required this.name,
    required this.additionalPrice,
    this.color,
    this.priority,
  });

  factory SubProductOption.fromMap(Map<String, dynamic> map) {
    return SubProductOption(
      id: map['id'],
      name: map['name'],
      additionalPrice: map['additionalPrice'] ?? 0.0,
      priority: map['priority'],
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'additionalPrice': additionalPrice,
      'priority': priority,
      'color': color,
    };
  }
}
