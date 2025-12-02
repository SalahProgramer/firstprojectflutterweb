import 'dart:convert';

import 'package:fawri_app_refactor/salah/models/constants/constant_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../server/domain/domain.dart';
import '../../../server/functions/functions.dart';
import '../../../services/remote_config_firebase/remote_config_firebase.dart';
import '../../models/items/item_model.dart';
import '../../utilities/sentry_service.dart';

class ApiMainProductController extends ChangeNotifier {
  TextEditingController? textController;
  bool isFirstLoadRunning = false;
  bool isLoadMoreRunning = false;
  bool noInternet = false;
  int page = 1;

//---------------------------------------------------------------------------------
// get Slider Products

  Future<List<Item>> apiGetTagProducts(String tag, page) async {
    List<Item> mainProduct;
    try {
      var response = await http.get(
          Uri.parse(
              "${url}getAvailableItems?api_key=$keyBath&page=$page&tag=$tag"),
          headers: headers);
      printLog("${url}getAvailableItems?api_key=$keyBath&page=$page&tag=$tag");
      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));

        mainProduct = Item.fromJsonListNewArrival(res["items"]);

        return mainProduct;
      } else {
        await SentryService.captureError(
          exception:
              "apiGetTagProducts failed with status: ${response.statusCode}",
          functionName: 'apiGetTagProducts',
          fileName: 'api_main_product_controller.dart',
        );
      }

      return [];
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiGetTagProducts',
        fileName: 'api_main_product_controller.dart',
      );
      // messageError("error sliderProduct: $e");
      return [];
    }
  }

//---------------------------------------------------------------------------------
// get Products
  Future<List<Item>> apiGetProducts(int page) async {
    // final cacheManager = CacheManager();
    // final cacheKey = 'products_page_$page';
    // final cachedData = await cacheManager.getCache(cacheKey);
    var seasonName = await FirebaseRemoteConfigClass().initilizeConfig();

    try {
      var response = await http.get(
          Uri.parse(
              "${url}getAllItems?api_key=$keyBath&season=${seasonName.toString()}&page=$page"),
          headers: headers);
      printLog(
          "new    : : : : ${url}getAllItems?api_key=$keyBath&season=${seasonName.toString()}&page=$page");
      var res = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        var e = Item.fromJsonListNewArrival(res["items"]);

        return e;
      } else {
        await SentryService.captureError(
          exception:
              "apiGetProducts failed with status: ${response.statusCode}",
          functionName: 'apiGetProducts',
          fileName: 'api_main_product_controller.dart',
        );
        return [];
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiGetProducts',
        fileName: 'api_main_product_controller.dart',
        lineNumber: 75,
      );
      // messageError("$e");
      return [];
    }
  }

  //--------------dynamic Sliders---------------------------------------------
  Future<List<Item>> apiSlidersProducts(String url1, int num) async {
    List<Item> mainProduct;
    url1 = url1.replaceAll("page=1", "page=$num");
    try {
      var response = await http.get(Uri.parse(url1), headers: headers);

      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));

        mainProduct = Item.fromJsonListNewArrival(res["items"]);

        return mainProduct;
      } else {
        await SentryService.captureError(
          exception:
              "apiSlidersProducts failed with status: ${response.statusCode}",
          functionName: 'apiSlidersProducts',
          fileName: 'api_main_product_controller.dart',
        );
      }

      return [];
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiSlidersProducts',
        fileName: 'api_main_product_controller.dart',
        lineNumber: 100,
      );
      // messageError("error sliderProduct: $e");
      return [];
    }
  }

  //---------------------------------------------------------------------------------
// get category Search(main,subMain,tags)

  Future<List<Item>> apiSearchItem(
    CategoryModel category,
    int page,
    String season,
  ) async {
    List<Item> mainProduct;
    String mainCat = category.mainCategory;
    String subCat = category.subCategory ?? "";
    if (mainCat != "") {
      mainCat = mainCat.replaceAll("&", "%26");
    }

    if (subCat != "") {
      subCat = subCat.replaceAll("&", "%26");
      subCat = subCat.replaceAll(
          "Women Sports Bras %26 Intimates, Women Sports Bras  Intimates, Plus Size Sports Bra, Sports %26 Outdoor Accessories",
          "Women Sports Bras & Intimates, Women Sports Bras  Intimates, Plus Size Sports Bra, Sports & Outdoor Accessories");
    } else if (subCat == "") {
      subCat = category.subCategory!.replaceAll("&", "%26");
    }
    try {
      var response = await http.get(
          Uri.parse((mainCat != "" && subCat == "")
              ? "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&season=$season"
              : (mainCat == "" && subCat == "")
                  ? "${url}getAvailableItems?api_key=$keyBath&page=$page&tag=${category.name}"
                  : (mainCat == "" && subCat != "")
                      ? "${url}getAvailableItems?api_key=$keyBath&page=$page&sub_category=$subCat&season=$season"
                      : "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$subCat&season=$season"),
          headers: headers);
      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        mainProduct = Item.fromJsonListNewArrival(res["items"]);
        return mainProduct;
      } else {
        await SentryService.captureError(
          exception: "apiSearchItem failed with status: ${response.statusCode}",
          functionName: 'apiSearchItem',
          fileName: 'api_main_product_controller.dart',
        );
      }

      return [];
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiSearchItem',
        fileName: 'api_main_product_controller.dart',
        lineNumber: 160,
      );
      // messageError("error sliderProduct: $e");
      return [];
    }
  }

  //---------------------------------------------------------------------------------
