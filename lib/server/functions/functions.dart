import 'package:fawri_app_refactor/firebase/order/order_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/sub_main_categories_conrtroller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/utilities/size_helper.dart';
import 'package:fawri_app_refactor/services/remote_config_firebase/remote_config_firebase.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../firebase/order/order_firebase_model.dart';
import '../../firebase/used_copons/used_coupos_controller.dart';
import '../../firebase/used_copons/used_coupos_firebase_model.dart';
import '../../salah/localDataBase/models_DB/cart_model.dart';
import '../../salah/models/items/item_model.dart';
import '../../salah/widgets/snackBarWidgets/snack_bar_style.dart';
import '../../salah/widgets/snackBarWidgets/snackbar_widget.dart';
import '../domain/domain.dart';

var headers = {'ContentType': 'application/json', "Connection": "Keep-Alive"};

void printLog(dynamic msg) {
  var logger = Logger();

  if (kDebugMode) {
    logger.d("Fawri: $msg");
  }
}

Future<Map<int, String>> addOrder({
  context,
  address,
  phone,
  city,
  name,
  description,
  total,
  copon,
  required List<CartModel> cartProvider,
  cityID,
  areaName,
  areaID,
  required String hasOrder,
  required String delivery,
}) async {
  try {
    printLog(copon);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('user_id') ?? "";

    List<Map<String, dynamic>> products = [];
    for (var i = 0; i < cartProvider.length; i++) {
      products.add({
        //new
        "sku": cartProvider[i].sku.toString(),
        "image": cartProvider[i].image.toString(),
        "quantity": int.parse(cartProvider[i].quantity.toString()),
        "variant_id": cartProvider[i].variantId.toString(),
      });
    }

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse('$urlAddORDER?api_key=$keyBath'),
    );
    printLog("$urlAddORDER?api_key=$keyBath");

    request.body = (hasOrder == "")
        ? json.encode({
            "name": name.toString(),
            "page": "Fawri App",
            "used_coupon": "$copon",
            "description": description.toString(),
            "phone": phone.toString(),
            "address": address.toString(),
            "city": city.toString(),
            "total_price": double.parse(total.toString()),
            "user_id": 38,
            "location_ids": {
              "city_id": cityID.toString(),
              "area_id": areaID.toString(),
              "area_name": areaName.toString(),
            },
            "products": products,
          })
        : json.encode({
            "name": name.toString(),
            "page": "Fawri App",
            "used_coupon": "$copon",
            "description": description.toString(),
            "phone": phone.toString(),
            "address": address.toString(),
            "city": city.toString(),
            "total_price": double.parse(total.toString()),
            "user_id": 38,
            "location_ids": {
              "city_id": cityID.toString(),
              "area_id": areaID.toString(),
              "area_name": areaName.toString(),
            },
            "has_order": hasOrder,
            "price_drivers": double.parse(delivery.toString()),
            "products": products,
          });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    // Read the stream once
    String responseBody = await response.stream.bytesToString();

    // Decode JSON once
    var jsonData = jsonDecode(responseBody);
    printLog("Decoded JSON: $products");
    printLog("Decoded JSON: $jsonData");

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        (jsonData["order_id"] != null &&
            jsonData["order_id"].toString() != "")) {
      final OrderController orderService = OrderController();
      final UsedCoponsController usedCoponService = UsedCoponsController();
      String orderId = Uuid().v4();
      String usedcoponId = Uuid().v4();
      var now = DateTime.now();
      var formatter = DateFormat('yyyy-MM-dd');
      String formattedDate = formatter.format(now);

      OrderFirebaseModel newItem = OrderFirebaseModel(
        id: orderId,
        trackingNumber: "123456",
        numberOfProducts: cartProvider.length.toString(),
        sum: total.toString(),
        orderId: jsonData["order_id"].toString(),
        userId: userID.toString(),
        createdAt: formattedDate.toString(),
      );
      orderService.addUser(newItem);

      UsedCoponsFirebaseModel newUsedCoponItem = UsedCoponsFirebaseModel(
        id: usedcoponId,
        copon: copon.toString(),
        orderId: jsonData["order_id"].toString(),
        userId: userID.toString(),
      );
      usedCoponService.addUsedCopon(newUsedCoponItem);
      return {response.statusCode: jsonData["order_id"].toString()};
    } else {
      await SentryService.captureError(
        exception: "Order creation failed with status: ${response.statusCode}",
        functionName: "addOrder",
        fileName: "functions.dart",
        lineNumber: 120,
      );
      return {response.statusCode: ""};
    }
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: "addOrder",
      fileName: "functions.dart",
      lineNumber: 125,
    );
    printLog(e.toString());

    return {404: ""};
  }
}

