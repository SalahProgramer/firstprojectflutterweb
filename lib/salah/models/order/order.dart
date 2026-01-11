class SpecificOrder {
  SpecificOrder({
    required this.id,
    required this.image,
    required this.shopId,
    required this.sku,
    required this.name,
    required this.price,
    required this.quantity,
    required this.size,
    required this.nickname,
    required this.vendorSku,
    required this.variantIndex,
    required this.placeInWarehouse,
    // required this.cancelled,
    // required this.pushToken,
  });
  late String id;
  late String image;
  late String shopId;
  late String sku;
  late String vendorSku;
  late String name;
  late String price;
  late String size;
  late String nickname;
  late String placeInWarehouse;
  late int quantity;
  late int variantIndex;

  late String numberOfProducts;
  late String orderId;
  late String sum;
  late String trackingNumber;
  late String userId;
  // late  bool cancelled;
  // late  String pushToken;

  SpecificOrder.fromJson(Map<String, dynamic> json) {
    id = json['product_id']?.toString() ?? '';
    image = json['image'] ?? '';
    shopId = json['shop_id']?.toString() ?? '';

    if (json['data'] != null &&
        json['data'] is List &&
        json['data'].isNotEmpty) {
      final data = json['data'][0];
      sku = data['sku']?.toString() ?? '';
      vendorSku = data['vendor_sku']?.toString() ?? '';
      name = data['name'] ?? '';
      size = data['size'] ?? '';
      nickname = data['nickname'] ?? '';
      placeInWarehouse = data['place_in_warehouse'] ?? '';
      price = "${data['price'].toString().trim()} ₪ ";
      quantity = data['quantity'] ?? 0;
      variantIndex = data['variant_index'] ?? 0;
    } else {
      sku = json['sku']?.toString() ?? '';
      vendorSku = json['vendor_sku']?.toString() ?? '';
      name = json['name'] ?? '';
      size = json['size'] ?? '';
      nickname = json['nickname'] ?? '';
      placeInWarehouse = json['place_in_warehouse'] ?? '';
      price = "${json['price'].toString().trim()} ₪ ";
      quantity = json['quantity'] ?? 0;
      variantIndex = json['variant_index'] ?? 0;
    }
  }
  static List<SpecificOrder> fromJsonListOrderItems(List<dynamic> jsonList) {
    return jsonList.map((json) => SpecificOrder.fromJson(json)).toList();
  }

  @override
  String toString() {
    return ""
        "SpecificOrder(id: $id, image: $image, shopId: $shopId, sku: $sku, vendorSku: $vendorSku, name: $name";
  }
}
