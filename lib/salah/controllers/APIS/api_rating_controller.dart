import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import '../../../server/domain/domain.dart';
import '../../../server/functions/functions.dart';
import 'package:http/http.dart' as http;

class ApiRatingController extends ChangeNotifier {
  Future<bool> apiAddFeedBckInServer({
    required int orderId,
    required int deliverySpeed,
    required int itemsQuality,
    required int sizesFit,
    required String description,
  }) async {
    try {
      var url1 = '${url}createFeedback';

      var headers1 = {
        'Content-Type': 'application/json', // 🔹 Send request as JSON
        'Accept': 'application/json',
      };

      var body = jsonEncode({
        "order_id": orderId, // Keep as integer
        "delivery_speed": deliverySpeed,
        "items_quality": itemsQuality,
        "sizes_fit": sizesFit,
        "notes": description, // Keep as string
      });

      printLog("Sending feedback request...");
      printLog(url1);

      var response = await http.post(
        Uri.parse(url1),
        headers: headers1,
        body: body, // ✅ Properly encoded body
      );

      printLog("${response.statusCode} Sending feedback request...");
      printLog("Sending feedback request...${response.body}");

      if (response.statusCode == 201) {
        return true;
      } else {
        await SentryService.captureError(
          exception:
              "        حدث خطأ غير متوقع أثناء معالجة الطلب failed with status: ${response.statusCode}",
          functionName: 'apiAddFeedBckInServer',
          fileName: 'api_rating_controller.dart',
        );
        // messageError("حدث خطأ غير متوقع أثناء معالجة الطلب");
        return false;
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiAddFeedBckInServer',
        fileName: 'api_rating_controller.dart',
        lineNumber: 54,
      );
      printLog('Error update birthday user: $e');
      return false;
    }
  }
}
