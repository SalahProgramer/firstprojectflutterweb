import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:fawri_app_refactor/salah/controllers/fetch_controller.dart';
import 'package:fawri_app_refactor/salah/localDataBase/hive_data/data_sizes.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constant-categories/constant_data_convert.dart';
import 'favourite_controller.dart';
import '../models/constants/constant_model.dart';
import '../models/items/item_model.dart';
import '../utilities/global/app_global.dart';
import 'APIS/api_main_product_controller.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';

class SearchItemController extends ChangeNotifier {
  TextEditingController nullSearch = TextEditingController();
  TextEditingController idAndSkuSearch = TextEditingController();
  TextEditingController minPrice = TextEditingController();
  TextEditingController maxPrice = TextEditingController();
  bool haveMoreData = true;
  bool showSpinKitMoreData = false;

  List<CategoryModel> categoriesSearch = [];
  List<CategoryModel> categories = [];
  List<CategoryModel> subCategoriesSearch = [];
  List<String> sizes = [];
  List<String> sizesPopUpShoes = [];
  List<CategoryModel> categoriesTags = [];
  bool isLoading = false;
  bool isLoadingPopUpShoes = false;
  bool isLoadingSearch = false;
  String searchText = "";
  RangeValues rangePrice = const RangeValues(0, 1000);
  ScrollController scrollSearchItems = ScrollController();
  ScrollController scrollFilterItems = ScrollController();
  ApiMainProductController apiMainProductController =
      NavigatorApp.context.read<ApiMainProductController>();
  int numPageItemSearch = 1;
  List<Item> subCategories = [];
  List<Item> popUpShoesData = [];
  ApiMainProductController apiMain =
      NavigatorApp.context.read<ApiMainProductController>();
  FavouriteController favouriteController =
      NavigatorApp.context.read<FavouriteController>();

  FetchController fetchController =
      NavigatorApp.context.read<FetchController>();
  Map<String, int> positionScroll = {};
  Map<String, bool> isFavourite = {};
  CategoryModel itemSearch = CategoryModel(
      name: "", image: "", mainCategory: "", icon: "", subCategory: "");

  late SingleSelectController<CategoryModel> selectController =
      SingleSelectController<CategoryModel>(null);

  CategoryModel itemCategory = CategoryModel(
      name: "", image: "", mainCategory: "", icon: "", subCategory: "");
  CategoryModel itemSubCategory = CategoryModel(
      name: "", image: "", mainCategory: "", icon: "", subCategory: "");
  CategoryModel selectTag = CategoryModel(
      name: "", image: "", mainCategory: "", icon: "", subCategory: "");
  List<CategoryModel> listSelectedSubMain = [];
  List<String> listSelectedSizes = [];
  List<String> listSelectedSizesPopUpShoes = [];

  Future<void> changeSpinHaveMoreData(bool check) async {
    showSpinKitMoreData = check;
    notifyListeners();
  }

  Future<void> getCategories() async {
    if (categoriesSearch.isEmpty) {
      categoriesSearch = [];
      categories = [];

      categoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(basicCategories));
      categoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(secondaryCategories));

      categories.addAll(CategoryModel.fromJsonListCategory(basicCategories));
      categories
          .addAll(CategoryModel.fromJsonListCategory(secondaryCategories));

      selectController =
          SingleSelectController<CategoryModel>(categoriesSearch[0]);

