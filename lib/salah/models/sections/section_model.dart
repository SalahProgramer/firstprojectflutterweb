import 'package:fawri_app_refactor/salah/models/sections/style_model.dart';
import '../items/item_model.dart';

class SectionModel {
  int id;
  String name;
  String contentUrl;
  StyleModel? style;
  int feedOrder;
  List<Item> content;

  // New attributes
  String bgImage;
  int height;
  bool animation;
  String type;
  bool active;

  SectionModel({
    required this.id,
    required this.name,
    required this.contentUrl,
    required this.style,
    required this.content,
    required this.feedOrder,
    this.bgImage = "",
    this.height = 250,
    this.animation = false,
    this.type = "section",
    this.active = true,
  });

  static List<SectionModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => SectionModel.fromJson(json))
        .where((section) =>
            (section.content.isNotEmpty && section.type == "section") ||
            section.type == "banner") // filter out empty content
        .toList();
  }

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    List<Item> items = [];
    if (json["content"] != null &&
        json["content"]["items"] != null &&
        (json["content"]["items"] as List).isNotEmpty) {
      items = Item.fromJsonListNewArrival(json["content"]["items"]);
    }

    return SectionModel(
      id: (json['id'] is int) ? json['id'] : 0,
      name: (json['name'] is String) ? json['name'] : "",
      content: items,
      contentUrl: (json['content_url'] is String) ? json['content_url'] : "",
      style: (json['style'] != null && (json['style'] as Map).isNotEmpty)
          ? StyleModel.fromJson(json['style'])
          : null,
      feedOrder: (json['feed_order'] is int) ? json['feed_order'] : 0,
      bgImage: (json['bg_image'] is String) ? json['bg_image'] : "",
      height: (json['height'] is int) ? json['height'] : 350,
      animation: (json['animation'] is bool) ? json['animation'] : false,
      type: (json['type'] is String) ? json['type'] : "section",
      active: (json['active'] is bool) ? json['active'] : true,
    );
  }
}
