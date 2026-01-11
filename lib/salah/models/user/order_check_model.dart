class OrderCheckModel {
  final bool success;
  final int? orderId;
  final String? message;

  OrderCheckModel({required this.success, this.orderId, this.message});

  factory OrderCheckModel.fromJson(Map<String, dynamic> json) {
    return OrderCheckModel(
      success: json['success'] ?? false,
      orderId: json['order_id'] ?? 1,
      message: json['message'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (orderId != null) 'order_id': orderId,
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return 'OrderCheckModel(success: $success, orderId: $orderId, message: $message)';
  }
}
