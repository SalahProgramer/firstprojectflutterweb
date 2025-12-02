import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/constants/constant_data/constant_data_convert.dart';
import '../core/network/connection_network.dart';
import '../core/services/database/hive_data/data_sizes.dart';
import '../core/utilities/global/app_global.dart';
import '../core/utilities/routes.dart';
import '../core/utilities/print_looger.dart';
import 'APIS/api_departments_controller.dart';
import 'favourite_controller.dart';
import '../models/constants/constant_model.dart';
import '../models/items/item_model.dart';
import 'APIS/api_main_product_controller.dart';
import 'fetch_controller.dart';

class DepartmentsController extends ChangeNotifier {
  int totalItems = 0;
  List<Item> itemsData = [];
  int? selectedIndex = 0; //design before------------

  int _requestVersion = 0;

  List<CategoryModel> subCategoriesDepartment = [];
  List<CategoryModel> listTags = [];
  CategoryModel selectSubCategorySpecific = CategoryModel(
      name: "", image: "", mainCategory: "", icon: "", subCategory: "");

  List<CategoryModel> listSelectedMultiSubCategoryDepartment = [];
  CategoryModel subSelectedSingleSubCategoryDepartment = CategoryModel(
      name: "", image: "", mainCategory: "", icon: "", subCategory: "");

  ////-----------------------------------
  bool haveCheck = false;
  bool haveCheckShoes = false;
  bool haveCheckWomenClothes = false;
  bool haveCheckWomenPlusClothes = false;
  bool haveCheckWomenShoes = false;
  bool haveCheckMenClothes = false;
  bool haveCheckMenShoes = false;
  bool haveCheckKidsShoes = false;
  bool haveCheckBoyKids = false;
  bool haveCheckGirlKids = false;
  int numSort = 2;
  bool haveCheckUnderWareClothes = false;
  Map<String, bool>? isLoadingWomenClothesTypes = {
    for (var entry in womenSizesList.entries) entry.key: false,
  };

  Map<String, bool>? isLoadingBoyKids = {
    for (var size in kidsBoysSizesList) size.trim().toString(): false,
  };
  Map<String, bool>? isLoadingGirlKids = {
    for (var size in girlsKidsSizesList) size.trim().toString(): false,
  };

  Map<String, bool>? isLoadingKidsShoes = {
    for (var size in kidsShoesSizesList) size.trim().toString(): false,
  };

  Map<String, bool>? isLoadingWomenShoes = {
    for (var size in womenShoesSizesList) size.trim().toString(): false,
  };
  Map<String, bool>? isLoadingMenShoes = {
    for (var size in menShoesSizesList) size.trim().toString(): false,
  };
  Map<String, bool>? isLoadingUnderWareTypes = {
    for (var size in underwearSizes) size.trim().toString(): false,
  };
  Map<String, bool>? isLoadingMenClothesTypes = {
    for (var entry in menSizesList.entries) entry.key: false,
  };

  Map<String, bool>? isLoadingWomenPlusClothesTypes = {
    for (var entry in womenPlusSizesList.entries) entry.key: false,
  };

  bool showShimmer = true;
  bool haveMoreData = true;
  bool showSpinKitMoreData = false;

  bool checkWifi = true;
  int numPageSelectDepartment = 1;
  int numberPage = 0;

  Map<String, int> positionScroll = {};
  Map<String, bool> isFavourite = {};
  FavouriteController favouriteController =
      NavigatorApp.context.read<FavouriteController>();
  ApiDepartmentsController api =
      NavigatorApp.context.read<ApiDepartmentsController>();

  FetchController fetchController =
      NavigatorApp.context.read<FetchController>();
  ApiMainProductController apiMain =
      NavigatorApp.context.read<ApiMainProductController>();

  //scroll-----------------------------------------------------------------
  ScrollController scrollPerfumeItems = ScrollController();
  ScrollController scrollMultiItems = ScrollController();

