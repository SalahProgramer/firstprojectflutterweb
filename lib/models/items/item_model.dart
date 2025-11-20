import 'package:fawri_app_refactor/models/items/variants_model.dart';

class Item {
  Item({
    required this.id,
    required this.title,
    this.thumbnail,
    this.vendorImagesLinks,
    this.videoUrl,
    this.description,
    this.mediumVendorImagesLinks,
    this.shopId,
    this.googleCloudImagesLinks,
    this.commentNum,
    this.mainCategoris,
    this.subCategoris,
    this.tags,
    this.commentNumStr,
    this.variants,
    this.status,
    this.vendorSku,
    this.sizeInfo,
    this.adType,
    this.isCouponEligible,
    this.nickname,
    this.sku,
    this.createdAt,
    this.url,
    this.featured,
    this.seen,
    this.oldPrice,
    this.newPrice,
  });

  dynamic oldPrice;
  dynamic newPrice;
  int? id;
  String? title;
  String? thumbnail;
  List<String>? vendorImagesLinks;
  dynamic videoUrl;
  List<String>? description;
  List<String>? mediumVendorImagesLinks;
  dynamic shopId;
  List<String>? googleCloudImagesLinks;
  dynamic commentNum;
  String? mainCategoris;
  String? subCategoris;
  List<String>? tags;
  dynamic commentNumStr;
  List<Variants>? variants;
  dynamic status;
  String? vendorSku;
  dynamic sizeInfo;
  dynamic adType;
  bool? isCouponEligible;
  String? nickname;
  String? sku;
  DateTime? createdAt;
  String? url;
  bool? featured;
  int? seen;

  // Adjusting fromJsonProduct to use `seen` and initialize required fields
  Item.fromJsonProductSpecificId(Map<dynamic, dynamic> json)
      : id = json["id"] ?? "",
        title = json["title"] ?? "",
        thumbnail = json["thumbnail"] ?? "",
        newPrice = (json["price"] != null)
            ? ((json["price"] != 0)
                ? "${(json["price"]).toStringAsFixed(2)} ₪"
                : "0 ₪")
            : "0 ₪",
        oldPrice = (json["price"] != null)
            ? (json["price"] != 0
                ? "${(double.parse(json["price"].toString()) * 2.5).toStringAsFixed(2)} ₪"
                : "0 ₪")
            : "0 ₪",
        vendorImagesLinks = (json['vendor_images_links'] != null)
            ? List.castFrom<dynamic, String>(json['vendor_images_links'])
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final url = entry.value;

                  if (index != 0) {
                    // Return the first image as it is, without modification

                    return url;
                  }

                  if ((url.contains('img.ltwebstatic.com'))) {
                    final extension = url.split('.').last;

                    // Append _thumbnail_400x400 before the extension
                    return url.replaceAll(RegExp(r'(\.[a-zA-Z]+)$'),
                        '_thumbnail_400x400.$extension');
                  }

