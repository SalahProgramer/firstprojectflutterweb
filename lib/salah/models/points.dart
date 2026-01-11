class Points {
  final int userId;
  final String phone;
  final int points;
  final int updatedPoints;
  final List<HistoryItem> history;

  Points({
    this.userId = 0,
    this.phone = '',
    this.points = 0,
    this.updatedPoints = 0,
    this.history = const [],
  });

  factory Points.fromJson(Map<String, dynamic> json) {
    return Points(
      userId: json['user_id'] is int ? json['user_id'] : 0,
      phone: json['phone'] as String? ?? '',
      points: json['points'] is int ? json['points'] : 0,
      updatedPoints: (json['updated_points'] as int?) ?? 0,
      history:
          (json['history'] as List<dynamic>?)
              ?.map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'phone': phone,
      'points': points,
      'history': history.map((e) => e.toJson()).toList(),
    };
  }
}

class HistoryItem {
  final String reason;
  final int value;
  final int enumPoint;
  final DateTime date;

  HistoryItem({
    this.reason = '',
    this.enumPoint = 1,
    this.value = 0,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      reason: json['reason'] as String? ?? '',
      value: json['value'] is int ? json['value'] : 0,
      enumPoint: json['enum'] is int ? json['enum'] : 1,
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'reason': reason, 'value': value, 'date': date.toIso8601String()};
  }
}
