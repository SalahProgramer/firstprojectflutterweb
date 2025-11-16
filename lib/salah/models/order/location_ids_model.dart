class LocationIdsModel {
  LocationIdsModel({
    required this.cityId,
    required this.areaId,
    required this.areaName,
  });

  late String cityId;
  late String areaId;
  late String areaName;

  LocationIdsModel.fromJson(Map<String, dynamic> json) {
    cityId = json['city_id'] ?? '';
    areaId = json['area_id'] ?? '';
    areaName = json['area_name'] ?? '';
  }

  static List<LocationIdsModel> fromJsonListLocationIdsModel(
      List<dynamic> jsonList) {
    return jsonList.map((json) => LocationIdsModel.fromJson(json)).toList();
  }

  @override
  String toString() {
    return '''
LocationIdsModel(
  cityId: $cityId,
  areaId: $areaId,
  areaName: $areaName)
  ''';
  }
}