                  return url; // Return the original URL if it contains 'google'
                })
                .take(5)
                .toList()
            : [""],
        videoUrl = json["video_url"] ?? "",
        description = (json["description"] == [] ||
                json["description"] == {} ||
                json["description"] == "")
            ? []
            : (json["description"] is Map)
                ? ((json["description"] as Map)
                    .entries
                    .map((entry) => "${entry.key} : ${entry.value}")
                    .toList())
                : (json["description"] is String)
                    ? json["description"].split('\n')
                    : (json["description"].toString().contains("[{") == false)
                        ? (List<String>.from(
                            json["description"].map((x) => x as String)))
                        : (json["description"].map<String>((item) {
                            String key = item.keys.first;
                            String value = item[key]!;
                            return "$key: $value";
                          }).toList()),
        mediumVendorImagesLinks = json["medium_vendor_images_links"] == null
            ? []
            : List<String>.from(
                json["medium_vendor_images_links"].map((x) => x as String)),
        shopId = json["shop_id"],
        googleCloudImagesLinks = json["google_cloud_images_links"] == null
            ? []
            : List<String>.from(
                json["google_cloud_images_links"].map((x) => x as String)),
        commentNum = json["comment_num"],
        mainCategoris = json["Main_cat"],
        subCategoris = json["Sub_cat"],
        // categories = json["categories"] == null
        //     ? []
        //     : List<List<String>>.from(json["categories"].map(
        //         (x) => x == null
        //             ? []
        //             : List<String>.from((x as List).map((y) => y as String)),
        //       )),
        tags = (json["tags"] == null || json["tags"] == "")
            ? []
            : List<String>.from(json["tags"].map((x) => x as String)),
        commentNumStr = json["comment_num_str"],
        variants = (json["variants"].isEmpty)
            ? [
                Variants(
                    employee: "",
                    oldPrice: "",
                    newPrice: "",
                    size: "",
                    id: 0,

                    placeInWarehouse: "",
                    quantity: "",
                    nickname: "",
                    season: "")
              ]
            : Variants.fromJsonList(
                json["variants"], json["max_purchase"] ?? 0),
        status = json["status"],
        vendorSku = json["vendor_sku"],
        sizeInfo = json["size_info"],
        adType = json["ad_type"],
        isCouponEligible = json["is_coupon_eligible"],
        nickname = (json["nickname"] == null || json["nickname"] == "")
            ? ""
            : json["nickname"],
        sku = (json["sku"] == null || json["sku"] == "") ? "" : json["sku"],
        createdAt = DateTime.tryParse(json["created_at"] ?? ""),
        url = json["url"] ?? "",
        featured = json["featured"],
        seen = json["seen"] ?? 0;

  // Adjusting fromJsonProduct to use `seen` and initialize required fields
  Item.fromJsonProductBestOrFlash(Map<dynamic, dynamic> json, String? newPrice1,
      String? oldPrice1, String? videoUrl)
      : id = json["id"] ?? "",
        title = json["title"] ?? "",
        thumbnail = json["thumbnail"] ?? "",
        newPrice = newPrice1,
        oldPrice = oldPrice1,
        vendorImagesLinks = (json['vendor_images_links'] != null)
            ? List.castFrom<dynamic, String>(json['vendor_images_links'])
                .asMap()
                .entries
                .map((entry) {
                  final url = entry.value;

                  // Return the first image as it is, without modification
                  return url;
                })
                .take(5)
                .toList()
            : [""],
        videoUrl = videoUrl ?? "",
        description = (json["description"] == [] ||
                json["description"] == {} ||
                json["description"] == "")
            ? []
            : (json["description"] is Map)
                ? ((json["description"] as Map)
                    .entries
                    .map((entry) => "${entry.key} : ${entry.value}")
                    .toList())
                : (json["description"] is String)
                    ? json["description"].split('\n')
                    : (json["description"].toString().contains("[{") == false)
                        ? (List<String>.from(
                            json["description"].map((x) => x as String)))
                        : (json["description"].map<String>((item) {
                            String key = item.keys.first;
                            String value = item[key]!;
                            return "$key: $value";
                          }).toList()),
        mediumVendorImagesLinks = json["medium_vendor_images_links"] == null
            ? []
            : List<String>.from(
                json["medium_vendor_images_links"].map((x) => x as String)),
        shopId = json["shop_id"],
        googleCloudImagesLinks = json["google_cloud_images_links"] == null
            ? []
            : List<String>.from(
                json["google_cloud_images_links"].map((x) => x as String)),
        commentNum = json["comment_num"],
        mainCategoris = json["Main_cat"],
        subCategoris = json["Sub_cat"],
        tags = (json["tags"] == null || json["tags"] == "")
            ? []
            : List<String>.from(json["tags"].map((x) => x as String)),
        commentNumStr = json["comment_num_str"],
        variants = (json["variants"].isEmpty)
            ? [
                Variants(
                    employee: "",
                    oldPrice: "",
                    newPrice: "",
                    size: "",
                    id: 0,

                    placeInWarehouse: "",
                    quantity: "",
                    nickname: "",
                    season: "")
              ]
            : Variants.fromJsonList(
                json["variants"], json["max_purchase"] ?? 0),
        status = json["status"],
        vendorSku = json["vendor_sku"],
        sizeInfo = json["size_info"],
        adType = json["ad_type"],
        isCouponEligible = json["is_coupon_eligible"],
        nickname = (json["nickname"] == null || json["nickname"] == "")
            ? ""
            : json["nickname"],
        sku = (json["sku"] == null || json["sku"] == "") ? "" : json["sku"],
        createdAt = DateTime.tryParse(json["created_at"] ?? ""),
        url = json["url"] ?? "",
        featured = json["featured"],
        seen = json["seen"] ?? 0;

  // Adjusting fromJsonProduct to use `seen` and initialize required fields
  Item.fromJsonProduct(
    Map<dynamic, dynamic> json,
    String? newPrice1,
    String? oldPrice1,
    String? videoUrl,
    List<String> tags1,
  )   : id = json["id"] ?? "",
        title = json["title"] ?? "",
        thumbnail = json["thumbnail"] ?? "",
        newPrice = newPrice1,
        oldPrice = oldPrice1,
        vendorImagesLinks = (json['vendor_images_links'] != null)
            ? List.castFrom<dynamic, String>(json['vendor_images_links'])
                .asMap()
                .entries
                .map((entry) {
                  final url = entry.value;

                  // Return the first image as it is, without modification
                  return url;
                })
                .take(5)
                .toList()
            : [""],
        videoUrl = videoUrl ?? "",
        description = (json["description"] == [] ||
                json["description"] == {} ||
                json["description"] == "")
            ? []
            : (json["description"] is Map)
                ? ((json["description"] as Map)
                    .entries
                    .map((entry) => "${entry.key} : ${entry.value}")
                    .toList())
                : (json["description"] is String)
                    ? json["description"].split('\n')
                    : (json["description"].toString().contains("[{") == false)
                        ? (List<String>.from(
                            json["description"].map((x) => x as String)))
                        : (json["description"].map<String>((item) {
                            String key = item.keys.first;
                            String value = item[key]!;
                            return "$key: $value";
                          }).toList()),
        mediumVendorImagesLinks = json["medium_vendor_images_links"] == null
            ? []
            : List<String>.from(
                json["medium_vendor_images_links"].map((x) => x as String)),
        shopId = json["shop_id"],
        googleCloudImagesLinks = json["google_cloud_images_links"] == null
            ? []
            : List<String>.from(
                json["google_cloud_images_links"].map((x) => x as String)),
        commentNum = json["comment_num"],
        mainCategoris = json["Main_cat"],
        subCategoris = json["Sub_cat"],

        // categories = json["categories"] == null
        //     ? []
        //     : List<List<String>>.from(json["categories"].map(
        //         (x) => x == null
        //             ? []
        //             : List<String>.from((x as List).map((y) => y as String)),
        //       )),
        tags = tags1,
        commentNumStr = json["comment_num_str"],
        variants = (json["variants"].isEmpty)
            ? [
                Variants(
                    employee: "",
                    oldPrice: "",
                    newPrice: "",
                    size: "",
                    id: 0,

                    placeInWarehouse: "",
                    quantity: "",
                    nickname: "",
                    season: "")
              ]
            : Variants.fromJsonList(
                json["variants"], json["max_purchase"] ?? 0),
        status = json["status"],
        vendorSku = json["vendor_sku"],
        sizeInfo = json["size_info"],
        adType = json["ad_type"],
        isCouponEligible = json["is_coupon_eligible"],
        nickname = (json["nickname"] == null || json["nickname"] == "")
            ? ""
            : json["nickname"],
        sku = (json["sku"] == null || json["sku"] == "") ? "" : json["sku"],
        createdAt = DateTime.tryParse(json["created_at"] ?? ""),
        url = json["url"] ?? "",
        featured = json["featured"],
        seen = json["seen"] ?? 0; // Initialize seen with 0 if null

  Item.fromJsonSimilarProduct(
    Map<dynamic, dynamic> json,
  )   : id = json["id"] ?? "",
        title = json["title"] ?? "",
        thumbnail = json["thumbnail"] ?? "",
        newPrice = (json["price"] != null)
            ? ((json["price"] != 0)
                ? "${(json["price"]).toStringAsFixed(2)} ₪"
                : "0 ₪")
            : "0 ₪",
        oldPrice = (json["price"] != null)
            ? (json["price"] != 0
                ? "${(double.parse(json["price"].toString()) * 2.5).toStringAsFixed(2)} ₪"
                : "0 ₪")
            : "0 ₪",
        vendorImagesLinks = (json['vendor_images_links'] != null)
            ? List.castFrom<dynamic, String>(json['vendor_images_links'])
                .asMap()
                .entries
                .map((entry) {
                  final url = entry.value;

                  // Return the first image as it is, without modification
                  return url;
                })
                .take(5)
                .toList()
            : [""],
        videoUrl = json["video_url"] ?? "",
        description = (json["description"] == [] ||
                json["description"] == {} ||
                json["description"] == "")
            ? []
            : (json["description"] is Map)
                ? ((json["description"] as Map)
                    .entries
                    .map((entry) => "${entry.key} : ${entry.value}")
                    .toList())
                : (json["description"] is String)
                    ? json["description"].split('\n')
                    : (json["description"].toString().contains("[{") == false)
                        ? (List<String>.from(
                            json["description"].map((x) => x as String)))
                        : (json["description"].map<String>((item) {
                            String key = item.keys.first;
                            String value = item[key]!;
                            return "$key: $value";
                          }).toList()),
        mediumVendorImagesLinks = json["medium_vendor_images_links"] == null
            ? []
            : List<String>.from(
                json["medium_vendor_images_links"].map((x) => x as String)),
        shopId = json["shop_id"],
        googleCloudImagesLinks = json["google_cloud_images_links"] == null
            ? []
            : List<String>.from(
                json["google_cloud_images_links"].map((x) => x as String)),
        commentNum = json["comment_num"],
        mainCategoris = json["Main_cat"],
        subCategoris = json["Sub_cat"],

        // categories = json["categories"] == null
        //     ? []
        //     : List<List<String>>.from(json["categories"].map(
        //         (x) => x == null
        //             ? []
        //             : List<String>.from((x as List).map((y) => y as String)),
        //       )),
        tags = (json["tags"] == null || json["tags"] == "")
            ? []
            : List<String>.from(json["tags"].map((x) => x as String)),
        commentNumStr = json["comment_num_str"],
        variants = (json["variants"].isEmpty)
            ? [
                Variants(
                    employee: "",
                    oldPrice: "",
                    newPrice: "",
                    size: "",
                    id: 0,

                    placeInWarehouse: "",
                    quantity: "",
                    nickname: "",
                    season: "")
              ]
            : Variants.fromJsonList(
                json["variants"], json["max_purchase"] ?? 0),
        status = json["status"],
        vendorSku = json["vendor_sku"],
        sizeInfo = json["size_info"],
        adType = json["ad_type"],
        isCouponEligible = json["is_coupon_eligible"],
        nickname = (json["nickname"] == null || json["nickname"] == "")
            ? ""
            : json["nickname"],
        sku = (json["sku"] == null || json["sku"] == "") ? "" : json["sku"],
        createdAt = DateTime.tryParse(json["created_at"] ?? ""),
        url = json["url"] ?? "",
        featured = json["featured"],
        seen = json["seen"] ?? 0; // Initialize seen with 0 if null

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  static List<Item> fromJsonListProducts(
      List<dynamic> jsonList, List<Item> allItems) {
    return jsonList.map((json) {
      final jsonMap = json as Map<String, dynamic>;
      final matchingItem = allItems.firstWhere(
        (item) =>
            item.id == jsonMap['id'], // Match title in json with id in allItems
        orElse: () => throw Exception(
            'No matching item found for title: ${jsonMap['id']}'),
      );

      return Item.fromJsonProduct(
          jsonMap,
          matchingItem.newPrice, // Use matching item's newPrice
          matchingItem.oldPrice,
          matchingItem.videoUrl,
          matchingItem.tags ?? [] // Use matching item's oldPrice
          );
    }).toList();
  }

  static List<Item> fromJsonListSimilarProducts(List<dynamic> jsonList) {
    return jsonList.map((json) {
      final jsonMap = json as Map<String, dynamic>;

      return Item.fromJsonSimilarProduct(
        jsonMap,
      );
    }).toList();
  }

  Item.fromJsonNewArrival(Map<String, dynamic> json)
      : id = json["id"],
        tags = (json["tags"] == null || json["tags"] == "")
            ? []
            : List<String>.from(json["tags"].map((x) => x as String)),
        variants = [
          Variants(
              employee: "",
              oldPrice: "",
              newPrice: "",
              id: json["id"],
              size: "${json["id"]}",
              placeInWarehouse: "",
              quantity: "",
              nickname: "",
              season: "")
        ],
        title = json["title"],
        thumbnail = (json["thumbnail"] != null) ? json["thumbnail"] : "",
        newPrice = (json["price"] != null)
            ? ((json["price"] != 0)
                ? "${(json["price"]).toStringAsFixed(2)} ₪"
                : "0 ₪")
            : "0 ₪",
        oldPrice = (json["price"] != null)
            ? (json["price"] != 0
                ? "${(double.parse(json["price"].toString()) * 2.5).toStringAsFixed(2)} ₪"
                : "0 ₪")
            : "0 ₪",
        vendorImagesLinks = (json['vendor_images_links'] != null)
            ? List.castFrom<dynamic, String>(json['vendor_images_links'])
                .map((url) {
                  if ((url.contains('img.ltwebstatic.com'))) {
                    final extension = url.split('.').last;

                    // Append _thumbnail_400x400 before the extension
                    return url.replaceAll(RegExp(r'(\.[a-zA-Z]+)$'),
                        '_thumbnail_400x400.$extension');
                  }
                  return url; // Return the original URL if it contains 'google'
                })
                .take(5)
                .toList()
            : [""],
        seen = 0; // Default to 0 for new arrivals

  static List<Item> fromJsonListNewArrival(List<dynamic> jsonList) {
    return jsonList.map((json) {
      return Item.fromJsonNewArrival(json);
    }).toList();
  }

  static List<Item> fromJsonListSpecificIds(List<dynamic> jsonList) {
    return jsonList.map((json) {
      return Item.fromJsonProductSpecificId(json);
    }).toList();
  }

  Item.fromJsonFlash(Map<String, dynamic> json)
      : id = json['item_id'],
        title = json['item_name'],
        tags = (json["tags"] == null || json["tags"] == "")
            ? []
            : List<String>.from(json["tags"].map((x) => x as String)),
        newPrice = (json["new_price"] != null)
            ? ((json["new_price"] != 0)
                ? "${(json["new_price"]).toStringAsFixed(2)} ₪"
                : "0 ₪")
            : "0 ₪",
        variants = [
          Variants(
              employee: "",
              oldPrice: "",
              newPrice: "",
              id: json['item_id'],
              size: "${json['item_id']}",
              placeInWarehouse: "",
              quantity: "",
              nickname: "",
              season: "")
        ],
        oldPrice = (json["old_price"] != null)
            ? (json["old_price"] != 0
                ? "${(double.parse(json["old_price"].toString())).toStringAsFixed(2)} ₪"
                : "0 ₪")
            : "0 ₪",
        vendorImagesLinks = (json['images'] != null)
            ? List.castFrom<dynamic, String>(json['images'])
                .map((url) {
                  if ((url.contains('img.ltwebstatic.com'))) {
                    final extension = url.split('.').last;

                    // Append _thumbnail_400x400 before the extension
                    return url.replaceAll(RegExp(r'(\.[a-zA-Z]+)$'),
                        '_thumbnail_400x400.$extension');
                  }
                  return url; // Return the original URL if it contains 'google'
                })
                .take(5)
                .toList()
            : [""],
        seen = 0; // Default to 0 for new arrivals
  static List<Item> fromJsonListFlash(List<dynamic> jsonList) {
    return jsonList.map((json) => Item.fromJsonFlash(json)).toList();
  }

  Item.fromJsonBestSeller(Map<String, dynamic> json)
      : id = json['item_id'],
        title = json['item_name'],
        tags = (json["tags"] == null || json["tags"] == "")
            ? []
            : List<String>.from(json["tags"].map((x) => x as String)),
        variants = [
          Variants(
              employee: "",
              oldPrice: "",
              newPrice: "",
              id: json['item_id'],
              size: "${json['item_id']}",
              placeInWarehouse: "",
              quantity: "",
              nickname: "",
              season: "")
        ],
        thumbnail = null,
        newPrice = (json["price"] != null)
            ? ((json["price"] != 0)
                ? "${(json["price"]).toStringAsFixed(2)} ₪"
                : "0 ₪")
            : "0 ₪",
        oldPrice = (json["price"] != null)
            ? (json["price"] != 0
                ? "${(double.parse(json["price"].toString()) * 2.5).toStringAsFixed(2)} ₪"
                : "0 ₪")
            : "0 ₪",
        vendorImagesLinks = (json['images'] != null)
            ? List.castFrom<dynamic, String>(json['images'])
                .map((url) {
                  if ((url.contains('img.ltwebstatic.com'))) {
                    final extension = url.split('.').last;

                    // Append _thumbnail_400x400 before the extension
                    return url.replaceAll(RegExp(r'(\.[a-zA-Z]+)$'),
                        '_thumbnail_400x400.$extension');
                  }
                  return url; // Return the original URL if it contains 'google'
                })
                .take(5)
                .toList()
            : [""],
        seen = 0; // Default to 0 for new arrivals

  static List<Item> fromJsonListBestSeller(List<dynamic> jsonList) {
    return jsonList.map((json) => Item.fromJsonBestSeller(json)).toList();
  }

  Map<String, dynamic> toJsonNewArrival() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['thumbnail'] = thumbnail;
    data['price'] = newPrice;
    data['vendor_images_links'] = vendorImagesLinks;
    return data;
  }

  Map<String, dynamic> toJsonProduct() => {
        "vendor_images_links": vendorImagesLinks?.map((x) => x).toList(),
        "video_url": videoUrl,
        "description": description?.map((x) => x).toList(),
        "medium_vendor_images_links":
            mediumVendorImagesLinks?.map((x) => x).toList(),
        "shop_id": shopId,

        "id": id,
        "thumbnail": thumbnail,
        "google_cloud_images_links":
            googleCloudImagesLinks?.map((x) => x).toList(),
        "comment_num": commentNum,
        // "categories": categories?.map((x) => x.map((x) => x).toList()).toList(),
        "tags": tags,
        "comment_num_str": commentNumStr,
        "variants": variants?.map((x) => x).toList(),
        "status": status,
        "title": title,
        "vendor_sku": vendorSku,
        "size_info": sizeInfo,
        "ad_type": adType,
        "is_coupon_eligible": isCouponEligible,
        "nickname": nickname,
        "sku": sku,
        "created_at": createdAt?.toIso8601String(),
        "url": url,
        "featured": featured,
        "seen": seen,
      };
}
