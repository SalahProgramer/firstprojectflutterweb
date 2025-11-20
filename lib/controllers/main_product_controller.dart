import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../core/network/connection_network.dart';
import '../core/utilities/global/app_global.dart';
import '../core/utilities/print_looger.dart';
import 'favourite_controller.dart';
import '../models/flash/flash_model.dart';
import '../models/items/item_model.dart';
import 'APIS/api_page_main_controller.dart';
import 'APIS/api_main_product_controller.dart';

class MainProductController extends ChangeNotifier {
  TextEditingController? textController;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  bool noInternet = false;
  int page = 1;
  bool hasNextPage = true;
  FlareControls flareControls = FlareControls();
  bool? hasApi;
  String? type1;

  Map<String, int> positionScroll = {};
  Map<String, bool> isFavourite = {};
  final ScrollController controller = ScrollController();
  FixedExtentScrollController controllerBest = FixedExtentScrollController();

  ApiPageMainController api =
      NavigatorApp.context.read<ApiPageMainController>();
  ApiMainProductController apiMain =
      NavigatorApp.context.read<ApiMainProductController>();
  FavouriteController favouriteController =
      NavigatorApp.context.read<FavouriteController>();

  List<Item> mainProducts = [];
  Map<String, List<Item>> cache = {};
  FlashModel? flash;
  List<Item> flashItems = [];
  List<Item> bestSellersProducts = [];
  List<Item> getProduct = [];

// all changes each products
  Future<void> changePositionScroll(String id, int index) async {
    positionScroll[id] = index;
    notifyListeners();
  }

  Future<void> changeIsFavourite(String id, bool newIsFavourite) async {
    isFavourite[id] = newIsFavourite;
    notifyListeners();
  }

//--------------------------------------------------------------------------------------------------------------
// ---firstLoad, loadMore, _refreshData
  Future<void> firstLoad({required String type, required bool hasAPI}) async {
    page = 1;
    hasApi = hasAPI;
    type1 = type;
    notifyListeners();
    isFirstLoadRunning = true;
    bool isConnected = await isConnectedWifi();
    if (!isConnected) {
      noInternet = true;
      isFirstLoadRunning = false;
      notifyListeners();
    } else {
      mainProducts = (type == "flash_sales")
          ? await apiMain.apiGetTagProducts("flash_sales", page)
          : (type == "11.11")
              ? await apiMain.apiGetTagProducts("11.11", page)
              : type == "discount"
                  ? await apiMain.apiGetTagProducts("discount", page)
                  : type == "Christmas"
                      ? await apiMain.apiGetTagProducts("Christmas", page)
                      : hasAPI
                          ? await getBestSellersProducts(page)
                          : await getProduct1(page);
      page += 1;
      notifyListeners();

      isFirstLoadRunning = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({required String type, required bool hasAPI}) async {
    if (hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        controller.position.extentAfter < 300) {
      isLoadMoreRunning = true;
      notifyListeners();
      printLog("loadMore1");
      printLog(page);

      printLog(type);
      printLog(hasAPI);
      List<Item> products = (type == "flash_sales")
          ? await apiMain.apiGetTagProducts("flash_sales", page)
          : (type == "11.11")
              ? await apiMain.apiGetTagProducts("11.11", page)
              : type == "discount"
                  ? await apiMain.apiGetTagProducts("discount", page)
                  : type == "Christmas"
                      ? await apiMain.apiGetTagProducts("Christmas", page)
                      : hasAPI
                          ? await getBestSellersProducts(page)
                          : await getProduct1(page);
      printLog("loadMore1");

      printLog(products[0].newPrice);

      if (products.isNotEmpty) {
        mainProducts.addAll(products);
        page++;

        isLoadMoreRunning = false;
        notifyListeners();
      } else {
        Fluttertoast.showToast(
            msg: "لا يوجد المزيد من المنتجات ، قم بتصفح الاقسام الأُخرى");
      }
    }
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    page = 1;

    var d = (type1 == "flash_sales")
        ? await apiMain.apiGetTagProducts("flash_sales", page)
        : (type1 == "11.11")
            ? await apiMain.apiGetTagProducts("11.11", page)
            : type1 == "discount"
                ? await apiMain.apiGetTagProducts("discount", page)
                : type1 == "Black Friday"
                    ? await apiMain.apiGetTagProducts("Black Friday", page)
                    : type1 == "Christmas"
                        ? await apiMain.apiGetTagProducts("Christmas", page)
                        : hasApi ?? false
                            ? await getBestSellersProducts(page)
                            : await getProduct1(page);
    if (d.isNotEmpty) {
      mainProducts = [];

      mainProducts = d;
    } else {
      printLog("_hasNextPage = false");
    }
  }

  //--------------------------------------------------------------------------------------------------------------
// ---get Flash sales (flash Sales)

//--------------------------------------------------------------------------------------------------------------
  // ---get bestSellers Products (bestSellers)

  Future<List<Item>> getBestSellersProducts(int page) async {
    var short = await api.apiBestSellersProducts(page);

    bestSellersProducts.addAll(short);
    bestSellersProducts = bestSellersProducts.toSet().toList();
    if (bestSellersProducts.isNotEmpty) {
      var tempItems = List.from(bestSellersProducts);

      for (var item in tempItems) {
        final id = item.id.toString();
        bool check =
            await favouriteController.checkFavouriteItem(productId: item.id);

        positionScroll[id] = 0;
        isFavourite[id] = check;
      }

      page++;
      await controllerScrollBest();

      notifyListeners();

      return bestSellersProducts;
    } else {
      return [];
    }
  }

  Future<void> controllerScrollBest() async {
    controllerBest.jumpToItem(2);
  }

  Future<List<Item>> getProduct1(int page) async {
    var res = await apiMain.apiGetProducts(page);
    getProduct.addAll(res);
    getProduct = getProduct.toSet().toList();
    if (getProduct.isNotEmpty) {
      var tempItems = List.from(getProduct);

      for (var item in tempItems) {
        final id = item.id.toString();
        bool check =
            await favouriteController.checkFavouriteItem(productId: item.id);

        positionScroll[id] = 0;
        isFavourite[id] = check;
      }
      return getProduct;
    } else {
      return [];
    }
  }
}