sendNotification({context, userTOKENS, productImage}) async {
  try {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = await prefs.getString('device_token') ?? "-";
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAACwl5eY0:APA91bHHuJ0hAZrN5X9Pxmygq8He3SwM0_2wXsUMC0JaPT3R12FWQnc3A0E9LaDEDieuwHa4lRCeYSObgT5nroTscoUjUA9CX3a6cYG9fa0L0sB-YPvVEqdk5ekMOyb24b8COE_rsuCz',
    };
    List<String> registrationTokens = userTOKENS;
    var request = http.Request(
      'POST',
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
    );
    request.body = json.encode({
      "notification": {
        "title": "Fawri App",
        "image": productImage,
        "body": "المنتج الذي تم اضافته الى السله لم يتبقى منه الا 2",
      },
      "registration_ids": registrationTokens,
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String stream = await response.stream.bytesToString();
      // final decodedMap =
      json.decode(stream);
    } else {
      await SentryService.captureError(
        exception:
            "Notification sending failed with status: ${response.statusCode}",
        functionName: "sendNotification",
        fileName: "functions.dart",
        lineNumber: 250,
      );
      printLog(response.reasonPhrase);
    }
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: "sendNotification",
      fileName: "functions.dart",
      lineNumber: 255,
    );
    printLog("Notification error: $e");
  }
}

