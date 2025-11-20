import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/domain.dart';
import '../../core/services/sentry/sentry_service.dart';
import '../../core/utilities/print_looger.dart';
import '../../models/order/order_detail_model.dart';
import '../../models/user/order_check_model.dart';

class ApiOrderController extends ChangeNotifier {
  Future<Map<List<OrderDetailModel>, int>> apiGetAllOrderDetails({
    required String phone,
    required String type,
    required int page,
  }) async {
    List<OrderDetailModel> ordersDetails = [];
    try {
      final uri = Uri.parse(
          "$urlOrderDETAILS?phoneNumber=$phone&type=$type&page=$page&api_key=$keyBath");

      printLog("Request URL: $uri");

      var response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        printLog(
            "ERROR: Failed to fetch order details, Status Code:  {response.statusCode}");

        await SentryService.captureError(
          exception:
              "apiGetAllOrderDetails failed with status: ${response.statusCode}",
          functionName: 'apiGetAllOrderDetails',
          fileName: 'api_order_controlller.dart',
        );
        return {[]: 0};
      }

      var bodyString = utf8.decode(response.bodyBytes);
      printLog("API raw response: $bodyString");

      var res = json.decode(bodyString);

      if (res is Map && res.containsKey("orders") && res["orders"] != null) {
        ordersDetails = OrderDetailModel.fromJsonListOrderItems(res["orders"]);
        printLog("Order details count:  {ordersDetails.length}");
        return {ordersDetails: res["total_orders"]};
      } else {
        printLog("ERROR: 'orders' key is missing or null in response");

        return {[]: 0};
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiGetAllOrderDetails',
        fileName: 'api_order_controlller.dart',
        lineNumber: 48,
      );
      printLog("EXCEPTION: $e");
      // await messageError("Failed: $e");
      return {[]: 0};
    }
  }

  Future<OrderCheckModel> apiCheckPendingOrder({required String phone}) async {
    OrderCheckModel orderCheck;
    try {
      var response = await http.get(
          Uri.parse("${url}check-pending-order?phone=${phone.trim()}"),
          headers: headers);
      // printLog("${url}check-order-status?phone=${phone.trim()}");
      if (response.statusCode == 200) {
        var res = json.decode(utf8.decode(response.bodyBytes));
        orderCheck = OrderCheckModel.fromJson(res);
        // printLog(res);
        return orderCheck;
      } else {
        await SentryService.captureError(
          exception:
              "apiCheckPendingOrder failed with status: ${response.statusCode}",
          functionName: 'apiCheckPendingOrder',
          fileName: 'api_order_controlller.dart',
        );
      }

      return OrderCheckModel(success: false, orderId: 123123);
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiCheckPendingOrder',
        fileName: 'api_order_controlller.dart',
        lineNumber: 71,
      );
      // messageError("error sliderProduct: $e");
      return OrderCheckModel(success: false, orderId: 123123);
    }
  }
}
