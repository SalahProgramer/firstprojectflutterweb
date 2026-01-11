class SliderModel {
  String title;
  String action;
  String type;
  String description;
  String image;
  int? id;
  SliderModel({
    required this.image,
    required this.description,
    required this.title,
    required this.id,
    required this.action,
    required this.type,
  });

  static List<SliderModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SliderModel.fromJson(json)).toList();
  }

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      image: json['image_url'] ?? "",
      id: json['id'] ?? "",
      description: json['description'] ?? "",
      title: json['title'] ?? "",
      type: json['type'] ?? "",
      action: json['action'] ?? "",
    );
  }
}