  void _bumpRequestVersion() {
    _requestVersion++;
  }

  bool isRequestVersionActive(int version) => version == _requestVersion;

  //---check wifi---------------------------------------------------
  Future<void> connectedWifi() async {
    if (await isConnectedWifi()) {
      checkWifi = true;
    } else {
      checkWifi = false;
    }
  }

//---------------------clear -----------------------------------------------------------------
  Future<void> clear() async {
    _bumpRequestVersion();
    itemsData.clear();
    showSpinKitMoreData = false;
    subCategoriesDepartment = [];
    numPageSelectDepartment = 1;
    selectedIndex = 0; //design before------------
    selectSubCategorySpecific = CategoryModel(
        name: "", image: "", mainCategory: "", icon: "", subCategory: "");
    subSelectedSingleSubCategoryDepartment = CategoryModel(
        name: "", image: "", mainCategory: "", icon: "", subCategory: "");

    totalItems = 0;
    showShimmer = true;
    haveMoreData = true;
    notifyListeners();
  }

  Future<void> clearAll() async {
    _bumpRequestVersion();
    itemsData.clear();
    subCategoriesDepartment = [];
    numPageSelectDepartment = 1;
    numberPage = 0;
    numSort = 2;
    showSpinKitMoreData = false;

    showShimmer = true;
    haveMoreData = true;

    selectedIndex = 0; //design before------------
    selectSubCategorySpecific = CategoryModel(
        name: "", image: "", mainCategory: "", icon: "", subCategory: "");
    subSelectedSingleSubCategoryDepartment = CategoryModel(
        name: "", image: "", mainCategory: "", icon: "", subCategory: "");

    listSelectedMultiSubCategoryDepartment = [];
    totalItems = 0;
    notifyListeners();
  }

  Future<void> changeSpinHaveMoreData(bool check) async {
    showSpinKitMoreData = check;
    notifyListeners();
  }

  Future<void> clearMulti() async {
    _bumpRequestVersion();
    numPageSelectDepartment = 1;

    listSelectedMultiSubCategoryDepartment = [];
    itemsData = [];
    showSpinKitMoreData = false;

    totalItems = 0;
    numSort = 2;


    numberPage = 0;
    showShimmer = true;
    haveMoreData = true;

    notifyListeners();
  }

  Future<void> clearSort() async {
    _bumpRequestVersion();
    numPageSelectDepartment = 1;
    totalItems = 0;
    showSpinKitMoreData = false;

    itemsData = [];

    numberPage = 0;
    showShimmer = true;
    haveMoreData = true;

    notifyListeners();
  }

  Future<void> clearSubDepartment() async {
    _bumpRequestVersion();
    totalItems = 0;
    showSpinKitMoreData = false;

    numPageSelectDepartment = 1;
    itemsData = [];
    numSort = 2;

    notifyListeners();
  }

  //sets--=-=-=-=-=-=-=-=-=-=-=---------------------------------------------------------------------===-=-=-=-=-=-

  Future<void> setTotalItems(int total) async {
    totalItems = total;
    notifyListeners();
  }

  Future<void> setPagesShow(int page) async {
    numberPage = page;
    notifyListeners();
  }

  Future<void> setNumSort(int page) async {
    numSort = page;
    notifyListeners();
  }

  Future<void> setSubCategorySpecific(CategoryModel category) async {
    selectSubCategorySpecific = category;
    notifyListeners();
  }

  Future<void> setSubCategoryDepartments(
      List<dynamic> subDepartment, bool addTags) async {
    var category = CategoryModel.fromJsonListCategory(subDepartment);
    subCategoriesDepartment = category;

    if (addTags == true) {
      List<CategoryModel> addTags = CategoryModel.fromJsonListTags(tags);

      // await apiMain.apiGetTag();
      addTags.removeWhere(
        (element) {
          return element.name == "Christmas" ||
              element.name == "flash_sales" ||
              element.name == "discount" ||
              element.name == "Flash Sales" ||
              element.name == "2025 home" ||
              element.name == "11.11";
        },
      );
      // addTags.add
      listTags.add(CategoryModel(
          name: "جميع الماركات",
          subCategory: "",
          image: "",
          mainCategory: "",
          icon: ""));
      listTags.addAll(addTags);

      subCategoriesDepartment.addAll(listTags);
    }

    notifyListeners();
  }

