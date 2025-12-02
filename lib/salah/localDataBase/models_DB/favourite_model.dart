class FavouriteModel {
  String? image;
  String? title;

  String? newPrice;
  String? oldPrice;
  int? productId;
  int variantId;
  String? tags;

  FavouriteModel(
      {this.image,
      this.title,
      this.newPrice,
      required this.variantId,
      this.oldPrice,
      this.productId,
      this.tags});

  static List<FavouriteModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FavouriteModel.fromJson(json)).toList();
  }

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      image: json['image'] ?? "",
      variantId: json['variantId'] ?? 0,
      title: json['title'] ?? "",
      newPrice: json['new_price'] ?? "",
      oldPrice: json['old_price'] ?? "",
      productId: json['product_id'] ?? "",
      tags: json['tags'] ?? "",
    );
  }

  Map<String, dynamic> toJsonCart() {
    final data = <String, dynamic>{};
    data['product_id'] = productId;
    data['title'] = title;
    data['image'] = image;
    data['price'] = newPrice;
    data['tags'] = tags;
    data['variantId'] = variantId;

    return data;
  }
}
