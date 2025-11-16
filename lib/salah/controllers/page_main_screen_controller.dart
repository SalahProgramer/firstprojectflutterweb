import 'dart:async';
import 'package:fawri_app_refactor/salah/controllers/APIS/api_page_main_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/cart_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/favourite_controller.dart';
import 'package:fawri_app_refactor/salah/models/first_images_model.dart';
import 'package:fawri_app_refactor/salah/models/items/item_model.dart';
import 'package:fawri_app_refactor/salah/models/user/user_activity.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dialog/dialogs/dialogs_home/dialogs_have_free_coupon.dart';
import '../../server/functions/functions.dart';
import '../../services/remote_config_firebase/remote_config_firebase.dart';
import '../localDataBase/sql_database.dart';
import '../localDataBase/models_DB/items_viewed_model.dart';
import '../models/flash/flash_model.dart';
import '../models/user/enum_point_status.dart';
import '../models/user/order_check_model.dart';
import '../models/sections/section_model.dart';
import '../models/slider_model.dart';
import '../utilities/sentry_service.dart';
import 'APIS/api_main_product_controller.dart';

class PageMainScreenController extends ChangeNotifier {
  List<Item> shortlisted = [];
  List<FirstImagesModel> imagesFirstCategories = [];
  int numPageCachedProducts = 1;
  List<Item> recommendedItems = [];
  List<Item> itemsMoreData = [];
  bool showSpinKitMoreData = false;

  bool haveMoreData = true;

  ScrollController scrollMoreDataItems = ScrollController();
  ApiMainProductController apiMain =
  NavigatorApp.context.read<ApiMainProductController>();
  FocusNode focusNodeDescription = FocusNode();
  final ValueNotifier<bool> isFocusedNotifier = ValueNotifier(false);

  //----------------------------item viewed -------------------------------------------
  SqlDb sqlDb = SqlDb();
  List<ItemsViewedModel> itemsViewed = [];
  List<Item> viewedItemsData = [];
  int numPageViewedItemsData = 1;
  String idsViewedItems = "";

  //---------------------------------------
  int numPageRecommendedItems = 1;
  int numPageMoreDataItems = 1;
  List<Item> featuresItems = [];
  int numPageFeaturesItems = 1;
  List<Item> homeItems = [];
  List<Item> offerTawseelItems = [];
  int numPageHomeItems = 1;
  OrderCheckModel? orderCheck;
  int numPageOfferTawseelItems = 1;
  Map<int, String> sectionsUrl = {};
  Map<int, int> sectionsNumPage = {};
  bool flag = false;
  bool fetchAppSection = false;
  bool doRefresh = false;

  List<List<Item>> sectionsItems = [];
  List<Item> addSectionsItems = [];
  List<Item> bestSellersProducts = [];
  int numPageBestSellersProducts = 1;

  List<SliderModel> cashedSliders = [];
  List<SliderModel> slidersUrl = [];
  List<SectionModel> sections = [];
  int numPageSectionItems = 1;
  FlashModel? flash;
  List<Item> flashItems = [];
  int numPageFlashItems = 1;

  Map<String, double> positionScroll = {};
  Map<String, bool> isFavourite = {};
  FixedExtentScrollController controllerBest = FixedExtentScrollController();
  Item? itemData;
  bool setBigCategories = false;
  bool wasShowRateOrder = false;
  bool wasShowWheelCoupon = false;
  Map<String, bool>? isLoadingProductNewArrival = {};
  Map<String, bool>? isLoadingRecommendedItems = {};
  Map<String, bool>? isLoadingFeaturesItems = {};
  Map<String, bool>? isLoadingFlashItems = {};
  List<Map<String, bool>?> isLoadingSectionsItems = [];
  Map<String, bool>? isLoadingBestSellersProducts = {};
  Map<String, bool>? isLoadingHomeProducts = {};
  Map<String, bool>? isLoadingOfferItemsTawseelProducts = {};
  Map<String, bool>? isLoadingItemViewedProducts = {};
  ScrollController scrollControllerNewArrival = ScrollController();
  List<ScrollController> scrollControllerSection = [ScrollController()];
  ScrollController scrollControllerFeatures = ScrollController();
  ScrollController scrollRecommendedItems = ScrollController();
  ScrollController scrollBestSellersItems = ScrollController();
  ScrollController scrollFlashItems = ScrollController();
  ScrollController scrollHomeItems = ScrollController();
  ScrollController scrollViewedItems = ScrollController();
  bool isEndReachedNewArrival = false;
  ApiPageMainController api =
      NavigatorApp.context.read<ApiPageMainController>();
  FavouriteController favouriteController =
      NavigatorApp.context.read<FavouriteController>();
  CartController cartController = NavigatorApp.context.read<CartController>();
  bool couponShown = false;

