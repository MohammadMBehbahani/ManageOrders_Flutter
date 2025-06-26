class Topping {
  final String id;
  final String name;

  Topping({
    required this.id,
    required this.name,
  });

  factory Topping.fromMap(Map<String, dynamic> map) {
    return Topping(
      id: map['id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