  Future<void> setSubCategoryDepartmentsPerfume(
      List<dynamic> subDepartment) async {
    var category = CategoryModel.fromJsonListTags(subDepartment);
    subCategoriesDepartment.add(CategoryModel(
        name: "جميع الماركات",
        subCategory: "",
        image: "",
        mainCategory: "",
        icon: ""));

    subCategoriesDepartment.addAll(category);

    notifyListeners();
  }

  //---------------------------categories------------------------------------------------------------------------------

//----------------women clothes------------------

  Future<void> changeLoadingWomenClothes(String type, bool check) async {
    isLoadingWomenClothesTypes?[type] = check;
    haveCheckWomenClothes =
        isLoadingWomenClothesTypes?.values.any((value) => value) ?? false;

    notifyListeners();
  }

  Future<void> clearWomenClothes() async {
    isLoadingWomenClothesTypes = {
      for (var entry in womenSizesList.entries) entry.key: false,
    };
    haveCheckWomenClothes = false;
    notifyListeners();
  }

  //----------------men clothes------------------

  Future<void> changeLoadingMenClothes(String type, bool check) async {
    isLoadingMenClothesTypes?[type] = check;
    haveCheckMenClothes =
        isLoadingMenClothesTypes?.values.any((value) => value) ?? false;

    notifyListeners();
  }

  Future<void> clearMenClothes() async {
    isLoadingMenClothesTypes = {
      for (var entry in menSizesList.entries) entry.key: false,
    };
    haveCheckMenClothes = false;
    notifyListeners();
  }

  //----------------boy kids------------------

  Future<void> changeLoadingBoyKids(String type, bool check) async {
    isLoadingBoyKids?[type] = check;
    haveCheckBoyKids = isLoadingBoyKids?.values.any((value) => value) ?? false;

    notifyListeners();
  }

  Future<void> clearBoyKids() async {
    isLoadingBoyKids = {
      for (var size in kidsBoysSizesList) size.trim().toString(): false,
    };
    haveCheckBoyKids = false;
    notifyListeners();
  }

  //----------------girl kids------------------

  Future<void> changeLoadingGirlKids(String type, bool check) async {
    isLoadingGirlKids?[type] = check;
    haveCheckGirlKids =
        isLoadingGirlKids?.values.any((value) => value) ?? false;

    notifyListeners();
  }

  Future<void> clearGirlKids() async {
    isLoadingGirlKids = {
      for (var size in girlsKidsSizesList) size.trim().toString(): false,
    };
    haveCheckGirlKids = false;
    notifyListeners();
  }

//----------------man shoes------------------

  Future<void> changeLoadingMenShoes(String type, bool check) async {
    isLoadingMenShoes?[type] = check;
    haveCheckMenShoes =
        isLoadingMenShoes?.values.any((value) => value) ?? false;

    notifyListeners();
  }

  Future<void> clearMenShoes() async {
    isLoadingMenShoes = {
      for (var size in womenShoesSizesList) size.trim().toString(): false,
    };
    haveCheckMenShoes = false;
    notifyListeners();
  }

  //----------------woman shoes------------------

  Future<void> changeLoadingWomenShoes(String type, bool check) async {
    isLoadingWomenShoes?[type] = check;
    haveCheckWomenShoes =
        isLoadingWomenShoes?.values.any((value) => value) ?? false;

    notifyListeners();
  }

