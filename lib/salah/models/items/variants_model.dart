import 'dart:collection';

class Variants {
  Variants({
    required this.id,
    required this.employee,
    required this.oldPrice,
    required this.newPrice,
    required this.size,
    required this.placeInWarehouse,
    required this.quantity,
    required this.nickname,
    required this.season,
  });
  late final int? id;
  late final String? employee;
  late final dynamic oldPrice;
  late final dynamic newPrice;
  late final String? size;
  late final String? placeInWarehouse;
  late final dynamic quantity;
  late final String? nickname;
  late final String? season;
  late final String? checkedBy;


  Variants.fromJson(Map<String, dynamic> json, int maxPurchase) {
    id = json['id'];
    employee = json['employee'] ?? "";
    newPrice = (json["price"] != null)
        ? ((json["price"] != 0)
            ? "${(json["price"]).toStringAsFixed(2)} ₪"
            : "0 ₪")
        : "0 ₪";
    oldPrice = (json["price"] != null)
        ? (json["price"] != 0
            ? "${(double.parse(json["price"].toString()) * 2.5).toStringAsFixed(2)} ₪"
            : "0 ₪")
        : "0 ₪";
    size = json['size'] ?? "";
    placeInWarehouse = json['place_in_warehouse'] ?? "";
    // Convert to int for comparison, but store as dynamic

    if ((json['quantity'] != null) &&
        json['quantity'].toString().trim().isNotEmpty) {
      int jsonQuantityInt = int.tryParse(json['quantity'].toString()) ?? 0;
      if (maxPurchase > 0) {
        quantity =
            (maxPurchase <= jsonQuantityInt) ? maxPurchase : jsonQuantityInt;
      } else if (maxPurchase == 0) {
        quantity = jsonQuantityInt;
      }
    } else {
      quantity = "";
    }
    nickname = json['nickname'] ?? "";
    season = json['season'] ?? "";
    checkedBy = json['checkedBy'];
  }

  static List<Variants> fromJsonList(List<dynamic> jsonList, int maxPurchase) {
    final uniqueVariants = LinkedHashSet<String>.from(jsonList.map(
        (json) => Variants.fromJson(json, maxPurchase).size.toString().trim()));

    return uniqueVariants.map((size) {
      return jsonList
          .map((json) => Variants.fromJson(json, maxPurchase))
          .firstWhere((variant) => variant.size.toString().trim() == size);
    }).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['employee'] = employee;
    data['price'] = newPrice;
    data['size'] = size;
    data['place_in_warehouse'] = placeInWarehouse;
    data['quantity'] = quantity;
    data['nickname'] = nickname;
    data['season'] = season;
    data['checkedBys'] = season;
    return data;
  }
}
