class Category {
  final String id;
  final String name;
  final int? priority; // Optional
  final int? color;

  Category({
    required this.id, 
    required this.name, 
    this.priority, 
    this.color
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'], 
      name: map['name'],
      priority: map['priority'], // Nullable
      color: map['color'] as int?, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, 
      'name': name,
      'priority': priority,
      'color': color,
    };
  }
}
