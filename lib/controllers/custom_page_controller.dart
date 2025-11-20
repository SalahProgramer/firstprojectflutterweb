import 'package:flutter/material.dart';

class CustomPageController extends ChangeNotifier {
  final pageController = PageController(initialPage: 0);
  final pageCategoryController = PageController(initialPage: 0);
  int selectPage = 0;
  int selectCategoryPage = 0;
  Widget? selectWidget;
  Widget? selectWidgetSub;

  bool first = true;
  bool second = true;

  Future<void> changePage0(bool change) async {
    first = change;
    notifyListeners();
  }

  Future<void> changeCategories(bool change) async {
    second = change;
    notifyListeners();
  }

  Future<void> changeIndexPage(int index) async {
    selectPage = index;
    notifyListeners();
  }

  Future<void> changeIndexCategoryPage(int index) async {
    selectCategoryPage = index;
    notifyListeners();
  }

  Widget? widgetSubProductList() {
    return selectWidget;
  }

  Widget? changeSubProductList({required Widget widget}) {
    selectWidget = widget;
    notifyListeners();

    return selectWidget;
  }
}