  Future<void> clearWomenShoes() async {
    isLoadingWomenShoes = {
      for (var size in womenShoesSizesList) size.trim().toString(): false,
    };
    haveCheckWomenShoes = false;
    notifyListeners();
  }

  //----------------man shoes------------------

  Future<void> changeLoadingKidsShoes(String type, bool check) async {
    isLoadingKidsShoes?[type] = check;
    haveCheckKidsShoes =
        isLoadingKidsShoes?.values.any((value) => value) ?? false;

    notifyListeners();
  }

  Future<void> clearKidsShoes() async {
    isLoadingKidsShoes = {
      for (var size in kidsShoesSizesList) size.trim().toString(): false,
    };
    haveCheckKidsShoes = false;
    notifyListeners();
  }

  //----------------under ware clothes------------------

  Future<void> changeLoadingUnderWareClothes(String type, bool check) async {
    isLoadingUnderWareTypes?[type] = check;
    haveCheckUnderWareClothes =
        isLoadingUnderWareTypes?.values.any((value) => value) ?? false;

    notifyListeners();
  }

  Future<void> clearUnderWareClothes() async {
    isLoadingUnderWareTypes = {
      for (var size in underwearSizes) size.trim().toString(): false,
    };
    haveCheckUnderWareClothes = false;
    notifyListeners();
  }

  //----------------women plus clothes------------------

  Future<void> changeLoadingWomenPlusClothes(String type, bool check) async {
    isLoadingWomenPlusClothesTypes?[type] = check;
    haveCheckWomenPlusClothes =
        isLoadingWomenPlusClothesTypes?.values.any((value) => value) ?? false;

    notifyListeners();
  }

  Future<void> clearWomenPlusClothes() async {
    isLoadingWomenPlusClothesTypes = {
      for (var entry in womenPlusSizesList.entries) entry.key: false,
    };
    haveCheckWomenPlusClothes = false;
    notifyListeners();
  }

  //-------------------3(shoes)------------------

  Map<int, bool>? isLoadingShoesTypes = {
    1: false, // woman
    2: false, // men
    3: false // baby
  };

  Future<void> changeLoadingShoes(int type, bool check) async {
    isLoadingShoesTypes?[type] = check;
    haveCheckShoes = isLoadingShoesTypes?.values.any((value) => value) ?? false;

    notifyListeners();
  }

  Future<void> clearShoes() async {
    isLoadingShoesTypes = {
      1: false, // woman
      2: false, // men
      3: false // baby
    };
    haveCheckShoes = false;
    notifyListeners();
  }

//--------------------2(perfume)----------------
  Map<int, bool>? isLoadingPerfumeType = {
    1: false, // men
    2: false, // woman
  };

  Future<void> changeLoadingPerfume(int type, bool check) async {
    isLoadingPerfumeType?[type] = check;
    haveCheck = isLoadingPerfumeType?.values.any((value) => value) ?? false;

    notifyListeners();
  }

  Future<void> clearPerfume() async {
    isLoadingPerfumeType = {
      1: false, // men
      2: false, // woman
    };
    haveCheck = false;
    notifyListeners();
  }

//---------------------------------------------------------------------------------------------------------------------

  Future<void> getPerfume() async {
    final currentVersion = _requestVersion;
    final String tag = subSelectedSingleSubCategoryDepartment.name;
    List<Item> short = [];

    if (haveMoreData) {
      showShimmer = true;
      short = await api.apiPerfumeItem(
          sizes: "",
          numSort: numSort,
          page: numPageSelectDepartment,
          category: selectSubCategorySpecific,
          selectTag: (tag.trim().toString() != "جميع الماركات") ? tag : "",
          sub: selectSubCategorySpecific.subCategory ?? "",
          season: fetchController.season,
          requestVersion: currentVersion);

      if (currentVersion != _requestVersion) {
        return;
      }
    }

    if (short.isEmpty) {
      haveMoreData = false;
      if (numPageSelectDepartment == 1) {
        showShimmer = false;
      }
      notifyListeners();
      return;
    }

    itemsData.addAll(short);
    itemsData = itemsData.toSet().toList();
    if (itemsData.isNotEmpty) {
      var tempItems = List.from(itemsData);

      for (var item in tempItems) {
        final id = item.id.toString();
        bool check =
            await favouriteController.checkFavouriteItem(productId: item.id);

        positionScroll[id] = 0;
        isFavourite[id] = check;
      }

      numPageSelectDepartment++;
    } else {
      showShimmer = false;
    }

    notifyListeners();
  }