Future<List<Item>> getProductByCategory(
  categoryId,
  String subCategoryKey,
  String size,
  String selectedSizes,
  int page,
) async {
  List<Item> item;
  SubMainCategoriesController subMainCategoriesController = NavigatorApp.context
      .read<SubMainCategoriesController>();

  try {
    var subCategoryKeyFinal = subCategoryKey;
    var seasonName = await FirebaseRemoteConfigClass().initilizeConfig();
    var finalURL = "";
    if (size.isNotEmpty && size.toString() != "null" && size.toString() != "") {
      size = expandSizeMappings(size);

      finalURL =
          "$urlProductByCATEGORY?main_category=$categoryId&sub_category=$subCategoryKeyFinal&${size != "null" || size != "" ? "size=$size,ONE SIZE, one-size" : ""}&season=${seasonName.toString()}&page=$page&api_key=$keyBath";
    } else {
        finalURL =
            "$urlProductByCATEGORY?main_category=$categoryId&sub_category=$subCategoryKeyFinal&season=${seasonName.toString()}&page=$page&api_key=$keyBath";
      }

    printLog(
      "$urlProductByCATEGORY?main_category=$categoryId&sub_category=$subCategoryKeyFinal&season=${seasonName.toString()}&page=$page&api_key=$keyBath",
    );
    var response = await http.get(Uri.parse(finalURL), headers: headers);
    if (response.statusCode == 200) {
      var res = json.decode(utf8.decode(response.bodyBytes));

      item = Item.fromJsonListNewArrival(res["items"]);
      await subMainCategoriesController.setTotalItems(res['total_items']);
      return item;
    } else {
      await SentryService.captureError(
        exception:
            "Product category fetch failed with status: ${response.statusCode}",
        functionName: "getProductByCategory",
        fileName: "functions.dart",
        lineNumber: 350,
      );
      return [];
    }
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: "getProductByCategory",
      fileName: "functions.dart",
      lineNumber: 355,
    );
    return [];
  }
}
Future<bool> cancelOrder(
  int orderId,
  String reason,
  BuildContext context,
  String phone,
  int totalDiscountAfterDelete,
) async {
  final String url1 = '${url}cancelOrder';
  try {
    final response = await http.get(
      Uri.parse('$url1?order_id=$orderId&reason=$reason&api_key=$keyBath'),
    );
    printLog("$url1?order_id=$orderId&reason=$reason&api_key=$keyBath");

    if (response.statusCode == 200) {
      var res = json.decode(utf8.decode(response.bodyBytes));
      if (res["message"].toString().contains("not in Pending status") == true) {
        showSnackBar(
          title: "لا يمكنك إلغاء الطلب لأنه ليس في حالة انتظار",
          type: SnackBarType.error,
        );
        NavigatorApp.pop();

        return false;
      } else {
        showSnackBar(
          title: "تم إلغاء الطلبية بنجاح",
          type: SnackBarType.success,
        );
        NavigatorApp.pop();
        return true;
      }
    } else {
      await SentryService.captureError(
        exception:
            "Order cancellation failed with status: ${response.statusCode}  فشلت عملية الإلغاء , الرجاء المحاولة مرة أخرى",
        functionName: "cancelOrder",
        fileName: "functions.dart",
        lineNumber: 420,
      );
      NavigatorApp.pop();
      // messageError('فشلت عملية الإلغاء , الرجاء المحاولة مرة أخرى');
      return false;
    }
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: "cancelOrder",
      fileName: "functions.dart",
      lineNumber: 425,
    );
    printLog('Error: $e');
    NavigatorApp.pop();

    // messageError('فشلت عملية الإلغاء , الرجاء المحاولة مرة أخرى');
    return false;
  }
}

getCoupun(code) async {
  try {
    var finalUrl = "$urlCOPUN?code=$code&redeem=false&api_key=$keyBath";
    var response = await http.post(Uri.parse(finalUrl), headers: headers);
    if (response.statusCode == 200) {
      var res = json.decode(utf8.decode(response.bodyBytes));
      return res["discount_amount"];
    } else {
      await SentryService.captureError(
        exception:
            "Coupon validation failed with status: ${response.statusCode}",
        functionName: "getCoupun",
        fileName: "functions.dart",
        lineNumber: 450,
      );
      return "false";
    }
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: "getCoupun",
      fileName: "functions.dart",
      lineNumber: 455,
    );
    return "false";
  }
}

getCoupunDeleteCose() async {
  try {
    var finalUrl = "$urlDELETECOST?api_key=$keyBath";
    var response = await http.get(Uri.parse(finalUrl), headers: headers);
    if (response.statusCode == 200) {
      var res = json.decode(utf8.decode(response.bodyBytes));
      return res;
    } else {
      await SentryService.captureError(
        exception:
            "Delete cost fetch failed with status: ${response.statusCode}",
        functionName: "getCoupunDeleteCose",
        fileName: "functions.dart",
        lineNumber: 470,
      );
      return "false";
    }
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: "getCoupunDeleteCose",
      fileName: "functions.dart",
      lineNumber: 475,
    );
    return "false";
  }
}

getCoupunRedeem(code) async {
  try {
    var finalUrl = "$urlCOPUN?code=$code&redeem=true&api_key=$keyBath";
    var response = await http.post(Uri.parse(finalUrl), headers: headers);
    // var res =
    json.decode(utf8.decode(response.bodyBytes));
  } catch (e, stack) {
    await SentryService.captureError(
      exception: e,
      stackTrace: stack,
      functionName: "getCoupunRedeem",
      fileName: "functions.dart",
      lineNumber: 490,
    );
  }
}
