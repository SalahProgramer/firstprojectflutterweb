import 'package:fawri_app_refactor/firebase/order/order_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/sub_main_categories_conrtroller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/services/remote_config_firebase/remote_config_firebase.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  if (kDebugMode) {
    print("Fawri: $msg");
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
    var request =
        http.Request('POST', Uri.parse('$urlAddORDER?api_key=$keyBath'));
    printLog(
        "$urlAddORDER?api_key=$keyBath");

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
              "area_name": areaName.toString()
            },
            "products": products
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
              "area_name": areaName.toString()
            },
            "has_order": hasOrder,
            "price_drivers": double.parse(delivery.toString()),
            "products": products
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
        (jsonData["order_id"] != null && jsonData["order_id"].toString() != "")) {
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
          createdAt: formattedDate.toString());
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
          'key=AAAACwl5eY0:APA91bHHuJ0hAZrN5X9Pxmygq8He3SwM0_2wXsUMC0JaPT3R12FWQnc3A0E9LaDEDieuwHa4lRCeYSObgT5nroTscoUjUA9CX3a6cYG9fa0L0sB-YPvVEqdk5ekMOyb24b8COE_rsuCz'
    };
    List<String> registrationTokens = userTOKENS;
    var request =
        http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "notification": {
        "title": "Fawri App",
        "image": productImage,
        "body": "المنتج الذي تم اضافته الى السله لم يتبقى منه الا 2"
      },
      "registration_ids": registrationTokens
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

Future<List<Item>> getProductByCategory(categoryId, String subCategoryKey,
    String size, String selectedSizes, int page) async {
  List<Item> item;
  SubMainCategoriesController subMainCategoriesController =
      NavigatorApp.context.read<SubMainCategoriesController>();

  try {
    var subCategoryKeyFinal = subCategoryKey;
    var seasonName = await FirebaseRemoteConfigClass().initilizeConfig();
    var finalURL = "";
    if (size.isNotEmpty && size.toString() != "null" && size.toString() != "") {
      printLog(size);
      //
      size = processSizesStringToString(size);
      printLog(size);
      if (categoryId == "Women Apparel") {
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
        finalURL =
            "$urlProductByCATEGORY?main_category=$categoryId&sub_category=$subCategoryKeyFinal&size=$size,ONE SIZE, one-size&season=${seasonName.toString()}&page=$page&api_key=$keyBath";
      }
      printLog(categoryId);
      printLog(size);

      finalURL =
          "$urlProductByCATEGORY?main_category=$categoryId&sub_category=$subCategoryKeyFinal&${size != "null" || size != "" ? "size=$size,ONE SIZE, one-size" : ""}&season=${seasonName.toString()}&page=$page&api_key=$keyBath";
    } else {
      if (categoryId == "Women Apparel" &&
          subCategoryKeyFinal ==
              "Plus Size Dresses, Plus Size Bottoms, Plus Size Outerwears, Plus Size Knitwear, Plus Size Denim, Plus Size Tops, Plus Size Co-Ords, Plus Size Co Ords, Women Plus Party Wear, Women Plus Wedding, Women Plus Beachwear, Plus Size Suits, Plus Size Jumpsuits %26 Bodysuits, Plus Size Jumpsuits Bodysuits, Plus Size Arabian Wear,Women Clothing, Women Dresses, Women Bottoms, Women Outerwear, Women Knitwear, Women Denim, Women Tops, Women Sweatshirts, Women T-Shirts, Women Blouses, Women Tank Tops Camis, Women T Shirts, Arabian Wear, Women Co-ords, Women Co ords, Women Wedding, Women Party Wear, Weddings %26 Events, Women Beachwear, Women Suits, Women Jumpsuits %26 Bodysuits, Women Jumpsuits Bodysuits, Women Tops, Blouses %26 Tee, Women Tops,Blouses %26 Tee, Women Tops, Blouses Tee, Women Tops Blouses %26 Tee, Underwear %26 Sleepwear, Apparel Accessories, Jewelry %26 Watches, Beauty %26 Health, Women Shoes") {
        printLog(size);
        //

        size = "0XL,1XL,2XL,3XL,4XL,5XL,XL,XXL,XXXL";
        printLog(size);
        finalURL =
            "$urlProductByCATEGORY?main_category=$categoryId&sub_category=$subCategoryKeyFinal&size=$size,ONE SIZE, one-size&season=${seasonName.toString()}&page=$page&api_key=$keyBath";
      } else {
        finalURL =
            "$urlProductByCATEGORY?main_category=$categoryId&sub_category=$subCategoryKeyFinal&season=${seasonName.toString()}&page=$page&api_key=$keyBath";
      }

      // printLog(finalURL);
    }
    // if (selectedSizes != '' && selectedSizes.toString() != "null") {
    //   printLog(selectedSizes.toString()+"jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj");
    //
    //   finalURL += "&size=$selectedSizes";
    // }
    printLog("Final_URL");
    printLog("Final_URL");
    printLog(subCategoryKeyFinal);
    printLog(page);
    printLog(
        "$urlProductByCATEGORY?main_category=$categoryId&sub_category=$subCategoryKeyFinal&season=${seasonName.toString()}&page=$page&api_key=$keyBath");
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

String convertSizeLabel(String size) {
  switch (size) {
    case "XL":
      return "1XL";
    case "XXL":
      return "2XL";
    case "XXXL":
      return "3XL";
    case "XXXXL":
      return "4XL";
    case "XXXXXL":
      return "5XL";
    default:
      return size; // Other sizes remain unchanged
  }
}

String processSizesStringToString(String sizes) {
  // Split the input by commas to process each size individually
  List<String> sizeList = sizes.split(',');
  List<String> processedSizes = [];

  for (String size in sizeList) {
    processedSizes.addAll(processSize(size.trim()));
    if (size.contains("-")) {
      processedSizes.add(size);
    }
  }

  // Join the processed sizes back into a single string separated by commas
  return processedSizes.join(',');
}

List<String> processSize(String size) {
  size = size.trim();

  // If the size contains a dash and does not have a space, split it
  if (size.contains('-') && !size.contains(' ') && size.contains('سنة')) {
    List<String> parts = size.split('-');
    // Only add "سنة" if it is not already included
    return parts
        .map((part) => part.trim() + (part.contains('سنة') ? '' : 'سنة'))
        .toList();
  }

  // If the size contains a dash and has a space (e.g., "9-10 سنة"), handle it
  if (size.contains('-') && size.contains(' ') && size.contains('سنة')) {
    List<String> parts = size.split(' '); // Split at space first
    List<String> ranges = parts[0].split('-');
    // Add "سنة" only if it's not already there
    return ranges
        .map((part) => part.trim() + (part.contains('سنة') ? '' : ' سنة'))
        .toList();
  }
  if (size.contains('-') && !size.contains(' ') && !size.contains('سنة')) {
    List<String> parts = size.split('-');
    // Only add "سنة" if it is not already included
    return parts.map((part) => part.trim()).toList();
  }


  return [size]; // For cases where size is already correct
}

Future<bool> cancelOrder(int orderId, String reason, BuildContext context,
    String phone, int totalDiscountAfterDelete) async {
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
            type: SnackBarType.error);
        NavigatorApp.pop();

        return false;
      } else {
        showSnackBar(
            title: "تم إلغاء الطلبية بنجاح", type: SnackBarType.success);
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
