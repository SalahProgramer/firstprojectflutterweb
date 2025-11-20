import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/domain.dart';
import '../../core/services/sentry/sentry_service.dart';
import '../../core/utilities/print_looger.dart';

class ApiBirthdayController extends ChangeNotifier {
  Future<bool> apiAddBirthday({
    required String phone,
    required bool isMale,
    required String birthday,
  }) async {
    try {
      var url1 = '${userUrl}update-info';
      var headers = {'Content-Type': 'application/json'};

      // Raw JSON body
      var body = jsonEncode({
        'phone': phone,
        'isMale': isMale, // keep as bool
        'birthday': birthday,
      });

      var response = await http.post(
        Uri.parse(url1),
        headers: headers,
        body: body,
      );

      printLog("Status: ${response.statusCode}");
      printLog("Response: ${response.body}");

      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        printLog(res["message"]);
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        await SentryService.captureError(
          exception:
              "added birthday failed with status: ${response.statusCode}",
          functionName: 'apiAddBirthday',
          fileName: 'api_birthday_controller.dart',
          lineNumber: 120,
        );
        return false;
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'apiAddBirthday',
        fileName: 'api_birthday_controller.dart',
        lineNumber: 40,
      );
      printLog('Error update birthday user: $e');
      return false;
    }
  }
}
