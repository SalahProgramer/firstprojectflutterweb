class CartModel {
  String? id;
  String? image;
  String? title;
  String? newPrice;
  String? oldPrice;
  int? productId;
  String? favourite;
  dynamic shopId;
  String? size;
  int? basicQuantity;
  int? quantity;
  String? employee;
  String? sku;
  String? hasOffer;
  String? vendorSku;
  String? placeInHouse;
  String? nickname;
  int? indexVariants;
  int variantId;
  String? totalPrice;
  String? tags;

  CartModel({
    this.id,
    required this.variantId,
    this.image,
    this.hasOffer,
    this.title,
    this.newPrice,
    this.oldPrice,
    this.productId,
    this.favourite,
    this.shopId,
    this.size,
    this.basicQuantity,
    this.quantity,
    this.employee,
    this.sku,
    this.vendorSku,

    this.placeInHouse,
    this.nickname,
    this.indexVariants,
    this.tags,
    this.totalPrice,
  });

  static List<CartModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CartModel.fromJson(json)).toList();
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] ?? "",
      image: json['image'] ?? "",
      title: json['title'] ?? "",
      newPrice: json['new_price'] ?? "",
      oldPrice: json['old_price'] ?? "",
      productId: json['product_id'] ?? "",
      favourite: json["favourite"] ?? "",
      shopId: (json["shop_id"] != "null") ? json["shop_id"].toString() : "null",
      size: json['size'] ?? "",
      hasOffer: json['has_offer'] ?? "false",
      basicQuantity: json['basic_quantity'] ?? "",
      quantity: json['quantity'] ?? "",
      employee: json['employee'] ?? "",
      sku: json['sku'] ?? "",
      vendorSku: json['vendor_sku'] ?? "",
      tags: json['tags'] ?? "",
      placeInHouse: json['place_in_warehouse'] ?? "",
      nickname: json['nickname'] ?? "",
      indexVariants: json['indexVariants'] ?? "",
      variantId: json['variantId'] ?? "",
      totalPrice: json['total_price'] ?? "",
    );
  }

  Map<String, dynamic> toJsonCart() {
    final data = <String, dynamic>{};

    data['id'] = productId;
    data['size'] = size;
    data['quantity'] = quantity;
    data['price'] = parsePriceToDouble(newPrice.toString());
    data['variantId'] = variantId;
    // data['price']= 2;
    return data;
  }

  double parsePriceToDouble(String? priceString) {
    if (priceString == null || priceString.isEmpty) return 0.0;

    // Remove ₪ symbol and any whitespace
    String cleanPrice = priceString.replaceAll("₪", "").trim();

    // Try to parse as double
    double? parsedPrice = double.tryParse(cleanPrice);

    // Return 0.0 if parsing fails, otherwise return the parsed value
    return parsedPrice ?? 0.0;
  }

  @override
  String toString() {
    return '''
  Product(
    id: $id,
    image: $image,
    title: $title,
    newPrice: $newPrice,
    has_offer: $hasOffer,
    oldPrice: $oldPrice,
    productId: $productId,
    favourite: $favourite,
    shopId: $shopId,
    size: $size,
    basicQuantity: $basicQuantity,
    quantity: $quantity,
    employee: $employee,
    sku: $sku,
    vendorSku: $vendorSku,
    placeInHouse: $placeInHouse,
    nickname: $nickname,
    indexVariants: $indexVariants,
    totalPrice: $totalPrice,
    variantId: $variantId,
    tags: $tags
  )
  ''';
  }
}
