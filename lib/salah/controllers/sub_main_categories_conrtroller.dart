import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../services/remote_config_firebase/remote_config_firebase.dart';
import 'favourite_controller.dart';
import '../models/items/item_model.dart';
import 'APIS/api_main_product_controller.dart';
import 'APIS/api_page_main_controller.dart';

class SubMainCategoriesController extends ChangeNotifier {
  int totalItems = 0;
  bool haveMoreData = true;
  bool showSpinKitMoreData = false;

  ApiPageMainController api =
      NavigatorApp.context.read<ApiPageMainController>();
  PageMainScreenController pageMainScreenController =
      NavigatorApp.context.read<PageMainScreenController>();
  ApiMainProductController apiMain =
      NavigatorApp.context.read<ApiMainProductController>();

  List<Item> subCategories = [];
  ScrollController scrollBestSellersItems = ScrollController();
  int numPageSubCategories = 1;
  Map<String, bool>? isLoadingBestSellersProducts = {};
  Map<int, int> sectionsSubMainNumPage = {};

  ScrollController scrollProductsItems = ScrollController();
  ScrollController scrollDynamicItems = ScrollController();
  ScrollController scrollSlidersItems = ScrollController();
  ScrollController scrollHomeItems = ScrollController();
  ScrollController scrollFeaturesItems = ScrollController();
  ScrollController scrollSectionsItems = ScrollController();

  Map<String, int> positionScroll = {};
  Map<String, bool> isFavourite = {};
  FavouriteController favouriteController =
      NavigatorApp.context.read<FavouriteController>();
  Future<void> changeSpinHaveMoreData(bool check) async {
    showSpinKitMoreData = check;
    notifyListeners();
  }

  Future<void> getBestSallarSubMain() async {
    List<Item> short = [];

    if (haveMoreData) {
      short = await api.apiBestSellersProducts(numPageSubCategories);
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

          isLoadingBestSellersProducts?[id] = false;
          positionScroll[id] = 0;
          isFavourite[id] = check;
        }
        numPageSubCategories++;
        notifyListeners();
      }
    }
  }

  Future<void> getFlashSalesSubMain() async {
    List<Item> short = [];

    if (haveMoreData) {
      short =
          await apiMain.apiGetTagProducts("flash_sales", numPageSubCategories);
    }
    if (short.isEmpty) {
      haveMoreData = false;
      return;
    }
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
      notifyListeners();
    }

    numPageSubCategories++;
  }

  Future<void> getBlackFridaySubMain() async {
    List<Item> short = [];

    if (haveMoreData) {
      short =
          await apiMain.apiGetTagProducts("Black Friday", numPageSubCategories);
    }

    if (short.isEmpty) {
      haveMoreData = false;
    }
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
      notifyListeners();
    }

    numPageSubCategories++;
  }

  Future<void> getDynamicSubMain(String? tag) async {
    List<Item> short = [];

    if (haveMoreData) {
      short = await apiMain.apiGetTagProducts(tag!, numPageSubCategories);
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
        numPageSubCategories++;
        notifyListeners();
      }
    }
  }

  Future<void> getFeaturesSubMain() async {
    List<Item> short = [];
    var featuresUrl3 = await FirebaseRemoteConfigClass().getCategoryIDKey3();

    if (haveMoreData) {
      short = await api.apiFeatureProducts(featuresUrl3, numPageSubCategories);
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
        numPageSubCategories++;
        notifyListeners();
      }
    }
  }

  Future<void> setTotalItems(int total) async {
    totalItems = total;
    notifyListeners();
  }

  Future<void> getSectionSubMain(int index) async {
    List<Item> short = [];

    if (haveMoreData) {
      short = await api.apiAllSectionsSubMain(
          pageMainScreenController.sectionsUrl[index] ?? "",
          numPageSubCategories);
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
        numPageSubCategories++;

        notifyListeners();
      }
    }
  }

  Future<void> get1111SubMain() async {
    List<Item> short = [];

    if (haveMoreData) {
      short = await apiMain.apiGetTagProducts("11.11", numPageSubCategories);
    }

    if (short.isEmpty) {
      haveMoreData = false;
    }

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
      notifyListeners();
    }

    numPageSubCategories++;
  }

  Future<void> getHomeSubMain() async {
    List<Item> short = [];

    if (haveMoreData) {
      short = await api.apiHomeData(numPageSubCategories);
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
        numPageSubCategories++;
        notifyListeners();
      }
    }
  }

  Future<void> getDiscountSubMain() async {
    List<Item> short = [];

    if (haveMoreData) {
      short = await apiMain.apiGetTagProducts("discount", numPageSubCategories);
    }

    if (short.isEmpty) {
      haveMoreData = false;
    }

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
      notifyListeners();
    }

    numPageSubCategories++;
  }

  Future<void> getChristmasSubMain() async {
    List<Item> short = [];

    if (haveMoreData) {
      short =
          await apiMain.apiGetTagProducts("Christmas", numPageSubCategories);
    }

    if (short.isEmpty) {
      haveMoreData = false;
    }

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
      notifyListeners();
    }

    numPageSubCategories++;
  }

  Future<void> getSlidersSubMain(String? url1) async {
    List<Item> short = [];

    if (haveMoreData) {
      short = await apiMain.apiSlidersProducts(url1!, numPageSubCategories);
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

        numPageSubCategories++;
        notifyListeners();
      }
    }
  }

  Future<void> getProduct1() async {
    List<Item> short = [];

    if (haveMoreData) {
      short = await apiMain.apiGetProducts(numPageSubCategories);
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
        numPageSubCategories++;

        notifyListeners();
      }
    }
  }

  Future<void> clear() async {
    subCategories.clear();
    numPageSubCategories = 1;
    haveMoreData = true;
    showSpinKitMoreData = false;
    notifyListeners();
  }
}
