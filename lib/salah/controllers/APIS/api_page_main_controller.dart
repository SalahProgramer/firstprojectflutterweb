import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:fawri_app_refactor/salah/controllers/user_controller.dart';
import 'package:fawri_app_refactor/salah/models/user/user_activity.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../firebase/selected_sizes/selected_sizes_controller.dart';
import '../../../firebase/selected_sizes/selected_sizes_model.dart';
import '../../../server/domain/domain.dart';
import '../../../server/functions/functions.dart';
import '../../../services/remote_config_firebase/remote_config_firebase.dart';
import '../../models/first_images_model.dart';
import '../../models/flash/flash_model.dart';
import '../../models/items/item_model.dart';
import '../../models/user/order_check_model.dart';
import '../../models/sections/section_model.dart';
import '../../models/slider_model.dart';
import '../../utilities/sentry_service.dart';
import '../../utilities/typedefs/failure.dart';

class ApiPageMainController extends ChangeNotifier {
  //--------------------------------------------------------------------------------------------------------------
  // ---get Cached Products (new Arrival)
  Future<List<Item>> apiCachedProducts(int numPageCachedProducts) async {
    List<Item> products;

    try {
      Map<String, dynamic> fetchedProducts = await apiGetProducts(
        numPageCachedProducts,
        1,
      );

      products = Item.fromJsonListNewArrival(
        jsonDecode(jsonEncode(fetchedProducts))["items"],
      );

      return products;
    } catch (error, stack) {
      await SentryService.captureError(
        exception: error,
        stackTrace: stack,
        functionName: 'apiCachedProducts',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 30,
      );
      printLog(error.toString());
      return [];
    }
  }

  // } catch (e) {
  //   // await messageError(e.toString());
  //   return [];
  // }