  UserActivity userActivity = UserActivity();

  Future<void> checkAndShowCoupon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    couponShown = prefs.getBool('couponShown') ?? false;
    if (!couponShown) {
      // Show the coupon dialog

      couponShown = true;

      await prefs.setBool('couponShown', true);

      showDelayedDialogFreeCoupon();
    } else {
      // printLog(
      //     "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
      // Check if it's a new month
      DateTime now = DateTime.now();
      int currentMonth = now.month;
      int currentYear = now.year;
      int? lastMonth = prefs.getInt('lastMonth');
      int? lastYear = prefs.getInt('lastYear');

      if (lastMonth != currentMonth || lastYear != currentYear) {
        showDelayedDialogFreeCoupon();
        await prefs.setInt('lastMonth', currentMonth);
        await prefs.setInt('lastYear', currentYear);
      }
    }
    notifyListeners();
  }

  Future<void> clearUserActivity() async {
    userActivity = UserActivity();
    notifyListeners();
  }

  // change big Category
  Future<void> changeCheckTimeOut(bool check) async {
    flag = check;
    notifyListeners();
  }

  Future<void> changeDoRefresh(bool check) async {
    doRefresh = check;
    notifyListeners();
  }

  /// Trigger scroll to top and refresh for main screen
  Future<void> refreshMainScreen() async {
    doRefresh = true;
    notifyListeners();
  }

  Future<void> resetPagesNumber() async {
    numPageCachedProducts = 1;
    numPageRecommendedItems = 1;
    numPageFeaturesItems = 1;
    numPageHomeItems = 1;
    numPageBestSellersProducts = 1;

    numPageSectionItems = 1;
    numPageViewedItemsData = 1;

    numPageFlashItems = 1;
    numPageMoreDataItems=1;
    sectionsNumPage = {};
    notifyListeners();
  }

// change big Category
  Future<void> changeBigCategories() async {
    setBigCategories = !setBigCategories;

    notifyListeners();
  }

  Future<void> changeBigCategoriesTrue() async {
    setBigCategories = true;
    notifyListeners();
  }

