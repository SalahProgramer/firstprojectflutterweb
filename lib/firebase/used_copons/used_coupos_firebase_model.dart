class UsedCoponsFirebaseModel {
  final String id;
  final String orderId;
  final String userId;
  final String copon;

  UsedCoponsFirebaseModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.copon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'copon': copon,
    };
  }

  factory UsedCoponsFirebaseModel.fromMap(Map<String, dynamic>? map) {
    return UsedCoponsFirebaseModel(
      id: map?['id'] ?? '',
      orderId: map?['order_id'] ?? '',
      userId: map?['user_id'] ?? '',
      copon: map?['copon'] ?? "",
    );
  }
}
