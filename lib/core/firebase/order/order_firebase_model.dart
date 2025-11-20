class OrderFirebaseModel {
  final String id;
  final String orderId;
  final String userId;
  final String numberOfProducts;
  final String sum;
  final String trackingNumber;
  final String createdAt;

  OrderFirebaseModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.trackingNumber,
    required this.sum,
    required this.numberOfProducts,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'tracking_number': trackingNumber,
      'sum': sum,
      'number_of_products': numberOfProducts,
      'created_at': createdAt,
    };
  }

  factory OrderFirebaseModel.fromMap(Map<String, dynamic>? map) {
    return OrderFirebaseModel(
      id: map?['id'] ?? '',
      orderId: map?['order_id'] ?? '',
      userId: map?['user_id'] ?? '',
      trackingNumber: map?['tracking_number'] ?? "",
      numberOfProducts: map?['number_of_products'] ?? "",
      sum: map?['sum'] ?? "",
      createdAt: map?['created_at'] ?? "",
    );
  }
}
