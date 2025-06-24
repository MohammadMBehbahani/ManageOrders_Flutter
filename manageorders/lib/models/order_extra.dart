class OrderExtra {
  final String title;
  final double amount;

  OrderExtra({required this.title, required this.amount});

  factory OrderExtra.fromMap(Map<String, dynamic> map) {
    return OrderExtra(
      title: map['title'],
      amount: map['amount'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'amount': amount};
  }
}
