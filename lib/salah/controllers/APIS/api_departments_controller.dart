import 'dart:convert';

import 'package:fawri_app_refactor/salah/controllers/departments_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../server/domain/domain.dart';
import '../../../server/functions/functions.dart';
import '../../models/constants/constant_model.dart';
import '../../models/items/item_model.dart';
import '../../utilities/sentry_service.dart';
import '../../utilities/size_helper.dart';

class ApiDepartmentsController extends ChangeNotifier {
  Future<List<Item>> apiPerfumeItem({
    required CategoryModel category,
    required String sub,
    required String sizes,
    required int page,
    required int numSort,
    required String selectTag,
    required String season,
    int? requestVersion,
  }) async {
    printLog("apiPerfumeItem selectTag: $selectTag"); // Check received value

    List<Item> mainProduct;
    DepartmentsController departmentsController = NavigatorApp.context
        .read<DepartmentsController>();
    String mainCat = category.mainCategory;
    try {
      if (sub != "") {
        sub = sub.replaceAll("&", "%26");
      } else if (sub == "" && sizes == "") {
        sub = category.subCategory!.replaceAll("&", "%26");
      
      }

      if (mainCat != "") {
        mainCat = mainCat.replaceAll("&", "%26");
      }

      // Handle size mappings
      if (sizes != "") {
        sizes = expandSizeMappings(sizes);
      }

      printLog("sizes"+ sizes.toString());
      var response = await http.get(
        Uri.parse(
          (sizes == "" && selectTag == "")
              ? "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$sub&season=$season&sorting_mode=$numSort"
              : (sizes == "" && selectTag != "")
              ? "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$sub&tag=$selectTag&season=$season&sorting_mode=$numSort"
              : "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$sub&tag=$selectTag&size=$sizes,ONE SIZE,one-size&season=$season&sorting_mode=$numSort",
        ),
        headers: headers,
      );
      printLog(
        (sizes == "" && selectTag == "")
            ? "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$sub&season=$season&sorting_mode=$numSort"
            : (sizes == "" && selectTag != "")
            ? "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$sub&tag=$selectTag&season=$season&sorting_mode=$numSort"
            : "${url}getAvailableItems?api_key=$keyBath&page=$page&main_category=$mainCat&sub_category=$sub&tag=$selectTag&size=$sizes,ONE SIZE,one-size&season=$season&sorting_mode=$numSort",
      );
      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        mainProduct = Item.fromJsonListNewArrival(res["items"]);
        if (requestVersion == null ||
            departmentsController.isRequestVersionActive(requestVersion)) {
          await departmentsController.setTotalItems(res['total_items']);
          printLog(
            res["items"].isEmpty,
          ); // This will return true if the list is empty.

          if (res["items"].isEmpty) {
          } else {
            await departmentsController.setPagesShow(res['page']);
          }
        }
        return mainProduct;
      } else {
        await SentryService.captureError(
          exception: "api Item failed with status: ${response.statusCode}",
          functionName: 'apiPerfumeItem',
          fileName: 'api_departments_controller.dart',
          lineNumber: 35,
        );
      }

      return [];
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiPerfumeItem',
        fileName: 'api_departments_controller.dart',
        lineNumber: 70,
      );
      // messageError("error sliderProduct: $e");
      return [];
    }
  }
}