// all changes each products
  Future<void> changePositionScroll(String id, double index) async {
    positionScroll[id] = index;
    notifyListeners();
  }

  Future<void> changeIsFavourite(String id, bool newIsFavourite) async {
    isFavourite[id] = newIsFavourite;
    notifyListeners();
  }

  // methods gets each products
  //--------------------------------------------------------------------------------------------------------------
  // ---get Cached Products (new Arrival)
  Future<void> getCachedProducts() async {
    // printLog(numPageCachedProducts);
    var short = await api.apiCachedProducts(numPageCachedProducts);

    if (numPageCachedProducts == 1) {
      shortlisted.clear();
      notifyListeners();
      // printLog(numPageCachedProducts);
    }

    shortlisted.addAll(short);

    // Remove duplicates
    shortlisted = shortlisted.toSet().toList();

    // printLog(shortlisted.length);

    if (shortlisted.isNotEmpty) {
      // Use a temporary list to prevent concurrent modification
      var tempShortlisted = List.from(shortlisted);

      for (var item in tempShortlisted) {
        final id = item.id.toString();
        bool check =
            await favouriteController.checkFavouriteItem(productId: item.id);

        isLoadingProductNewArrival![id] = false;
        positionScroll[id] = 0;
        isFavourite[id] = check;
      }
    }

    numPageCachedProducts++;
    notifyListeners();
  }

  Future<void> changeLoadingProductNewArrival(String index, bool check) async {
    isLoadingProductNewArrival?[index] = check;
    notifyListeners();
  }

  //--------------------------------------------------------------------------------------------------------------
  //---get Cached Sliders (cashed slider and category)
  Future<void> getAllSliders() async {
    Map<String, List<SliderModel>> allSliders = await api.apiSliders();
    if (allSliders == {} || allSliders.isEmpty) {
    } else {
      cashedSliders = allSliders["sliders"] ?? [];
      slidersUrl = allSliders["category"] ?? [];
    }

    notifyListeners();
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get Recommended Products (Recommended)
  Future<void> fetchRecommendedItems() async {
    var short = await api.apiRecommendedItems(numPageRecommendedItems);
    if (numPageRecommendedItems == 1) {
      recommendedItems.clear();
    }
    recommendedItems.addAll(short);

    // Convert the list to a set and back to list to remove duplicates
    recommendedItems = recommendedItems.toSet().toList();

    if (recommendedItems.isNotEmpty) {
      // Use a temporary list for iteration
      var tempItems = List.from(recommendedItems);

      for (var item in tempItems) {
        final id = item.id.toString();
        bool check =
            await favouriteController.checkFavouriteItem(productId: item.id);

        isLoadingRecommendedItems![id] = false;
        positionScroll[id] = 0;
        isFavourite[id] = check;
      }
      numPageRecommendedItems++;
    }

    notifyListeners();
  }

  Future<void> changeLoadingProductRecommendedItems(
      String index, bool check) async {
    isLoadingRecommendedItems?[index] = check;
    notifyListeners();
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get bestSellers Products (bestSellers)

  Future<void> getBestSellersProducts() async {
    var short = await api.apiBestSellersProducts(numPageBestSellersProducts);
    if (numPageBestSellersProducts == 1) {
      bestSellersProducts.clear();
    }
    bestSellersProducts.addAll(short);
    bestSellersProducts = bestSellersProducts.toSet().toList();
    if (bestSellersProducts.isNotEmpty) {
      var tempItems = List.from(bestSellersProducts);

      for (var item in tempItems) {
        final id = item.id.toString();
        bool check =
            await favouriteController.checkFavouriteItem(productId: item.id);

        isLoadingBestSellersProducts?[id] = false;
        positionScroll[id] = 0;
        isFavourite[id] = check;
      }
    }
    numPageBestSellersProducts++;
    await controllerScrollBest();
  }

  Future<void> controllerScrollBest() async {
    controllerBest.jumpToItem(2);
  }

  Future<void> changeLoadingProductBest(String index, bool check) async {
    isLoadingBestSellersProducts?[index] = check;
    notifyListeners();
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get features items (features)
  Future<void> getFeatureProducts() async {
    var featuresUrl3 = await FirebaseRemoteConfigClass().getCategoryIDKey3();
    // printLog(featuresUrl3);
    var short =
        await api.apiFeatureProducts(featuresUrl3, numPageFeaturesItems);

    if (numPageFeaturesItems == 1) {
      featuresItems.clear();
    }
    featuresItems.addAll(short);
    featuresItems = featuresItems.toSet().toList();
    if (featuresItems.isNotEmpty) {
      var tempItems = List.from(featuresItems);

      for (var item in tempItems) {
        final id = item.id.toString();
        bool check =
            await favouriteController.checkFavouriteItem(productId: item.id);

        isLoadingFeaturesItems?[id] = false;
        positionScroll[id] = 0;
        isFavourite[id] = check;
      }
    }
    numPageFeaturesItems++;
    notifyListeners();
  }

  Future<void> changeLoadingProductFeaturesItems(
      String index, bool check) async {
    isLoadingFeaturesItems?[index] = check;
    notifyListeners();
  }

//--------------------------------------------------------------------------------------------------------------
  // ---get home items (homeItems)
  Future<void> getHomeData() async {
    var short = await api.apiHomeData(numPageHomeItems);
    if (numPageHomeItems == 1) {
      homeItems.clear();
    }
    homeItems.addAll(short);
    homeItems = homeItems.toSet().toList();
    if (homeItems.isNotEmpty) {
      var tempItems = List.from(homeItems);

      for (var item in tempItems) {
        final id = item.id.toString();
        bool check =
            await favouriteController.checkFavouriteItem(productId: item.id);

        isLoadingHomeProducts?[id] = false;
        positionScroll[id] = 0;
        isFavourite[id] = check;
      }
      numPageHomeItems++;
      notifyListeners();
    }
  }

  Future<void> changeLoadingProductHomeItems(String index, bool check) async {
    isLoadingHomeProducts?[index] = check;
    notifyListeners();
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get Sections (Sections)

  Future<void> getAppSections({bool isFirstGet = true}) async {
    sections = await api.apiAppSections();

    if (sections.isNotEmpty) {
      int index = 0;
      for (var element in sections) {
        var add = element.content;
        sectionsUrl[index] = element.contentUrl;
        sectionsNumPage[index] = 2;
        if (isFirstGet == true) {
          sectionsItems.add(add);
        } else {
          if (numPageSectionItems == 1) {
            sectionsItems[index].clear();
          }
          sectionsItems[index].addAll(add);
        }

        // printLog(sectionsItems.length);
        isLoadingSectionsItems.add(
            {for (var item in sectionsItems[index]) item.id.toString(): false});
        positionScroll.addAll(
            {for (var item in sectionsItems[index]) item.id.toString(): 0});
        for (var item in sectionsItems[index]) {
          bool check =
              await favouriteController.checkFavouriteItem(productId: item.id);
          isFavourite.addAll({item.id.toString(): check});
        }
        scrollControllerSection.add(ScrollController());
        index++;
      }
      numPageSectionItems++;
    }
    fetchAppSection = true;

    notifyListeners();
  }

  Future<void> getSectionIndex({required int indexUrl}) async {
    if (sections.isNotEmpty) {
      var add = await api.specificSection(
          sectionsUrl[indexUrl] ?? "", sectionsNumPage[indexUrl] ?? 2);

      if (numPageSectionItems == 1) {
        sectionsItems[indexUrl].clear();
      }
      sectionsItems[indexUrl].addAll(add);
    }

    // printLog(sectionsItems.length);
    isLoadingSectionsItems.add(
        {for (var item in sectionsItems[indexUrl]) item.id.toString(): false});
    positionScroll.addAll(
        {for (var item in sectionsItems[indexUrl]) item.id.toString(): 0});
    for (var item in sectionsItems[indexUrl]) {
      bool check =
          await favouriteController.checkFavouriteItem(productId: item.id);
      isFavourite.addAll({item.id.toString(): check});
    }
    scrollControllerSection.add(ScrollController());

    sectionsNumPage[indexUrl] = sectionsNumPage[indexUrl]! + 1;
    notifyListeners();
  }

  Future<void> changeLoadingSectionsItems(
      int index, String id, bool check) async {
    isLoadingSectionsItems[index]?[id] = check;
    notifyListeners();
  }

//--------------------------------------------------------------------------------------------------------------
// ---get Flash sales (flash Sales)
  Future<void> getFlashItems() async {
    flash = await api.apiFlashItems(numPageFlashItems);
    if (numPageFlashItems == 1) {
      flashItems.clear();
    }
    if (flash != null) {
      flashItems.addAll(flash!.items);
      flashItems = flashItems.toSet().toList();

      // Ensure that the list is not empty
      if (flash?.items.isNotEmpty ?? false) {
        // Use a temporary list to prevent concurrent modification
        var tempFlashItems = List.from(flashItems);

        for (var item in tempFlashItems) {
          final id = item.id.toString();
          bool check =
              await favouriteController.checkFavouriteItem(productId: item.id);

          isLoadingFlashItems?[id] = false;
          positionScroll[id] = 0;
          isFavourite[id] = check;
        }
      }
    }

    numPageFlashItems++;
    notifyListeners();
  }

  Future<void> changeLoadingProductFlashItems(String index, bool check) async {
    isLoadingFlashItems?[index] = check;
    notifyListeners();
  }

//-------------------------items viewed--------------------------------------------------------------

  Future<void> getItemsViewedData() async {
    var short =
        await api.apiViewedItemsData(numPageViewedItemsData, idsViewedItems);
    if (numPageViewedItemsData == 1) {
      viewedItemsData.clear();
    }
    viewedItemsData.addAll(short);
    viewedItemsData = viewedItemsData.toSet().toList();
    viewedItemsData = viewedItemsData.reversed.toList();

    for (var i in cartController.cartItems) {
      viewedItemsData.removeWhere(
        (element) =>
            element.id.toString().trim() == i.productId.toString().trim(),
      );
    }

    // Step 2: Sort `viewedItemsData` based on sorted `itemsViewed`
    viewedItemsData.sort((a, b) {
      // Safely get the createdAt field, defaulting to an empty string if not found
      String createdAtA =
          itemsViewed.firstWhere((item) => item.id == a.id).createdAt ?? "";

      String createdAtB = itemsViewed
              .firstWhere((item) =>
                      item.id ==
                      b.id // Provide a default item with empty createdAt
                  )
              .createdAt ??
          "";

      // Parse the createdAt strings into DateTime objects for comparison
      DateTime dateA = DateTime.tryParse(createdAtA) ??
          DateTime.now(); // Handle invalid format gracefully
      DateTime dateB = DateTime.tryParse(createdAtB) ??
          DateTime.now(); // Handle invalid format gracefully

      // Compare the DateTime objects
      return dateA.compareTo(dateB);
    });

    viewedItemsData = viewedItemsData.reversed.toList();
    if (viewedItemsData.isNotEmpty) {
      var tempItems = List.from(viewedItemsData);

      for (var item in tempItems) {
        final id = item.id.toString();
        bool check =
            await favouriteController.checkFavouriteItem(productId: item.id);

        isLoadingItemViewedProducts?[id] = false;
        positionScroll[id] = 0;
        isFavourite[id] = check;
      }
      numPageViewedItemsData++;
      notifyListeners();
    }
  }

  Future<void> changeLoadingViewedItems(String index, bool check) async {
    isLoadingItemViewedProducts?[index] = check;
    notifyListeners();
  }

  Future<void> getItemsViewed() async {
    idsViewedItems = "";
    List<Map> response =
        await sqlDb.readData(sql: "SELECT * FROM 'itemViewed'");
    itemsViewed = ItemsViewedModel.fromJsonList(response);

    itemsViewed.sort((a, b) {
      DateTime dateA = DateTime.parse(a.createdAt ?? "");
      DateTime dateB = DateTime.parse(b.createdAt ?? "");
      return dateA.compareTo(dateB);
    });

    // // Now, products are sorted by createdAt
    //     for (var product in itemsViewed) {
    //       printLog('Product ID: ${product.id}, Created At: ${product.createdAt}');
    //     }

    // printLog("crated_Att:${itemsViewed.toString()}");

    if (itemsViewed.isNotEmpty) {
      idsViewedItems = itemsViewed.map((e) => e.id.toString()).join(',');
    } else {
      idsViewedItems = "";
    }

    await getItemsViewedData();
    notifyListeners();
  }

  Future<bool> checkItemViewedById({required int productId}) async {
    List<Map> response = await sqlDb.readData(
        sql: "SELECT * FROM 'itemViewed'  WHERE id =$productId");

    if (response.toString() == "[]") {
      return false;
    } else {
      return true;
    }
  }

  Future<void> deleteLastItem(
      {required int? id, required String? createdAt}) async {
    int deletedId = itemsViewed[0].id ?? 0; // Get the id of the deleted item

    // printLog("Before deletion: $deletedId");

    await sqlDb.deleteData(sql: "DELETE FROM itemViewed WHERE id =$deletedId");
    // printLog(response);
    // printLog(response);

    viewedItemsData.removeWhere((item) => item.id == deletedId);
    // await getItemsViewed();

    // printLog("Before deletionData: ${viewedItemsData.length}");
    // printLog("After deletionViewed: ${itemsViewed.length}");

    await insertData(createdAt: createdAt, id: id);
    // Print items after deletion
  }

  Future<int> insertData({required int? id, required String? createdAt}) async {
    createdAt ??= DateTime.now()
        .toIso8601String(); // Converts to "YYYY-MM-DD HH:MM:SS.SSS"

    // printLog("crated_Att:$createdAt");
    //         printLog("Before deletion: ${viewedItemsData.length}");

    int response = await sqlDb.insertData(
        sql:
            "INSERT INTO 'itemViewed' ('id','created_at') VALUES ($id,'$createdAt')");

    // printLog("crated_Att:$response");

    if (response > 0) {
      // await getItemsViewed();
    }
    return response;
  }

  //-----------------Images big categories-------------------------------------------------------

  Future<void> returnFirstImageEachMain() async {
    // printLog(numPageCachedProducts);
    var short = await api.apiReturnFirstImageEachMain();

    imagesFirstCategories.addAll(short);

    // Remove duplicates
    imagesFirstCategories = imagesFirstCategories.toSet().toList();
    for (var item in imagesFirstCategories) {
      await insertDataBigCategories(
          image: item.image, mainCategories: item.mainCategory);
    }

    notifyListeners();
  }

  Future<void> getDataBigCategoriesImages() async {
    idsViewedItems = "";
    List<Map> response =
        await sqlDb.readData(sql: "SELECT * FROM 'bigCategoriesImages'");
    imagesFirstCategories =
        FirstImagesModel.fromJsonListImagesCategory(response);
    imagesFirstCategories = imagesFirstCategories.toSet().toList();
    notifyListeners();
  }

  Future<int> insertDataBigCategories(
      {required String? mainCategories, required String? image}) async {
    int response = await sqlDb.insertData(
        sql:
            "INSERT INTO 'bigCategoriesImages' ('main_category','image') VALUES ('$mainCategories','$image')");

    // printLog("crated_Att:$response");

    if (response > 0) {}
    return response;
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get Offer tasweel items (homeItems)
  Future<void> getOfferTawseelItems() async {
    var short = await api.apiOfferTawseelItem(numPageOfferTawseelItems);
    if (numPageOfferTawseelItems == 1) {
      offerTawseelItems.clear();
    }
    offerTawseelItems.addAll(short);
    offerTawseelItems = offerTawseelItems.toSet().toList();
    if (offerTawseelItems.isNotEmpty) {
      var tempItems = List.from(offerTawseelItems);

      for (var item in tempItems) {
        final id = item.id.toString();

        await favouriteController.checkFavouriteItem(productId: item.id);

        isLoadingOfferItemsTawseelProducts?[id] = false;
      }
      numPageOfferTawseelItems++;
      notifyListeners();
    }
  }

  Future<void> getOfferTawseelClear() async {
    numPageOfferTawseelItems = 1;
    notifyListeners();
  }

  Future<void> changeLoadingProductOfferItems(String index, bool check) async {
    isLoadingOfferItemsTawseelProducts?[index] = check;
    notifyListeners();
  }

  // get Order Completed----------------------------------------------------------------------------

  Future<void> getOrderCompletedSuccess({required String phone}) async {
    orderCheck = await api.apiOrderCompleted(phone: phone);
    notifyListeners();
  }

  Future<void> changeWasFirstShowRateOrder(bool check) async {
    wasShowRateOrder = check;
    notifyListeners();
  }

  Future<void> getUserActivity({required String phone}) async {
    final result = await api.getUserActivity(phone: phone);
    Map<String, EnumPointsStatus> enumStatus = {
      '1': EnumPointsStatus.defaultStatus(),
      '2': EnumPointsStatus.defaultStatus(),
      '3': EnumPointsStatus.defaultStatus(),
      '4': EnumPointsStatus.defaultStatus(),
      '5': EnumPointsStatus.defaultStatus(),
      '6': EnumPointsStatus.defaultStatus(),
    };
    result.fold(
      (failure) async {
        if (failure.code == 404) {
        } else {
          userActivity = UserActivity(lastEnumStatus: enumStatus);

          SentryService.captureError(
            exception: Exception("Error [${failure.code}]: ${failure.message}"),
          );
        }
        notifyListeners();
      },
      // RIGHT = Points
      (rightPoints) async {
        userActivity = rightPoints;
        notifyListeners();

        printLog("✅ Success: $rightPoints");
      },
    );
  }



  Future<void> changeSpinHaveMoreData(bool check) async {
    showSpinKitMoreData = check;
    notifyListeners();
  }



  Future<void> getProductMoreData() async {
    List<Item> short = [];

    if (haveMoreData) {
      short = await apiMain.apiGetProducts(numPageMoreDataItems);
    }

    if (short.isEmpty) {
      haveMoreData = false;
      notifyListeners();
      return;
    } else {
      itemsMoreData.addAll(short);
      itemsMoreData = itemsMoreData.toSet().toList();
      if (itemsMoreData.isNotEmpty) {
        var tempItems = List.from(itemsMoreData);

        for (var item in tempItems) {
          final id = item.id.toString();
          bool check =
          await favouriteController.checkFavouriteItem(productId: item.id);

          positionScroll[id] = 0;
          isFavourite[id] = check;
        }
        numPageMoreDataItems++;

        notifyListeners();
      }
    }
  }
  Future<void> clearMoreData() async {
    itemsMoreData.clear();
    numPageMoreDataItems = 1;
    haveMoreData = true;
    showSpinKitMoreData = false;
    notifyListeners();
  }




//------------------------------------------------------------------------------------------------------
}
