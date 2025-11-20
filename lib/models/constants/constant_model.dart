import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';

class CategoryModel with CustomDropdownListFilter {
  final String? id;
  final String name;
  final String image;
  final String mainCategory;
  final String? subCategory;
  final String? icon;

  CategoryModel({
    this.id,
    required this.name,
    required this.subCategory,
    required this.image,
    required this.mainCategory,
    this.icon,
  });

  // Factory method to create a Category instance from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
        name: json['name'] as String,
        image: json['image'] as String,
        subCategory: (json['sub_category'] == null)
            ? ""
            : json['sub_category'] as String,
        id: json['id'] ?? "0",
        mainCategory: json['main_category'] as String,
        icon: ""
        // json['icon'] as String,
        );
  }

  static List<CategoryModel> fromJsonListCategory(List<dynamic> jsonList) {
    return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
  }

  // Factory method to create a Category instance from JSON
  factory CategoryModel.fromJsonTags(Map<String, dynamic> json) {
    return CategoryModel(
        name: json['tag'] as String,
        image: Assets.images.tags.path,
        subCategory: "",
        mainCategory: "",
        icon: "");
  }

  static List<CategoryModel> fromJsonListTags(List<dynamic> jsonList) {
    return jsonList.map((json) => CategoryModel.fromJsonTags(json)).toList();
  }

  // Method to convert a Category instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'main_category': mainCategory,
      'icon': icon,
    };
  }

  @override
  String toString() {
    return name;
  }

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}