      // List<CategoryModel> addTags = await apiMainProductController.apiGetTag();
      List<CategoryModel> addTags = CategoryModel.fromJsonListTags(tags);
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(men.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(women.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(womenPlus.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(allkids.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(girls.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(boys.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(womenAndBaby.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(allShoes.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(kidsShoes.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(menShoes.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(womenShoes.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(underWare.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(home.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(apparel.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(beauty.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(electronics.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(bags.sublist(1)));
      subCategoriesSearch
          .addAll(CategoryModel.fromJsonListCategory(sports.sublist(1)));
      // subCategoriesSearch
      //     .addAll(CategoryModel.fromJsonListCategory(perfume.sublist(1)));

      categoriesTags = addTags;
      categoriesSearch.addAll(subCategoriesSearch);
      categoriesSearch.addAll(addTags);
      categoriesSearch = categoriesSearch.toSet().toList();
      subCategoriesSearch = [];
    } else {}

    notifyListeners();
  }

  Future<void> setSkuAndIdSearch(String value) async {
    idAndSkuSearch.text = value;
    notifyListeners();
  }

  Future<void> setTextSearch(String text) async {
    searchText = text;
    notifyListeners();
  }

  Future<void> changeLoading(bool check) async {
    isLoading = check;
    notifyListeners();
  }

  Future<void> changeLoadingSearch(bool check) async {
    isLoadingSearch = check;
    notifyListeners();
  }

  Future<void> changeLoadingPopUpShoes(bool check) async {
    isLoadingPopUpShoes = check;
    notifyListeners();
  }

  Future<void> changePrice(RangeValues prices) async {
    rangePrice = prices;
    notifyListeners();
  }

  Future<void> clear() async {
    subCategories.clear();
    numPageItemSearch = 1;

    haveMoreData = true;
    showSpinKitMoreData = false;

    notifyListeners();
  }

  Future<void> clearItemSearch() async {
    haveMoreData = true;
    showSpinKitMoreData = false;

    itemSearch = CategoryModel(
        name: "", image: "", mainCategory: "", icon: "", subCategory: "");
    notifyListeners();
  }

  Future<void> setItemCategory(CategoryModel item) async {
    // Clear sizes, subcategories, and other lists at the start
    listSelectedSubMain.clear();
    listSelectedSizes.clear();
    subCategoriesSearch.clear();
    sizes.clear(); // Clear sizes initially

    if (itemCategory == item) {
      // Reset itemCategory if the same category is selected again
      itemCategory = CategoryModel(
        name: "",
        image: "",
        mainCategory: "",
        icon: "",
        subCategory: "",
      );
    } else {
      // Update itemCategory to the new selection
      itemCategory = item;

      // Set sizes and subcategories based on the main category and name
      switch (item.mainCategory) {
        case "Women Apparel":
          if (item.name == "ملابس نسائية") {
            subCategoriesSearch = CategoryModel.fromJsonListCategory(women);
            sizes = womenSizesList.values.toList(); // Create a copy of the list
          } else if (item.name == "مقاسات كبيرة") {
            subCategoriesSearch = CategoryModel.fromJsonListCategory(womenPlus);
            sizes =
                womenPlusSizesList.values.toList(); // Create a copy of the list
          }
          break;

        case "Men Apparel, Men,Sports %26 Outdoor, Sports Outdoor":
          subCategoriesSearch = CategoryModel.fromJsonListCategory(men);
          sizes = menSizesList.values.toList(); // Create a copy of the list
          break;

        case "Kids":
          if (item.name == "ملابس أطفال") {
            subCategoriesSearch = CategoryModel.fromJsonListCategory(allkids);
          } else if (item.name == "ملابس أولاد") {
            subCategoriesSearch = CategoryModel.fromJsonListCategory(boys);
            sizes = List.from(kidsBoysSizesList); // Create a copy of the list
          } else if (item.name == "ملابس بنات") {
            subCategoriesSearch = CategoryModel.fromJsonListCategory(girls);
            sizes = List.from(girlsKidsSizesList); // Create a copy of the list
          } else if (item.name == "أحذية أطفال") {
            subCategoriesSearch = CategoryModel.fromJsonListCategory(kidsShoes);
            sizes = List.from(kidsShoesSizesList); // Create a copy of the list
          }

          break;

        case "Women Apparel, Baby":
          subCategoriesSearch =
              CategoryModel.fromJsonListCategory(womenAndBaby);
          break;

        case "Shoes,Kids":
          subCategoriesSearch = CategoryModel.fromJsonListCategory(allShoes);

          break;
        case "Shoes":
          if (item.name == "أحذية ستاتية") {
            subCategoriesSearch =
                CategoryModel.fromJsonListCategory(womenShoes);
            sizes = List.from(womenShoesSizesList); // Create a copy of the list
          } else if (item.name == "أحذية رجالية") {
            subCategoriesSearch = CategoryModel.fromJsonListCategory(menShoes);
            sizes = List.from(menShoesSizesList); // Create a copy of the list
          } else if (item.name == "أحذية رجالية") {
            subCategoriesSearch = CategoryModel.fromJsonListCategory(menShoes);
            sizes = List.from(menShoesSizesList); // Create a copy of the list
          }

          break;

        case "Underwear %26 Sleepwear,Underwear Sleepwear":
          subCategoriesSearch = CategoryModel.fromJsonListCategory(underWare);
          sizes = List.from(underwearSizes); // Create a copy of the list

          break;

        case "Home %26 Living, Home Living, Home Textile,Tools %26 Home Improvement":
          subCategoriesSearch = CategoryModel.fromJsonListCategory(home);
          break;

        case "Jewelry %26 Watches, Jewelry  Watches":
          subCategoriesSearch = [];
          break;

        case "Apparel Accessories":
          subCategoriesSearch = CategoryModel.fromJsonListCategory(apparel);
          break;

        case "Beauty %26 Health, Jewelry %26 Watches":
          subCategoriesSearch = CategoryModel.fromJsonListCategory(beauty);
          break;

        case "Electronics":
          subCategoriesSearch = CategoryModel.fromJsonListCategory(electronics);
          break;

        case "Bags %26 Luggage, Bags %26 Luggage":
          subCategoriesSearch = CategoryModel.fromJsonListCategory(bags);
          break;

        case "Sports %26 Outdoor, Sports  Outdoor":
          subCategoriesSearch = CategoryModel.fromJsonListCategory(sports);
          break;

        // case "perfume":
        //   if (item.name == "العطور") {
        //     subCategoriesSearch = CategoryModel.fromJsonListCategory(perfume);
        //   }
        //   break;

        default:
          // For cases where sizes are not explicitly set
          sizes = [];
          break;
      }
    }

    printLog("end");
    printLog("Sizes length: ${sizes.length}");

    notifyListeners(); // Notify listeners of changes
  }

  Future<void> setItemSearch(CategoryModel item) async {
    itemSearch = item;
    notifyListeners();
  }

  Future<void> setListSubItemSearch(List<CategoryModel> items) async {
    listSelectedSubMain.clear();
    listSelectedSubMain.addAll(items);
    for (var i in items) {
      if (i.name.trim().toString() == "ملابس نسائية داخلية") {
        // Clear sizes, subcategories, and other lists at the start

        listSelectedSubMain.clear();
        listSelectedSizes.clear();
        subCategoriesSearch.clear();

        sizes.clear(); // Clear sizes initially
        subCategoriesSearch = CategoryModel.fromJsonListCategory(underWare);
        itemCategory = CategoryModel(
          name: "ملابس نسائية داخلية",
          image: Assets.images.undercat.path,
          mainCategory: "Underwear %26 Sleepwear,Underwear Sleepwear",
          subCategory: "",
        );
        sizes = List.from(underwearSizes); // Create a copy of the list
      } else if (i.name.trim().toString() == "اكسسوارات نسائية") {
        // Clear sizes, subcategories, and other lists at the start

        listSelectedSubMain.clear();
        listSelectedSizes.clear();
        subCategoriesSearch.clear();

        sizes.clear(); // Clear sizes initially
        subCategoriesSearch = CategoryModel.fromJsonListCategory(apparel);
        itemCategory = CategoryModel(
          name: "اكسسوارات نسائية",
          image: Assets.images.aLanding.path,
          mainCategory: "Apparel Accessories",
          subCategory: "",
        );
      } else if (i.name.trim().toString() == "الموضة والجمال نسائية") {
        // Clear sizes, subcategories, and other lists at the start

        listSelectedSubMain.clear();
        listSelectedSizes.clear();
        subCategoriesSearch.clear();

        sizes.clear(); // Clear sizes initially
        subCategoriesSearch = CategoryModel.fromJsonListCategory(beauty);
        itemCategory = CategoryModel(
          name: "الموضة والجمال نسائية",
          image: Assets.images.beautycat.path,
          mainCategory: "Beauty %26 Health, Jewelry %26 Watches",
          subCategory: "",
        );
      } else if (i.name.trim().toString() == "أحذية نسائية") {
        // Clear sizes, subcategories, and other lists at the start

        listSelectedSubMain.clear();
        listSelectedSizes.clear();
        subCategoriesSearch.clear();

        sizes.clear(); // Clear sizes initially
        subCategoriesSearch = CategoryModel.fromJsonListCategory(womenShoes);
        itemCategory = CategoryModel(
          name: "أحذية نسائية",
          image: Assets.images.beautycat.path,
          mainCategory: "Shoes",
          subCategory:
              "Women Shoes,Women Boots, Women Fashion Boots, Women Outdoor Shoes,Women Pumps,Wide Fit Pumps,Women Flats,Women Loafers Shoes,Women Slippers, Women Clogs, Women Sneakers, Women Athletic Shoes, Women Slippers, Women Clogs, Women Wedges %26 Flatform, Women Wedges Flatform",
        );
        sizes = List.from(womenShoesSizesList); // Create a copy of the list
      } else if (i.name.trim().toString() == "أحذية رجالية") {
        // Clear sizes, subcategories, and other lists at the start

        listSelectedSubMain.clear();
        listSelectedSizes.clear();
        subCategoriesSearch.clear();

        sizes.clear(); // Clear sizes initially
        subCategoriesSearch = CategoryModel.fromJsonListCategory(menShoes);
        itemCategory = CategoryModel(
          name: "أحذية رجالية",
          image: Assets.images.mencat.path,
          mainCategory: "Shoes",
          subCategory:
              "Men Shoes,Men Loafers,Men Boots, Men Outdoor Shoes,Dress Shoes, Men Loafers, Men Canvas Shoes,Men Sneakers, Men Athletic Shoes,Men Sandals, Men Clogs, Men Flip Flops %26 Slides, Men Flip Flops  Slides,Men Clogs, Men Slippers, Men Work %26 Safety Shoes, Men Work Safety Shoes, Men Outdoor Shoes",
        );
        sizes = List.from(menShoesSizesList); // Create a copy of the list
      }
    }

    notifyListeners();
  }

  Future<void> setListSizesSearch(List<String> items) async {
    listSelectedSizes.clear();
    listSelectedSizes.addAll(items);

    notifyListeners();
  }

//pop us shoes----------------------------------------------------------------------------------
  Future<void> setListSizesPopUpShoes(String items) async {
    // listSelectedSizesPopUpShoes.clear();

    if (listSelectedSizesPopUpShoes.contains(items)) {
      listSelectedSizesPopUpShoes.remove(items);
    } else {
      listSelectedSizesPopUpShoes.add(items);
    }

    listSelectedSizesPopUpShoes = listSelectedSizesPopUpShoes.toSet().toList();
    notifyListeners();
  }

  Future<void> setSizesPopUpShoes({required bool isMale}) async {
    sizesPopUpShoes.clear();
    listSelectedSizesPopUpShoes.clear();
    if (isMale) {
      sizesPopUpShoes.addAll(menShoesSizesList);
    } else {
      sizesPopUpShoes.addAll(womenShoesSizesList);
    }

    notifyListeners();
  }

  Future<void> getShoesPopUp({required bool isMale}) async {
    popUpShoesData.clear();
    List<Item> short = [];
    if (isMale) {
      short = await apiMain.apiPopUpShoesItem(
          1, "Men Shoes", fetchController.season);
    } else {
      short = await apiMain.apiPopUpShoesItem(
          1, "Women Shoes", fetchController.season);
    }

    popUpShoesData.addAll(short);
    popUpShoesData = popUpShoesData.toSet().toList();
    if (popUpShoesData.isNotEmpty) {
      // var tempItems = List.from(popUpShoesData);
    }
  }

  //--------------------------------------------------------------------------------------------

  Future<void> removeSubItemFilter(item) async {
    printLog("fffffffffffffffffffffffffffffffffffffffffffffff");
    listSelectedSubMain.remove(item);
    if (listSelectedSubMain.isEmpty) {
      sizes.clear();
    }

    notifyListeners();
  }

  Future<void> removeSizesFilter(item) async {
    printLog("fffffffffffffffffffffffffffffffffffffffffffffff");
    listSelectedSizes.remove(item);

    notifyListeners();
  }

  Future<void> removeTagFilter() async {
    printLog("fffffffffffffffffffffffffffffffffffffffffffffff");
    selectTag = CategoryModel(
        name: "", image: "", mainCategory: "", icon: "", subCategory: "");

    notifyListeners();
  }

  Future<void> setTagSearch(CategoryModel item) async {
    if (selectTag == (item)) {
      selectTag = CategoryModel(
          name: "", image: "", mainCategory: "", icon: "", subCategory: "");
    } else {
      selectTag = (item);
    }
    notifyListeners();
  }

  Future<void> getSearch() async {
    List<Item> short = [];

    if (haveMoreData) {
      short = await apiMain.apiSearchItem(
          itemSearch, numPageItemSearch, fetchController.season);
    }

    if (short.isEmpty) {
      haveMoreData = false;
      notifyListeners();
      return;
    } else {
      subCategories.addAll(short);
      subCategories = subCategories.toSet().toList();
      if (subCategories.isNotEmpty) {
        var tempItems = List.from(subCategories);

        for (var item in tempItems) {
          final id = item.id.toString();
          bool check =
              await favouriteController.checkFavouriteItem(productId: item.id);

          positionScroll[id] = 0;
          isFavourite[id] = check;
        }
        numPageItemSearch++;
        notifyListeners();
      }
    }
  }

  Future<void> getFilter() async {
    String sub = "";
    String size = "";
    List<Item> short = [];

    if (listSelectedSubMain.isNotEmpty) {
      int index = 0;
      for (var i in listSelectedSubMain) {
        if (index == listSelectedSubMain.length - 1) {
          sub = "$sub${i.subCategory?.trim().toString()}";
        } else {
          sub = "$sub${i.subCategory?.trim().toString()},";
        }
        index++;
      }
    }

    if (listSelectedSizes.isNotEmpty) {
      int index = 0;
      for (var i in listSelectedSizes) {
        if (index == listSelectedSizes.length - 1) {
          size = "$size${i.trim().toString()}";
        } else {
          size = "$size${i.trim().toString()},";
        }
        index++;
      }
    }
    //
    size = processSizesStringToString(size);
    printLog(size);

    if (itemCategory.mainCategory == "Women Apparel" && size != "") {
      if (size.contains("0XL") || size.contains("1XL")) {
        size = "$size,XL";
      }
      if (size.contains("2XL")) {
        size = "$size,XXL";
      }
      if (size.contains("3XL")) {
        size = "$size,XXXL";
      }
      if (size.contains("XL")) {
        size = "$size,0XL,1XL";
      }
      if (size.contains("XXL")) {
        size = "$size,2XL";
      }
      if (size.contains("XXXL")) {
        size = "$size,3XL";
      }
    }
    printLog(size);

    if (haveMoreData) {
      short = await apiMain.apiFilterItem(
          itemCategory,
          sub,
          size,
          selectTag,
          rangePrice.start.toString(),
          rangePrice.end.toString(),
          numPageItemSearch,
          fetchController.season);
    }

    if (short.isEmpty) {
      haveMoreData = false;
      notifyListeners();
      return;
    } else {
      subCategories.addAll(short);
      subCategories = subCategories.toSet().toList();
      if (subCategories.isNotEmpty) {
        var tempItems = List.from(subCategories);

        for (var item in tempItems) {
          final id = item.id.toString();
          bool check =
              await favouriteController.checkFavouriteItem(productId: item.id);

          positionScroll[id] = 0;
          isFavourite[id] = check;
        }
        numPageItemSearch++;
        notifyListeners();
      }
    }
  }
}
