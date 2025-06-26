class SubProductOption {
  final String id;
  final String name;
  final double additionalPrice;

  SubProductOption({
    required this.id,
    required this.name,
    required this.additionalPrice,
  });

  factory SubProductOption.fromMap(Map<String, dynamic> map) {
    return SubProductOption(
      id: map['id'],
      name: map['name'],
      additionalPrice: map['additionalPrice'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'additionalPrice': additionalPrice};
  }
}
