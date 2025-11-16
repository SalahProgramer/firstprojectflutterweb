import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../server/domain/domain.dart';
import '../../../server/functions/functions.dart';
import '../../models/items/item_model.dart';
import '../../utilities/sentry_service.dart';

class ApiProductItemController extends ChangeNotifier {
  bool isRequestActive = true;

  Future<void> cancelRequests() async {
    isRequestActive = false;
    notifyListeners();
  }

  Future<void> resetRequests() async {
    isRequestActive = true;
    notifyListeners();
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---Get Item Data ,IDS and all items data( (get data,IDS and all items data)
  Future<List<Item>> apiItemData(Item item,
      {required String sizes,
      bool haveSimilar = true,
      required int page}) async {
    List<Item> allItems = [];

    if (!isRequestActive) return []; // Cancel if flag is false

    try {
      var response = await http.get(
          Uri.parse(
              "$urlSimilarPRODUCT?api_key=$keyBath&id=${item.id.toString()}&include_similar=$haveSimilar&size=$sizes&page=$page"),
          headers: headers);

      printLog(
          "$urlSimilarPRODUCT?api_key=$keyBath&id=${item.id.toString()}&include_similar=$haveSimilar&size=$sizes&page=$page");
      if (!isRequestActive) return []; // Cancel after response

      if (response.statusCode == 200) {
        var res = await jsonDecode(utf8.decode(response.bodyBytes));
        if (page == 1) {
          Item firstItem = Item.fromJsonProduct(res["item"], item.newPrice,
              item.oldPrice, item.videoUrl, item.tags ?? []);
          allItems.add(firstItem);
        }

        if (haveSimilar == true) {
          List<Item> similarItems =
              Item.fromJsonListSimilarProducts(res["similar_items"]);

          allItems.addAll(similarItems);
        }

        return allItems;
      } else {
        await SentryService.captureError(
          exception:
              "Error item data: ${item.id} with status: ${response.statusCode}",
          functionName: 'apiItemData',
          fileName: 'api_product_item.dart',
        );
        // messageError("Error item data: ${response.statusCode}");
        return [];
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiItemData',
        fileName: 'api_product_item.dart',
        lineNumber: 65,
      );
      printLog("Error item data $e");
      // messageError("Error item data $e");
      return [];
      // }
    }
  }

  Future<List<Item>> apiItemDataBestOrFlash(Item item,
      {required String sizes, required int page}) async {
    List<Item> allItems = [];

    if (!isRequestActive) return []; // Cancel if flag is false

    try {
      var response = await http.get(
          Uri.parse(
              "$urlSimilarPRODUCT?api_key=$keyBath&id=${item.id.toString()}&include_similar=true&size=$sizes&page=$page"),
          headers: headers);

      printLog(
          "$urlSimilarPRODUCT?api_key=$keyBath&id=${item.id.toString()}&include_similar=true&size=$sizes&page=$page");

      if (!isRequestActive) return []; // Cancel after response

      if (response.statusCode == 200) {
        var res = await jsonDecode(utf8.decode(response.bodyBytes));
        if (page == 1) {
          Item data = Item.fromJsonProductBestOrFlash(
              res["item"], item.newPrice, item.oldPrice, item.videoUrl);
          allItems.add(data);
        }
        List<Item> similarItems =
            Item.fromJsonListSimilarProducts(res["similar_items"]);

        allItems.addAll(similarItems);
        return allItems;
      } else {
        await SentryService.captureError(
          exception:
              "Error item data: ${item.id} failed with status: ${response.statusCode}",
          functionName: 'apiItemDataBestOrFlash',
          fileName: 'api_product_item.dart',
        );
        // messageError("Error item data: ${response.statusCode}");
        return [];
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiItemDataBestOrFlash',
        fileName: 'api_product_item.dart',
        lineNumber: 110,
      );
      printLog("Error item data $e");
      // messageError("Error item data $e");
      return [];
      // }
    }
  }

  Future<Map<String, dynamic>> apiItemsIds(
      {required String main,
      required String myId,
      required List<Item> allItems,
      required String subMain,
      required String sizes}) async {
    if (!isRequestActive) return {};

    try {
      // printLog(sizes == "null");
      // printLog("jjjjjjjjjjjjjjjjjjjjjjjjjjj");
      var response = await http.get(
          Uri.parse((sizes != "" || sizes != '' || sizes != "null")
              ? "${url}getAvailableItems?main_category=$main&sub_category=$subMain&page=1&size=$sizes&api_key=$keyBath"
              : "${url}getAvailableItems?main_category=$main&sub_category=$subMain&page=1&api_key=$keyBath"),
          headers: headers);

      if (!isRequestActive) return {}; // Cancel after response

      if (response.statusCode == 200) {
        var res = await jsonDecode(utf8.decode(response.bodyBytes));
        // printLog(
        //     "${url}getAvailableItems?main_category=$main&sub_category=$subMain&page=1&tag&api_key=$keyBath");
        //
        // printLog(
        //     "${url}getAvailableItems?main_category=$main&sub_category=$subMain&page=1&size=$sizes&api_key=$keyBath");
        // printLog(res["items"]); // true

        if ((res["items"].isEmpty.toString()) == "true") {
          return {"allItems": "[]", "ids": ""};
        } else {
          List<Item> data = Item.fromJsonListNewArrival(res["items"]);

          if (data.length == 1) {
            return {"allItems": "[]", "ids": ""};
          } else {
            //------------------------------------------add_items-------------------------
            List<Item> newItems = data
                .where((item) =>
                    item.id.toString().trim() != myId.toString().trim())
                .toList();
            allItems.addAll(newItems); // Add sublist
            allItems = allItems.toSet().toList();

            //--------------------------------------------------------
            List<String> idsList = allItems
                .where((item) =>
                    item.id.toString().trim() !=
                    myId.toString().trim()) // Exclude items where id == myId
                .map((item) => item.id.toString())
                .toList();
            String commaSeparatedIds = idsList.join(',');
            // printLog(commaSeparatedIds);

            return {"allItems": allItems, "ids": commaSeparatedIds};
          }
        }
      } else {
        // messageError("Error ids data: ${response.statusCode}");
        await SentryService.captureError(
          exception: "apiItemsIds failed with status: ${response.statusCode}",
          functionName: 'apiItemsIds',
          fileName: 'api_product_item.dart',
        );
        return {"allItems": "[]", "ids": ""};
      }
    } catch (error, stack) {
      await SentryService.captureError(
        exception: error,
        stackTrace: stack,
        functionName: 'apiItemsIds',
        fileName: 'api_product_item.dart',
        lineNumber: 160,
      );
      // messageError("error Ids :$error");

      return {"allItems": "[]", "ids": ""};
    }
  }

  Future<List<Item>> apiAllItemsData(String id, List<Item> allItems) async {
    if (!isRequestActive) return []; // Cancel after response

    try {
      if (id.toString().endsWith(',')) {
        id = id.toString().substring(0, id.toString().length - 1);
      }
      var response = await http.get(
          Uri.parse("$urlSinglePRODUCT?api_key=$keyBath&id=$id"),
          headers: headers);
      if (!isRequestActive) return []; // Cancel after response

      if (response.statusCode == 200) {
        printLog("$urlSinglePRODUCT?api_key=$keyBath&id=$id");

        var res = await jsonDecode(utf8.decode(response.bodyBytes));

        if (allItems.length == 1) {
          Item data = Item.fromJsonProduct(
              res["item"],
              allItems[0].newPrice,
              allItems[0].oldPrice,
              allItems[0].videoUrl,
              allItems[0].tags ?? []);
          return [data];
        } else {
          List<Item> data = Item.fromJsonListProducts(res["item"], allItems);

          return data;
        }
      } else {
        await SentryService.captureError(
          exception:
              "apiAllItemsData failed with status: ${response.statusCode}",
          functionName: 'apiAllItemsData',
          fileName: 'api_product_item.dart',
        );
        // messageError("Error: ${response.statusCode}");
        return [];
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiAllItemsData',
        fileName: 'api_product_item.dart',
        lineNumber: 210,
      );
      printLog(e.toString());
      // messageError("Error all items Data: $e");
      return [];
      // var domainName = await FirebaseRemoteConfigClass().getDomain();
      //
      // var response = await http.get(
      //     Uri.parse("$domainName/api/getItemData?api_key=$keyBath&id=$id"),
      //     headers: headers);
      // if (response.statusCode == 200) {
      //   var res = await jsonDecode(utf8.decode(response.bodyBytes));
      //   Item data = Item.fromJsonProduct(res["item"]);
      //   notifyListeners();
      // } else {
      //   printLog("Error: ${response.statusCode}");
      // }
    }
  }

  //---------------------------------------------------------------------------------------
// get Specific Id from share Url

  Future<Item?> apiGetSpecificProduct(id) async {
    Item item;

    try {
      if (id.toString().endsWith(',')) {
        id = id.toString().substring(0, id.toString().length - 1);
      }
      // printLog("// get item data //");
      // printLog("$urlSinglePRODUCT?api_key=$keyBath&id=$id");
      var response = await http.get(
          Uri.parse("$urlSinglePRODUCT?api_key=$keyBath&id=$id"),
          headers: headers);

      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        item = Item.fromJsonProductSpecificId(res['item']);
        return item;
      } else {
        await SentryService.captureError(
          exception:
              "Error!! get items specific $id with status: ${response.statusCode}",
          functionName: 'apiGetSpecificProduct',
          fileName: 'api_product_item.dart',
        );
        // messageError("Error!! get items specific id");
        return null;
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiGetSpecificProduct',
        fileName: 'api_product_item.dart',
        lineNumber: 260,
      );
      // messageError("Error!! get items specific id : $e");

      return null;
    }
  }
}
