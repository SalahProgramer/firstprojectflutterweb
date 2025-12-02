import 'dart:convert';

import 'package:fawri_app_refactor/salah/models/available_model.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../server/domain/domain.dart';
import '../../../server/functions/functions.dart';

class ApiCartController extends ChangeNotifier {
  //------------------------------------------------------------------------------------------
  //check items availability
  Future<List<AvailableModel>> apiCheckProductAvailability(
      List<Map<String, dynamic>> items) async {
    List<AvailableModel> availabilityItems = [];

    try {
      var url1 = '${url}checkProductAvailabilityListM';
      var headers = {'Content-Type': 'application/json'};
      var body = json.encode({'items': items});


      var response =
      await http.post(Uri.parse(url1), headers: headers, body: body);
      printLog("apiCheckProductAvailability: $response");
      printLog("apiCheckProductAvailability: ${response.body}");

          await http.post(Uri.parse(url1), headers: headers, body: body);
      if (response.statusCode == 200) {
        var res = json.decode(response.body);

        availabilityItems = AvailableModel.fromJsonList(res['items']);

        return availabilityItems;
      } else {

        await SentryService.captureError(
          exception:
              "api Check Product Availability failed with status: ${response.statusCode}",
          functionName: 'apiCheckProductAvailability',
          fileName: 'api_cart_controller.dart',
          lineNumber: 35,
        );

        return [];
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiCheckProductAvailability',
        fileName: 'api_cart_controller.dart',
        lineNumber: 35,
      );
      printLog('Error checking product availability: $e');
      return [];
    }
  }
}
