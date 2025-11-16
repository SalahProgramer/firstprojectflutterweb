class ItemsViewedModel {
  int? id;
  String? createdAt;

  ItemsViewedModel({
    required this.id,
    required this.createdAt,
  });

  static List<ItemsViewedModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ItemsViewedModel.fromJson(json)).toList();
  }

  factory ItemsViewedModel.fromJson(Map<String, dynamic> json) {
    return ItemsViewedModel(
        id: json['id'] ?? 0, createdAt: json['created_at'] ?? "");
  }

  Map<String, dynamic> toJsonItemViewed() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    return data;
  }

  @override
  String toString() {
    return '''
  Product(
    id: $id,
    created_at: $createdAt
  )
  ''';
  }
}
