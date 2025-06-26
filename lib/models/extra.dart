class Extra {
  final String id;
  final String title;

  Extra({required this.id, required this.title});

  factory Extra.fromMap(Map<String, dynamic> map) {
    return Extra(
      id: map['id'],
      title: map['title']
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title };
  }
}