  Future<Map<String, dynamic>> apiGetProducts(int page, int sortingMode) async {
    try {
      var seasonName = await FirebaseRemoteConfigClass().initilizeConfig();

      var response = await http.get(
        Uri.parse(
          "${url}getAllItems?api_key=$keyBath&season=${seasonName.toString()}&page=$page&sorting_mode=$sortingMode",
        ),
        headers: headers,
      );

      printLog(
        "${url}getAllItems?api_key=$keyBath&season=${seasonName.toString()}&page=$page&sorting_mode=$sortingMode",
      );
      var res = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return res;
      } else {
        await SentryService.captureError(
          exception:
              "Failed to load products with status: ${response.statusCode}",
          functionName: 'apiGetProducts',
          fileName: 'api_page_main_controller.dart',
        );

        // await messageError("Failed to load products: ${response.statusCode}");
        return {};
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiGetProducts',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 70,
      );
      // await messageError("error: $e");

      return {};
    }
  }

  //--------------------------------------------------------------------------------------------------------------
  //---get Sliders without category (slider and category)
  Future<Map<String, List<SliderModel>>> apiSliders() async {
    Map<String, List<SliderModel>> allSliders;

    try {
      var response = await http.get(
        Uri.parse("${url}getSlidersAll?api_key=$keyBath"),
        headers: headers,
      );
      var res = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<SliderModel> slider = SliderModel.fromJsonList(((res["slider"])));
        List<SliderModel> category = SliderModel.fromJsonList(
          ((res["category"])),
        );
        allSliders = {"sliders": slider, "category": category};

        return allSliders;
      } else {
        await SentryService.captureError(
          exception: "apiSliders failed with status: ${response.statusCode}",
          functionName: 'apiSliders',
          fileName: 'api_page_main_controller.dart',
        );
        return {};
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiSliders',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 100,
      );
      printLog(e.toString());
      return {};
    }
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get Recommended Products (Recommended)
  Future<List<Item>> apiRecommendedItems(int page) async {
    UserController userController = NavigatorApp.context.read<UserController>();

    try {
      SelectedSizeService selectedSizeService = SelectedSizeService();
      await userController.getUserID();
      String userID = userController.userId;
      String categoryId = "";
      List<String> sizes = [];
      String userId = userID;
      List<SelectedSizeModel> selectedSizes = await selectedSizeService
          .getSelectedSizesByUserId(userId);
      for (var selectedSize in selectedSizes) {
        categoryId = selectedSize.categoryId;
        categoryId = categoryId.replaceAll('&', '%26');
        sizes = selectedSize.selectedSizes;
        // String sizesParam = sizes.join(',');
      }
      var response = await getProductByCategory(
        categoryId,
        '',
        '',
        sizes.join(','),
        page,
      );
      if (response.isNotEmpty) {
        // combinedResponse["items"].addAll(response);

        return response;
      } else {
        return await apiCachedProducts(1);
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiRecommendedItems',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 140,
      );
      // await messageError("Failed to load recommended items");

      return [];
    }
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get bestSellers Products (bestSellers)

  Future<List<Item>> apiBestSellersProducts(int page) async {
    List<Item> bestSellersProducts;
    try {
      var response = await http.get(
        Uri.parse("$urlTopSELLERS?page=$page"),
        headers: headers,
      );

      var res = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        bestSellersProducts = Item.fromJsonListBestSeller(res["data"]);

        bestSellersProducts.removeWhere((i) {
          String numericString = i.newPrice.replaceAll('₪', '').trim();
          double? numericValue = double.tryParse(numericString);

          if (numericValue == null) {
            // printLog("Invalid price format for item: '${i.newPrice}'");
            return false;
          }

          if (numericValue == 0) {
            // printLog("Removing item with price 0: '${i.newPrice}'");
            return true;
          }

          return false;
        });

        return bestSellersProducts;
      } else {
        await SentryService.captureError(
          exception:
              "Failed to loadBest Sellers with status: ${response.statusCode}",
          functionName: 'apiBestSellersProducts',
          fileName: 'api_page_main_controller.dart',
        );
        // await messageError("Failed to loadBest Sellers");

        return [];
      }
    } catch (error, stack) {
      await SentryService.captureError(
        exception: error,
        stackTrace: stack,
        functionName: 'apiBestSellersProducts',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 180,
      );
      // /await messageError("Failed to loadBest Sellers:$error");
      return [];
    }
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get features items (features)
  Future<List<Item>> apiFeatureProducts(domainName, int index) async {
    List<Item> featuresItems;

    String url = domainName.replaceFirst(RegExp(r'page=\d+'), 'page=$index');

    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode != 200) {
        // await messageError("Failed to load features items");

        await SentryService.captureError(
          exception:
              "Failed to load features items with status: ${response.statusCode}",
          functionName: 'apiFeatureProducts',
          fileName: 'api_page_main_controller.dart',
        );

        return [];
      } else {
        var res = json.decode(utf8.decode(response.bodyBytes));

        featuresItems = Item.fromJsonListNewArrival(res["items"]);

        return featuresItems;
      }
    } catch (error, stack) {
      await SentryService.captureError(
        exception: error,
        stackTrace: stack,
        functionName: 'apiFeatureProducts',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 220,
      );
      // await messageError("Failed features $error");

      return [];
    }
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get home items (homeItems)
  Future<List<Item>> apiHomeData(int page) async {
    var seasonName = await FirebaseRemoteConfigClass().initilizeConfig();
    List<Item> homeItems;
    try {
      var response = await http.get(
        Uri.parse(
          "${url}getAvailableItems?main_category=Home %26 Living, Home Living, Home Textile,Tools %26 Home Improvement&sub_category=&season=${seasonName.toString()}&page=$page&api_key=H93J48593HFNWIEUTR287TG3",
        ),
        headers: headers,
      );
      printLog(
        "${url}getAvailableItems?main_category=Home %26 Living, Home Living, Home Textile,Tools %26 Home Improvement&sub_category=&season=${seasonName.toString()}&page=$page&api_key=H93J48593HFNWIEUTR287TG3",
      );
      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        homeItems = Item.fromJsonListNewArrival(res["items"]);
        return homeItems;
      } else {
        await SentryService.captureError(
          exception: "apiHomeData failed with status: ${response.statusCode}",
          functionName: 'apiHomeData',
          fileName: 'api_page_main_controller.dart',
        );

        return [];
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiHomeData',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 360,
      );
      // await messageError("Failed $e");

      return [];
    }
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get Sections (Sections)
  Future<List<SectionModel>> apiAppSections() async {
    List<SectionModel> sections;

    try {
      var response = await http.get(
        Uri.parse("$urlAppSECTIONS?api_key=$keyBath"),
        headers: headers,
      );

      if (response.statusCode != 200) {
        await SentryService.captureError(
          exception:
              "Failed to load sections with status: ${response.statusCode}",
          functionName: 'apiAppSections',
          fileName: 'api_page_main_controller.dart',
        );
        // await messageError("Failed to load sections");

        return [];
      } else {
        var res = json.decode(utf8.decode(response.bodyBytes));
        sections = SectionModel.fromJsonList(res);
        return sections;
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiAppSections',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 385,
      );
      // await messageError("Failed $e");

      return [];
    }
  }

  Future<List<Item>> apiAllSections(SectionModel element, int page) async {
    List<Item> sectionsItem;
    try {
      var url1 = element.contentUrl.replaceAll(RegExp(r'(&page=\d+)'), '');
      var response = await http.get(
        Uri.parse("$url1&page=$page"),
        headers: headers,
      );
      // printLog("$url1&page=$page");
      if (response.statusCode != 200) {
        await SentryService.captureError(
          exception:
              "Failed to load sections $element with status: ${response.statusCode}",
          functionName: 'apiAllSections',
          fileName: 'api_page_main_controller.dart',
        );

        // await messageError("Failed to load sections $index");

        return [];
      } else {
        var res = json.decode(utf8.decode(response.bodyBytes));

        sectionsItem = Item.fromJsonListNewArrival(res["items"]);

        return sectionsItem;
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiAllSections',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 410,
      );
      // await messageError("Failed $e");

      return [];
    }
  }

  Future<List<Item>> apiAllSectionsSubMain(String element, int page) async {
    List<Item> sectionsItem;
    try {
      var url1 = element.replaceAll(RegExp(r'(&page=\d+)'), '');
      var response = await http.get(
        Uri.parse("$url1&page=$page"),
        headers: headers,
      );
      // printLog("$url1&page=$page");
      if (response.statusCode != 200) {
        // await messageError("Failed to load sections $index");
        await SentryService.captureError(
          exception:
              "Failed to load sections $element with status: ${response.statusCode}",
          functionName: 'apiAllSectionsSubMain',
          fileName: 'api_page_main_controller.dart',
        );
        return [];
      } else {
        var res = json.decode(utf8.decode(response.bodyBytes));

        sectionsItem = Item.fromJsonListNewArrival(res["items"]);

        return sectionsItem;
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiAllSectionsSubMain',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 435,
      );
      // await messageError("Failed $e");

      return [];
    }
  }

  Future<List<Item>> specificSection(String element, int page) async {
    List<Item> sectionsItem;
    try {
      var url1 = element.replaceAll(RegExp(r'(&page=\d+)'), '');
      var response = await http.get(
        Uri.parse("$url1&page=$page"),
        headers: headers,
      );
      // printLog("$url1&page=$page");
      if (response.statusCode != 200) {
        await SentryService.captureError(
          exception:
              "Failed to load sections $element with status: ${response.statusCode}",
          functionName: 'specificSection',
          fileName: 'api_page_main_controller.dart',
        );
        // await messageError("Failed to load sections $index");

        return [];
      } else {
        var res = json.decode(utf8.decode(response.bodyBytes));

        sectionsItem = Item.fromJsonListNewArrival(res["items"]);

        return sectionsItem;
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'specificSection',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 460,
      );
      // await messageError("Failed $e");

      return [];
    }
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get Flash sales (flash Sales)
  Future<FlashModel?> apiFlashItems(int page) async {
    FlashModel flash;

    try {
      var response = await http.get(
        Uri.parse("$urlFLASHSALES?page=$page"),
        headers: headers,
      );
      // printLog("$urlFLASHSALES?page=$page");
      if (response.statusCode != 200) {
        await SentryService.captureError(
          exception:
              "Failed to load Flash items with status: ${response.statusCode}",
          functionName: 'apiFlashItems',
          fileName: 'api_page_main_controller.dart',
        );
        // await messageError("Failed to load Flash items");

        return null;
      } else {
        var res = json.decode(utf8.decode(response.bodyBytes));

        flash = FlashModel.fromJson(res);
        return flash;
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiFlashItems',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 510,
      );
      // await messageError("Failed $e");

      return null;
    }
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get Viewed items (viewedItems)
  Future<List<Item>> apiViewedItemsData(int page, String ids) async {
    List<Item> items;

    try {
      // printLog("// get item data //");
      // printLog("${url}getItemsByIds?ids=$ids");
      var response = await http.get(
        Uri.parse("${url}getItemsByIds?ids=$ids"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        items = Item.fromJsonListNewArrival(res['items']);
        return items;
      } else {
        await SentryService.captureError(
          exception:
              "Error!! get items specific $ids with status: ${response.statusCode} the ids= is empty",
          functionName: 'apiViewedItemsData',
          fileName: 'api_page_main_controller.dart',
        );
        // messageError("Error!! get items specific id");
        return [];
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiViewedItemsData',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 540,
      );
      // messageError("Error!! get items specific id : $e");

      return [];
    }
  }

  Future<List<Item>> apiSpecificItemData(String id) async {
    List<Item> items = [];

    try {
      // printLog("// get item data //");
      // printLog("${url}getItemsByIds?ids=$id");
      var response = await http.get(
        Uri.parse("${url}getItemData?id=$id&api_key=$keyBath"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        printLog("${url}getItemData?id=$id&api_key=$keyBath");
        items.add(Item.fromJsonProductBestOrFlash(res['item'], "0", "0", ""));
        return items;
      } else {
        await SentryService.captureError(
          exception:
              "Error!! get items specific $id with status: ${response.statusCode}",
          functionName: 'apiSpecificItemData',
          fileName: 'api_page_main_controller.dart',
        );
        // messageError("Error!! get items specific id");
        return [];
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiSpecificItemData',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 575,
      );
      // messageError("Error!! get items specific id : $e");

      return [];
    }
  }

  //getFirstImages------------------------------------------------------------------------------------------------
  Future<List<FirstImagesModel>> apiReturnFirstImageEachMain() async {
    List<FirstImagesModel> items;

    try {
      // printLog("// get item data //");
      // printLog("${url}ReturnFirstImageEachMain?api_key=$keyBath");
      var response = await http.get(
        Uri.parse("${url}ReturnFirstImageEachMain?api_key=$keyBath"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        items = FirstImagesModel.fromJsonListImagesCategory(res['data']);
        return items;
      } else {
        await SentryService.captureError(
          exception:
              "apiReturnFirstImageEachMain failed with status: ${response.statusCode}",
          functionName: 'apiReturnFirstImageEachMain',
          fileName: 'api_page_main_controller.dart',
        );

        // messageError("Error!! get items specific id");
        return [];
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiReturnFirstImageEachMain',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 605,
      );
      // messageError("Error!! get items specific id : $e");

      return [];
    }
  }

  //----------------------------------------------------------------
  //get items to offer tawseel
  Future<List<Item>> apiOfferTawseelItem(int page) async {
    List<Item> mainProduct;

    try {
      var season = await FirebaseRemoteConfigClass().initilizeConfig();

      var response = await http.get(
        Uri.parse(
          "${url}getAvailableItems?api_key=$keyBath&page=$page&min_price=20&max_price=200&&season=$season",
        ),
        headers: headers,
      );
      printLog(
        "${url}getAvailableItems?api_key=$keyBath&page=$page&min_price=20&max_price=200&&season=$season",
      );
      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        mainProduct = Item.fromJsonListNewArrival(res["items"]);
        // printLog(res["total_items"]);
        return mainProduct;
      } else {
        await SentryService.captureError(
          exception:
              "apiOfferTawseelItem failed with status: ${response.statusCode}",
          functionName: 'apiOfferTawseelItem',
          fileName: 'api_page_main_controller.dart',
        );
      }

      return [];
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiOfferTawseelItem',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 650,
      );
      // messageError("error sliderProduct: $e");
      return [];
    }
  }

  //-----------------------------------------------------------------------------------------------------------------
  // get Order Completed----------------------------------------------------------------------------

  Future<OrderCheckModel> apiOrderCompleted({required String phone}) async {
    OrderCheckModel orderCheck;
    try {
      var response = await http.get(
        Uri.parse("${url}check-order-status?phone=${phone.trim()}"),
        headers: headers,
      );
      // printLog("${url}check-order-status?phone=${phone.trim()}");
      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        orderCheck = OrderCheckModel.fromJson(res);
        // printLog(res);
        return orderCheck;
      } else {
        await SentryService.captureError(
          exception:
              "apiOrderCompleted failed with status: ${response.statusCode}",
          functionName: 'apiOrderCompleted',
          fileName: 'api_page_main_controller.dart',
        );
      }

      return OrderCheckModel(success: false, orderId: 123123);
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiOrderCompleted',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 680,
      );
      // messageError("error sliderProduct: $e");
      return OrderCheckModel(success: false, orderId: 123123);
    }
  }

  Future<Either<Failure, UserActivity>> getUserActivity({
    required String phone,
  }) async {
    final responseUrl = Uri.parse("$urlUserActivity?phone=$phone");

    try {
      final response = await http.get(responseUrl);
      Map<String, dynamic>? json;

      json = jsonDecode(response.body) as Map<String, dynamic>?;
      printLog(response.statusCode);
      if (response.statusCode == 200) {
        final userActivity = UserActivity.fromJson(json ?? {});

        return Right(userActivity);
      }
      // Special case: 404 user not found
      else if (response.statusCode == 404) {
        final message = json?['detail'] as String? ?? "User not found";
        return Left(Failure(404, message));
      }
      // Other errors
      else {
        return Left(Failure(response.statusCode, "Server error"));
      }
    } catch (e) {
      return Left(Failure(500, e.toString()));
    }
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---get Videos (Reels)
  Future<Either<Failure, List<Item>>> apiGetVideos(int page) async {
    try {
      final responseUrl = Uri.parse("$hasVideos&page=$page&api_key=$keyBath");
      printLog("Fetching videos: $responseUrl");

      final response = await http.get(responseUrl, headers: headers);

      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        final items = Item.fromJsonListNewArrival(res["items"] ?? []);

        // Filter items that have videoUrl and exclude Vimeo videos
        final videoItems = items.where((item) {
          if (item.videoUrl == null || item.videoUrl.toString().isEmpty) {
            return false;
          }
          final videoUrl = item.videoUrl.toString().toLowerCase();
          // Drop videos with vimeo in the URL
          return !videoUrl.contains('vimeo');
        }).toList();

        return Right(videoItems);
      } else {
        await SentryService.captureError(
          exception: "apiGetVideos failed with status: ${response.statusCode}",
          functionName: 'apiGetVideos',
          fileName: 'api_page_main_controller.dart',
        );
        return Left(
          Failure(
            response.statusCode,
            "Failed to load videos: ${response.statusCode}",
          ),
        );
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiGetVideos',
        fileName: 'api_page_main_controller.dart',
        lineNumber: 750,
      );
      return Left(Failure(500, e.toString()));
    }
  }
}
