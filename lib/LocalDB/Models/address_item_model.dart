class AddressItem {
  final int? id;
  final String name;
  final String userId;
  final String cityId;
  final String cityName;
  final String areaId;
  final String areaName;

  AddressItem({
    this.id,
    required this.userId,
    required this.areaId,
    required this.cityId,
    required this.cityName,
    required this.areaName,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'area_name': areaName,
      'area_id': areaId,
      'city_id': cityId,
      'city_name': cityName,
    };
  }

  factory AddressItem.fromJson(Map<String, dynamic> json) {
    return AddressItem(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      areaName: json['area_name'],
      areaId: json['area_id'],
      cityId: json['city_id'],
      cityName: json['city_name'],
    );
  }

  AddressItem copyWith({
    int? id,
    String? userId,
    String? cityId,
    String? areaId,
    String? areaName,
    String? cityName,
    String? name,
  }) {
    return AddressItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      areaId: areaId ?? this.areaId,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      areaName: areaName ?? this.areaName,
      name: name ?? this.name,
    );
  }
}