  Future<void> getData(
      {required CategoryModel category,
      String sizes = "",
      required bool isFirst}) async {
    printLog("start");
    final currentVersion = _requestVersion;
    List<Item> short = [];
    String sub = "";
    if (isFirst) {
      sub = category.subCategory.toString();
    } else {
      for (var i in listSelectedMultiSubCategoryDepartment) {
        sub += "${i.subCategory},";
      }
    }
    printLog("haveMoreData: $haveMoreData");

    if (haveMoreData) {
      showShimmer = true;

      short = await api.apiPerfumeItem(
          sizes: sizes,
          numSort: numSort,
          page: numPageSelectDepartment,
          category: (subCategoriesDepartment.isEmpty)
              ? category
              : listSelectedMultiSubCategoryDepartment.last,
          selectTag: "",
          sub: sub,
          season: fetchController.season,
          requestVersion: currentVersion);

      if (currentVersion != _requestVersion) {
        return;
      }
    }

    if (short.isEmpty) {
      haveMoreData = false;
      if (numPageSelectDepartment == 1) {
        showShimmer = false;
      }
      notifyListeners();
      return;
    }

    itemsData.addAll(short);
    itemsData = itemsData.toSet().toList();
    printLog("itemsData: ${itemsData.length}");
    if (itemsData.isNotEmpty) {
      var tempItems = List.from(itemsData);

      for (var item in tempItems) {
        final id = item.id.toString();
        bool check =
            await favouriteController.checkFavouriteItem(productId: item.id);

        positionScroll[id] = 0;
        isFavourite[id] = check;
      }

      numPageSelectDepartment++;
    } else {
      showShimmer = false;
    }

    notifyListeners();
  }

//------------------Selection sub departments-------------------------------------
  Future<void> setSingleSubDepartments(CategoryModel item) async {
    if (subSelectedSingleSubCategoryDepartment == item) {
      // Reset itemCategory if the same category is selected again
      subSelectedSingleSubCategoryDepartment = CategoryModel(
        name: "",
        image: "",
        mainCategory: "",
        icon: "",
        subCategory: "",
      );

      // printLog(subCategoriesDepartment.first.name);
      //
      // subSelectedSingleSubCategoryDepartment = subCategoriesDepartment.first;
    } else {
      subSelectedSingleSubCategoryDepartment = item;
    }

    notifyListeners(); // Notify UI of changes
  }

  Future<void> setMultiSelectSubDepartments(List<CategoryModel> items) async {
    //items was selected
    listSelectedMultiSubCategoryDepartment.clear();

    if (items.length == 1 && items[0].name.contains("جميع") == true) {
      listSelectedMultiSubCategoryDepartment.clear();
      listSelectedMultiSubCategoryDepartment.addAll(items);
    } else if (items.length == 1) {
      listSelectedMultiSubCategoryDepartment.clear();
      listSelectedMultiSubCategoryDepartment.addAll(items);
    } else if (items.length > 1) {
      if (items.last.name.contains("جميع")) {
        listSelectedMultiSubCategoryDepartment.clear();
        listSelectedMultiSubCategoryDepartment.add(items.last);
      } else {
        printLog("Multiple items selected");

        // Add all items first
        listSelectedMultiSubCategoryDepartment.addAll(items);

        // Check if any item contains "جميع"
        CategoryModel? itemWithJame3 =
            listSelectedMultiSubCategoryDepartment.firstWhere(
          (element) => element.name.contains("جميع"),
          orElse: () => CategoryModel(
              name: "", subCategory: "", image: "", mainCategory: "", icon: ""),
        );

        if (itemWithJame3.name != "") {
          // Clear and retain only the item containing "جميع"
          // listSelectedSubDepartment.clear();
          listSelectedMultiSubCategoryDepartment.remove(itemWithJame3);
        }
      }
    } else {}
    if (listSelectedMultiSubCategoryDepartment.isEmpty) {
      listSelectedMultiSubCategoryDepartment.clear();
      listSelectedMultiSubCategoryDepartment.add(subCategoriesDepartment.first);
    }

    notifyListeners(); // Notify UI of changes
  }

