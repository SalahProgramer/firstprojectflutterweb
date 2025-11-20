import 'package:fawri_app_refactor/models/user/pending_order_model.dart';
import 'enum_point_status.dart';
import 'order_check_model.dart';

class UserActivity {
  final bool? isActive;
  final List<PendingOrder> pendingOrders;
  final Map<String, EnumPointsStatus> lastEnumStatus;
  final OrderCheckModel? checkOrderStatus;

  UserActivity({
    this.isActive = true,
    this.pendingOrders = const [],
    this.lastEnumStatus = const {},
    this.checkOrderStatus,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    // Handle empty enum status map by creating default values
    Map<String, EnumPointsStatus> enumStatus = {
      '1': EnumPointsStatus.defaultStatus(),
      '2': EnumPointsStatus.defaultStatus(canUse: true),
      '3': EnumPointsStatus.defaultStatus(),
      '4': EnumPointsStatus.defaultStatus(),
      '5': EnumPointsStatus.defaultStatus(),
      '6': EnumPointsStatus.defaultStatus(),
    };

    if (json['last_enum_status'] != null && json['last_enum_status'] is Map) {
      final enumData = json['last_enum_status'] as Map<String, dynamic>;
      if (enumData.isNotEmpty) {
        enumStatus = enumData.map(
            (key, value) => MapEntry(key, EnumPointsStatus.fromJson(value)));
      }
    }

    return UserActivity(
      isActive: json['is_active'] ?? true,
      pendingOrders: (json['pending_orders'] as List<dynamic>?)
              ?.map((order) => PendingOrder.fromJson(order))
              .toList() ??
          [],
      lastEnumStatus: enumStatus,
      checkOrderStatus: json['check_order_status'] != null
          ? OrderCheckModel.fromJson(json['check_order_status'])
          : OrderCheckModel(success: false, message: "", orderId: 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_active': isActive,
      'pending_orders': pendingOrders.map((order) => order.toJson()).toList(),
      'last_enum_status':
          lastEnumStatus.map((key, value) => MapEntry(key, value.toJson())),
      'check_order_status': checkOrderStatus?.toJson(),
    };
  }

  // Helper method to get enum status by key with fallback
  EnumPointsStatus getEnumStatus(String key) {
    return lastEnumStatus[key] ??
        EnumPointsStatus.defaultStatus(canUse: (key == "2") ? true : false);
  }

  // Helper method to check if specific enum can be used
  bool canUseEnum(String key) {
    final status = getEnumStatus(key);
    return status.canUseNow;
  }

  // Helper method to get formatted time for specific enum
  String getEnumTimeRemaining(String key) {
    final status = getEnumStatus(key);
    return status.formattedTimeRemaining;
  }

  @override
  String toString() {
    return 'UserActivity(isActive: $isActive, pendingOrders: ${pendingOrders.length}, enumStatuses: ${lastEnumStatus.length}, checkOrderStatus: $checkOrderStatus)';
  }
}
