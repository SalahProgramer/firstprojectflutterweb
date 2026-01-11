class StyleModel {
  String styleId;
  String bGColor;
  int? flexStyle;
  int? flexImage;
  StyleModel({
    required this.styleId,
    required this.bGColor,
    this.flexImage,
    this.flexStyle,
  });

  static List<StyleModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => StyleModel.fromJson(json)).toList();
  }

  factory StyleModel.fromJson(Map<String, dynamic> json) {
    return StyleModel(
      styleId: json['style_id'] ?? "",
      bGColor: json['BG_color'] ?? "",
      flexImage: json['flex_image'] ?? 2,
      flexStyle: json['flex_style'] ?? 2,
    );
  }
}
