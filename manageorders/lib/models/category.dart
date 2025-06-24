class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
