class PendingOrder {
  final int id;
  final String totalPrice;

  PendingOrder({required this.id, required this.totalPrice});

  factory PendingOrder.fromJson(Map<String, dynamic> json) {
    return PendingOrder(
      id: json['id'] ?? 0,
      totalPrice: json['total_price']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'total_price': totalPrice};
  }

  @override
  String toString() {
    return 'PendingOrder(id: $id, totalPrice: $totalPrice)';
  }
}
