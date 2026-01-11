import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:fawri_app_refactor/salah/models/points.dart';
import 'package:fawri_app_refactor/salah/utilities/typedefs/failure.dart';
import 'package:fawri_app_refactor/server/domain/domain.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiPointsController extends ChangeNotifier {
  Future<Either<Failure, Points>> getPoints({
    required String phone,
    bool includeHistory = false,
  }) async {
    final responseUrl = Uri.parse(
      "${userUrl}get_points?phone=$phone&include_history=$includeHistory",
    );

    try {
      final response = await http.get(responseUrl);
      Map<String, dynamic>? json;

      json = jsonDecode(response.body) as Map<String, dynamic>?;
      printLog(response.statusCode);
      if (response.statusCode == 200) {
        final points = Points.fromJson(json ?? {});

        return Right(points);
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

  Future<Either<Failure, Points>> updatePoints({
    required String phone,
    required int value,
    required int enumNumber,
  }) async {
    printLog("ddddddddd");

    final responseUrl = Uri.parse("${userUrl}update_points");

    final body = jsonEncode({
      "phone": phone,
      "value": value,
      "enum_reson": enumNumber,
      "reason": "",
    });
    printLog("ddddddddd2");

    try {
      final response = await http.post(
        responseUrl,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      Map<String, dynamic>? json;

      json = jsonDecode(response.body) as Map<String, dynamic>?;
      printLog(json);
      if (response.statusCode == 200) {
        final points = Points.fromJson(json?['user'] ?? {});
        return Right(points);
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
}