// get category filter(main,subMain,tags,price)

  Future<List<Item>> apiFilterItem(
    CategoryModel category,
    String sub,
    String sizes,
    CategoryModel tag,
    String min,
    String max,
    int page,
    String season,
  ) async {
    List<Item> mainProduct;
    String mainCat = category.mainCategory;
    try {
      if (sub != "") {
        sub = sub.replaceAll("&", "%26");
        sub = sub.replaceAll(
            "Women Sports Bras %26 Intimates, Women Sports Bras  Intimates, Plus Size Sports Bra, Sports %26 Outdoor Accessories",
            "Women Sports Bras & Intimates, Women Sports Bras  Intimates, Plus Size Sports Bra, Sports & Outdoor Accessories");
      } else if (sub == "" && sizes == "") {
        sub = category.subCategory!.replaceAll("&", "%26");
        if (category.mainCategory == "Women Apparel" &&
            (category.name == "مقاسات كبيرة")) {
          sizes = "0XL,1XL,2XL,3XL,4XL,5XL,XL,XXL,XXXL";
        }
      }

      if (mainCat != "") {
        mainCat = mainCat.replaceAll("&", "%26");
      }

      var response = await http.get(
          Uri.parse(((min == "0.0" && max == "1000.0") ||
                  (min == "0.0" && max == "0.0"))
              ? (sizes == "")
                  ? "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$sub&tag=${tag.name}&season=$season"
                  : "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$sub&size=$sizes,ONE SIZE,one-size&tag=${tag.name}&season=$season"
              : (sizes == "")
                  ? "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$sub&tag=${tag.name}&min_price=$min&max_price=$max&&season=$season"
                  : "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$sub&size=$sizes,ONE SIZE,one-size&tag=${tag.name}&min_price=$min&max_price=$max&&season=$season"),
          headers: headers);
      printLog(
          "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$sub&tag=${tag.name}&season=$season");
      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        mainProduct = Item.fromJsonListNewArrival(res["items"]);
        printLog(res["total_items"]);
        return mainProduct;
      } else {
        await SentryService.captureError(
          exception: "apiFilterItem failed with status: ${response.statusCode}",
          functionName: 'apiFilterItem',
          fileName: 'api_main_product_controller.dart',
        );
      }

      return [];
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiFilterItem',
        fileName: 'api_main_product_controller.dart',
        lineNumber: 220,
      );
      // messageError("error sliderProduct: $e");
      return [];
    }
  }

  //---------------------------------------------------------------------------------
// get tags Search

  // Future<List<CategoryModel>> apiGetTag() async {
  //   List<CategoryModel> tags;
  //   if (await isConnectedWifi()) {
  //     try {
  //       var response = await http
  //           .get(Uri.parse("${url}getTags?api_key=$keyBath"), headers: headers);
  //
  //       if (response.statusCode == 200) {
  //         var res = json.decode(utf8.decode(response.bodyBytes));
  //         tags = CategoryModel.fromJsonListTags(res);
  //         return tags;
  //       }
  //
  //       return [];
  //     } catch (e) {
  //       // messageError("error sliderProduct: $e");
  //       return [];
  //     }
  //   } else {
  //     noConnection();
  //
  //     return [];
  //   }
  // }

//-------------------------------------------------------------------------------------
  // get category Search(Ids || SKU)

  Future<List<Item>> apiSearchIdORSku(String idORsku) async {
    List<Item> mainProduct;
    try {
      idORsku = idORsku;
      var response = await http.get(
          Uri.parse(
              "${url}getAvailableItems?api_key=$keyBath&page=$page&id=$idORsku"),
          headers: headers);
      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        mainProduct = Item.fromJsonListNewArrival(res["items"]);
        return mainProduct;
      } else {
        await SentryService.captureError(
          exception:
              "apiSearchIdORSku failed with status: ${response.statusCode}",
          functionName: 'apiSearchIdORSku',
          fileName: 'api_main_product_controller.dart',
        );
      }

      return [];
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiSearchIdORSku',
        fileName: 'api_main_product_controller.dart',
        lineNumber: 275,
      );
      // messageError("error sliderProduct: $e");
      return [];
    }
  }

//-----------------------------------------------------------------------------------
  //---------------------------------------------------------------------------------
// get pop Up Shoes-------------------------------------------

  Future<List<Item>> apiPopUpShoesItem(
    int page,
    String subCat,
    String season,
  ) async {
    List<Item> mainProduct;
    try {
      var response = await http.get(
          Uri.parse(
              "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=Shoes&sub_category=$subCat&season=$season"),
          headers: headers);
      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        mainProduct = Item.fromJsonListNewArrival(res["items"]);
        return mainProduct;
      } else {
        await SentryService.captureError(
          exception:
              "apiPopUpShoesItem failed with status: ${response.statusCode}",
          functionName: 'apiPopUpShoesItem',
          fileName: 'api_main_product_controller.dart',
        );
      }

      return [];
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiPopUpShoesItem',
        fileName: 'api_main_product_controller.dart',
        lineNumber: 310,
      );
      // messageError("error sliderProduct: $e");
      return [];
    }
  }
}
