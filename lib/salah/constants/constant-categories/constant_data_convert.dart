// This file provides backward compatibility by exporting category data
// from the new CategoriesDataService in the old format

import 'package:fawri_app_refactor/salah/constants/constant-categories/categories_data_service.dart';
import 'package:fawri_app_refactor/salah/constants/constant-categories/categories_data_model.dart';
export 'package:fawri_app_refactor/salah/utilities/style/colors.dart';

// Helper to convert CategoryItem to Map format
List<Map<String, String>> toJsonList(List<CategoryItem> items) {
  return items
      .map(
        (item) => {
          'id': item.id?.toString() ?? '',
          'name': item.name,
          'image': item.image,
          'main_category': item.mainCategory,
          'sub_category': item.subCategory ?? '',
        },
      )
      .toList();
}

// Helper to convert Tags to Map format
List<Map<String, String>> tagsToJsonList(List<Tag> tags) {
  return tags.map((tag) => {'tag': tag.tag}).toList();
}

// Basic Categories
List<Map<String, String>> get basicCategories =>
    toJsonList(CategoriesDataService.instance.basicCategories);

List<Map<String, String>> get secondaryCategories =>
    toJsonList(CategoriesDataService.instance.secondaryCategories);

// Detailed Categories
List<dynamic> get women => toJsonList(CategoriesDataService.instance.women);

List<dynamic> get womenPlus =>
    toJsonList(CategoriesDataService.instance.womenPlus);

List<dynamic> get men => toJsonList(CategoriesDataService.instance.men);

List<dynamic> get boys => toJsonList(CategoriesDataService.instance.boys);

List<dynamic> get girls => toJsonList(CategoriesDataService.instance.girls);

List<dynamic> get allkids => toJsonList(CategoriesDataService.instance.allkids);

List<dynamic> get kidsShoes =>
    toJsonList(CategoriesDataService.instance.kidsShoes);

List<dynamic> get womenShoes =>
    toJsonList(CategoriesDataService.instance.womenShoes);

List<dynamic> get menShoes =>
    toJsonList(CategoriesDataService.instance.menShoes);

List<dynamic> get allShoes =>
    toJsonList(CategoriesDataService.instance.allShoes);

List<dynamic> get womenAndBaby =>
    toJsonList(CategoriesDataService.instance.womenAndBaby);

List<dynamic> get underWare =>
    toJsonList(CategoriesDataService.instance.underWare);

List<dynamic> get home => toJsonList(CategoriesDataService.instance.home);

List<dynamic> get apparel => toJsonList(CategoriesDataService.instance.apparel);

List<dynamic> get beauty => toJsonList(CategoriesDataService.instance.beauty);

List<dynamic> get electronics =>
    toJsonList(CategoriesDataService.instance.electronics);

List<dynamic> get bags => toJsonList(CategoriesDataService.instance.bags);

List<dynamic> get sports => toJsonList(CategoriesDataService.instance.sports);

List<dynamic> get perfume => toJsonList(CategoriesDataService.instance.perfume);

// Tags
List<dynamic> get tags => tagsToJsonList(CategoriesDataService.instance.tags);

List<dynamic> get tagsMen =>
    tagsToJsonList(CategoriesDataService.instance.tagsMen);

List<dynamic> get womenTags =>
    tagsToJsonList(CategoriesDataService.instance.womenTags);
