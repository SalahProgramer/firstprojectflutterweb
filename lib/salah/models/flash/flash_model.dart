import '../items/item_model.dart';

class FlashModel {
  bool active;
  String name;
  String startDate;
  String endDate;
  dynamic userLimit;
  dynamic countdownHours;
  dynamic page;
  dynamic limit;
  dynamic totalItems;
  dynamic totalPages;
  List<Item> items;

  FlashModel({
    required this.active,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.userLimit,
    required this.countdownHours,
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
    required this.items,
  });

  factory FlashModel.fromJson(Map<String, dynamic> json) {
    return FlashModel(
      active: json['active'] ?? false,
      name: json['name'] ?? "",
      startDate: json['start_date'] ?? "",
      endDate: json['end_date'] ?? "",
      userLimit: json['user_limit'] ?? "0",
      countdownHours: json['countdown_hours'] ?? "0",
      page: json['page'] ?? "0",
      limit: json['limit'] ?? "0",
      totalItems: json['total_items'] ?? "0",
      totalPages: json['total_pages'] ?? "0",
      items: Item.fromJsonListFlash(json['items']),
    );
  }
}
