class FirstImagesModel {
  late String mainCategory;
  late String image;
  late String id;
  FirstImagesModel(
      {required this.mainCategory, required this.image, required this.id});

  // late  bool cancelled;
  // late  String pushToken;

  FirstImagesModel.fromJson(Map<String, dynamic> json) {
    mainCategory = json['main_category'] ?? '';
    image = json['image'] ?? '';
    id = json['id'] ?? '';
  }
  static List<FirstImagesModel> fromJsonListImagesCategory(
      List<dynamic> jsonList) {
    return jsonList.map((json) => FirstImagesModel.fromJson(json)).toList();
  }
}
