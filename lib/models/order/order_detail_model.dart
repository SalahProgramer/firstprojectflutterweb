import 'location_ids_model.dart';
import 'order.dart';

class OrderDetailModel {
  OrderDetailModel({
    this.isFawriOrder,
    this.driver,
    this.page,
    this.isCancelled,
    this.isFreeDriver,
    this.totalPrice,
    this.locationIds,
    this.description,
    this.address,
    this.user,
    this.name,
    this.status,
    required this.orderId,
    this.createdAt,
    this.phone,
    this.listItemOrder,
  });
  late bool? isFawriOrder;
  late String? driver;
  late String? page;
  late bool? isCancelled;
  late bool? isFreeDriver;
  late String? totalPrice;
  late LocationIdsModel? locationIds;
  late String? description;
  late String? address;
  late String? user;
  late String? name;
  late String? status;
  late int orderId;
  late String? phone;
  late String? createdAt;
  late List<SpecificOrder>? listItemOrder;

  OrderDetailModel.fromJson(Map<String, dynamic> json) {
    isFawriOrder = json['is_fawri_order'] ?? false;
    driver = json['driver'] ?? '';
    page = json['page'] ?? '';
    isCancelled = ((json['status'].toString().toLowerCase() == "cancelled") ||
            (json['status'].toString().toLowerCase() == "to cancel"))
        ? true
        : false;
    isFreeDriver = json['is_free_driver'] ?? false;
    totalPrice = json['total_price'] ?? '0';
    locationIds = LocationIdsModel.fromJson(json['location_ids'] ?? {});
    description = json['description'] ?? '';
    address = json['address'] ?? '';
    user = json['user'] ?? '';
    name = json['name'] ?? '';
    status = json['status'] ?? '';
    orderId = json['id'] ?? 0;
    phone = json['phone'] ?? '';
    createdAt =
        (json['created_at'] != null) ? json['created_at'].substring(0, 10) : '';
    // Parse list of SpecificOrder items
    if (json['items'] != null) {
      listItemOrder = (json['items'] as List)
          .map((item) => SpecificOrder.fromJson(item))
          .toList();
    } else {
      listItemOrder = [];
    }
  }

  /// **Helper method to parse a list of `OrderDetailModel`**
  static List<OrderDetailModel> fromJsonListOrderItems(List<dynamic> jsonList) {
    return jsonList.map((json) => OrderDetailModel.fromJson(json)).toList();
  }


  @override
  String toString() {
    return '''
OrderDetailModel(
  orderId: $orderId,
  name: $name,
  user: $user,
  phone: $phone,
  address: $address,
  description: $description,
  totalPrice: $totalPrice,
  isFawriOrder: $isFawriOrder,
  isFreeDriver: $isFreeDriver,
  isCancelled: $isCancelled,
  driver: $driver,
  status: $status,
  createdAt: $createdAt,
  locationIds: $locationIds,
  page: $page,
  listItemOrder: ${listItemOrder?.map((e) => e.toString()).join(', ')}
)
''';
  }
}
