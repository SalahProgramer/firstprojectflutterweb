class AvailableModel {
  int? id;
  String? availability;
  String? message;
  double? price;
  int? availableQuantity;

  AvailableModel({
    this.availability,
    required this.id,
    this.message,
    this.price,
    this.availableQuantity,
  });

  static List<AvailableModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AvailableModel.fromJson(json)).toList();
  }

  factory AvailableModel.fromJson(Map<String, dynamic> json) {
    return AvailableModel(
      id: json['id'] ?? 0,
      availability: json['availability']?.toString() ?? "true",
      message: json['message'],
      price: json['price']?.toDouble(),
      availableQuantity: json['available quantity'],
    );
  }
}