  Future<void> setSubCategorySpecificFirstMulti(CategoryModel category) async {
    listSelectedMultiSubCategoryDepartment =
        [category].toList(); // Ensure a new list
    printLog("${listSelectedMultiSubCategoryDepartment[0].name} selected");
    notifyListeners(); // Notify UI of change
  }

  //the design before---------------------------------------------------------------------------
  Future<void> changeIndex(int index) async {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> tapSelectCategory({required CategoryModel categoryModel}) async {
    if (categoryModel.id == 1.toString()) {
      NavigatorApp.pushName(
        AppRoutes.women,
        arguments: {
          'category': categoryModel,
        },
      );
    } else if (categoryModel.id == 2.toString()) {
      NavigatorApp.pushName(
        AppRoutes.men,
        arguments: {
          'category': categoryModel,
        },
      );
    } else if (categoryModel.id == 3.toString()) {
      NavigatorApp.pushName(
        AppRoutes.kidsAll,
        arguments: {
          'category': categoryModel,
        },
      );
    } else if (categoryModel.id == 4.toString()) {
      NavigatorApp.pushName(
        AppRoutes.womenPlus,
        arguments: {
          'category': categoryModel,
        },
      );
    } else if (categoryModel.id == 5.toString()) {
      await clearMulti();

      var category = CategoryModel.fromJsonListCategory(bags);

      await setSubCategoryDepartments(bags, false);

      await setSubCategorySpecific(category[0]);
      NavigatorApp.pushName(
        AppRoutes.pageDepartment,
        arguments: {
          'title': categoryModel.name,
          'category': categoryModel,
          'showIconSizes': false,
          'sizes': '',
          'scrollController': scrollMultiItems,
        },
      );
    } else if (categoryModel.id == 6.toString()) {
      NavigatorApp.pushName(
        AppRoutes.shoes,
        arguments: {
          'category': categoryModel,
        },
      );
    }
    //------------------------------------------------------- (9,10,11,15- 32 )   -----------------------------------------
    else if (categoryModel.id == 9.toString()) {
      NavigatorApp.pushName(AppRoutes.underware);
    } else if (categoryModel.id == 10.toString()) {
      await clearMulti();

      var category = CategoryModel.fromJsonListCategory(womenAndBaby);

      await setSubCategoryDepartments(womenAndBaby, false);

      await setSubCategorySpecific(category[0]);
      NavigatorApp.pushName(
        AppRoutes.pageDepartment,
        arguments: {
          'title': categoryModel.name,
          'showIconSizes': false,
          'category': categoryModel,
          'sizes': '',
          'scrollController': scrollMultiItems,
        },
      );
    } else if (categoryModel.id == 11.toString()) {
      NavigatorApp.pushName(AppRoutes.perfume);
    } else if (categoryModel.id == 15.toString()) {
      await clearMulti();

      var category = CategoryModel.fromJsonListCategory(home);

      await setSubCategoryDepartments(home, false);

      await setSubCategorySpecific(category[0]);
      NavigatorApp.pushName(
        AppRoutes.pageDepartment,
        arguments: {
          'title': categoryModel.name,
          'category': categoryModel,
          'showIconSizes': false,
          'sizes': '',
          'scrollController': scrollMultiItems,
        },
      );
    } else if (categoryModel.id == 16.toString()) {
      await clearMulti();

      var category = CategoryModel.fromJsonListCategory(apparel);

      await setSubCategoryDepartments(apparel, false);

      await setSubCategorySpecific(category[0]);
      NavigatorApp.pushName(
        AppRoutes.pageDepartment,
        arguments: {
          'title': categoryModel.name,
          'category': categoryModel,
          'showIconSizes': false,
          'sizes': '',
          'scrollController': scrollMultiItems,
        },
      );
    } else if (categoryModel.id == 17.toString()) {
      await clearMulti();

      var category = CategoryModel.fromJsonListCategory(beauty);

      await setSubCategoryDepartments(beauty, false);

      await setSubCategorySpecific(category[0]);
      NavigatorApp.pushName(
        AppRoutes.pageDepartment,
        arguments: {
          'title': categoryModel.name,
          'category': categoryModel,
          'sizes': '',
          'showIconSizes': false,
          'scrollController': scrollMultiItems,
        },
      );
    } else if (categoryModel.id == 18.toString()) {
      await clearMulti();

      await setSubCategoryDepartments([], false);

      await setSubCategorySpecific(categoryModel);
      NavigatorApp.pushName(
        AppRoutes.pageDepartment,
        arguments: {
          'title': categoryModel.name,
          'category': categoryModel,
          'showIconSizes': false,
          'sizes': '',
          'scrollController': scrollMultiItems,
        },
      );
    } else if (categoryModel.id == 19.toString()) {
      await clearMulti();

      await setSubCategoryDepartments([], false);

      await setSubCategorySpecific(categoryModel);
      NavigatorApp.pushName(
        AppRoutes.pageDepartment,
        arguments: {
          'title': categoryModel.name,
          'showIconSizes': false,
          'category': categoryModel,
          'sizes': '',
          'scrollController': scrollMultiItems,
        },
      );
    } else if (categoryModel.id == 20.toString()) {
      await clearMulti();

      await setSubCategoryDepartments([], false);

      await setSubCategorySpecific(categoryModel);
      NavigatorApp.pushName(
        AppRoutes.pageDepartment,
        arguments: {
          'title': categoryModel.name,
          'showIconSizes': false,
          'category': categoryModel,
          'sizes': '',
          'scrollController': scrollMultiItems,
        },
      );
    } else if (categoryModel.id == 21.toString()) {
      await clearMulti();

      await setSubCategoryDepartments([], false);

      await setSubCategorySpecific(categoryModel);
      NavigatorApp.pushName(
        AppRoutes.pageDepartment,
        arguments: {
          'title': categoryModel.name,
          'category': categoryModel,
          'showIconSizes': false,
          'sizes': '',
          'scrollController': scrollMultiItems,
        },
      );
    } else if (categoryModel.id == 22.toString()) {
      await clearMulti();

      var category = CategoryModel.fromJsonListCategory(electronics);

      await setSubCategoryDepartments(electronics, false);

      await setSubCategorySpecific(category[0]);
      NavigatorApp.pushName(
        AppRoutes.pageDepartment,
        arguments: {
          'title': categoryModel.name,
          'showIconSizes': false,
          'category': categoryModel,
          'sizes': '',
          'scrollController': scrollMultiItems,
        },
      );
    } else if (categoryModel.id == 23.toString()) {
      await clearMulti();

      var category = CategoryModel.fromJsonListCategory(sports);

      await setSubCategoryDepartments(sports, false);

      await setSubCategorySpecific(category[0]);
      NavigatorApp.pushName(
        AppRoutes.pageDepartment,
        arguments: {
          'title': categoryModel.name,
          'category': categoryModel,
          'showIconSizes': false,
          'sizes': '',
          'scrollController': scrollMultiItems,
        },
      );
    }
  }
}
