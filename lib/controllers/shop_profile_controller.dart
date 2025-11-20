// import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
// import 'package:fawri_app_refactor/salah/utilities/networks/connection_network.dart';
// import 'package:flare_flutter/flare_controls.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
//
// import '../../server/functions/functions.dart';
// import 'favourite_controller.dart';
// import '../models/flash/flash_model.dart';
// import '../models/items/item_model.dart';
// import 'APIS/api_page_main_controller.dart';
// import 'APIS/api_main_product_controller.dart';

// class ShopProfileController extends ChangeNotifier {
//   TextEditingController? textController;
//   bool isFirstLoadRunning = false;
//   bool isLoadMoreRunning = false;
//   bool noInternet = false;
//   int page = 1;
//   bool hasNextPage = true;
//   FlareControls flareControls = FlareControls();
//
//   Map<String, int> positionScroll = {};
//   Map<String, bool> isFavourite = {};
//   final ScrollController controller = ScrollController();
//   FixedExtentScrollController controllerBest = FixedExtentScrollController();
//
//   ApiPageMainController api =
//       NavigatorApp.context.read<ApiPageMainController>();
//   ApiMainProductController apiMain =
//       NavigatorApp.context.read<ApiMainProductController>();
//   FavouriteController favouriteController =
//       NavigatorApp.context.read<FavouriteController>();
//
//   List<Item> shopProfile = [];
//   Map<String, List<Item>> cache = {};
//   FlashModel? flash;
//   List<Item> flashItems = [];
//   List<Item> bestSellersProducts = [];
//   List<Item> getProduct = [];
//
// // all changes each products
//   Future<void> changePositionScroll(String id, int index) async {
//     positionScroll[id] = index;
//     notifyListeners();
//   }
//
//   Future<void> changeIsFavourite(String id, bool newIsFavourite) async {
//     isFavourite[id] = newIsFavourite;
//     notifyListeners();
//   }
//
// //--------------------------------------------------------------------------------------------------------------
// // ---firstLoad, loadMore, _refreshData
//   Future<void> firstLoad() async {
//     page = 1;
//     notifyListeners();
//     isFirstLoadRunning = true;
//     bool isConnected = await isConnectedWifi();
//     if (!isConnected) {
//       noInternet = true;
//       isFirstLoadRunning = false;
//       notifyListeners();
//     } else {
//       shopProfile = await getProduct1();
//
//       notifyListeners();
//
//       isFirstLoadRunning = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> loadMore() async {
//     if (hasNextPage == true &&
//         isFirstLoadRunning == false &&
//         isLoadMoreRunning == false &&
//         controller.position.extentAfter < 300) {
//       isLoadMoreRunning = true;
//
//       page += 1;
//
//       var products = await getProduct1();
//
//       if (products.isNotEmpty) {
//         shopProfile.addAll(products);
//         notifyListeners();
//       } else {
//         Fluttertoast.showToast(
//             msg: "لا يوجد المزيد من المنتجات ، قم بتصفح الاقسام الأُخرى");
//       }
//
//       isLoadMoreRunning = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> refreshData() async {
//     await Future.delayed(Duration(seconds: 1));
//     page = 1;
//
//     var d = await getProduct1();
//     if (d.isNotEmpty) {
//       shopProfile = [];
//
//       shopProfile = d;
//     } else {
//       printLog("_hasNextPage = false");
//     }
//   }
//
//   //--------------------------------------------------------------------------------------------------------------
// // ---get products
//
//   Future<List<Item>> getProduct1() async {
//     var res = await apiMain.apiGetProducts(page);
//     getProduct.addAll(res);
//     getProduct = getProduct.toSet().toList();
//     if (getProduct.isNotEmpty) {
//       var tempItems = List.from(getProduct);
//
//       for (var item in tempItems) {
//         final id = item.id.toString();
//         bool check =
//             await favouriteController.checkFavouriteItem(productId: item.id);
//
//         positionScroll[id] = 0;
//         isFavourite[id] = check;
//       }
//       return getProduct;
//     } else {
//       return [];
//     }
//   }
// }
