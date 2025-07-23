class DrawerLog {
  final int? id;
  final DateTime dateTime;
  final String reason;

  DrawerLog({
    this.id,
    required this.dateTime,
    required this.reason,
  });

  factory DrawerLog.fromJson(Map<String, dynamic> json) {
    return DrawerLog(
      id: json['id'] as int?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      reason: json['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'dateTime': dateTime.toIso8601String(),
      'reason': reason,
    };
  }
}
