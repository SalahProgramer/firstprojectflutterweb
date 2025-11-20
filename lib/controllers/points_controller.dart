import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/sentry/sentry_service.dart';
import '../core/utilities/print_looger.dart';
import '../core/utilities/global/app_global.dart';
import '../models/points.dart';
import 'APIS/api_points_controller.dart';

class PointsController extends ChangeNotifier {
  String points = "";
  List<HistoryItem>? historyPoints;
  int shekel = 0;

  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneProfileController = TextEditingController();
  TextEditingController nameProfileController = TextEditingController();

  TextEditingController pointsController = TextEditingController();
  ApiPointsController apiPointsController =
      NavigatorApp.context.read<ApiPointsController>();
  String shekelText = "0.00";
  bool loadingSaveProfile = false;
  String textPoint = "";
  String textPointDo = "";
  String valueCode = "+970";
  String pointsMessage = "first";

  //------------------------------we used in first order later------------------------------------

  double discount = 0.00;
  double discountCoupoun = 0.00;
  double discountpoint = 0.00;
  bool pointApplied = false;
  double total = 0.00;
  double totalItems = 0.00;
  double oldTotal = 0.00;

  Future<void> changeAllDiscount(double dis) async {
    discount = dis;
    notifyListeners();
  }

  Future<void> changePhone(String value) async {
    phoneProfileController.text = value;
    notifyListeners();
  }

  Future<void> changePointsApplied(bool check) async {
    pointApplied = check;
    notifyListeners();
  }

  Future<void> changeLoadingSaveProfile(bool check) async {
    loadingSaveProfile = check;
    notifyListeners();
  }

  Future<void> setChangeText(String text) async {
    textPointDo = text;
    notifyListeners();
  }

  Future<void> clearAllDataPointPage() async {
    discount = 0.00;
    discountCoupoun = 0.00;
    discountpoint = 0.00;
    pointApplied = false;
    total = 0.00;
    totalItems = 0.00;
    oldTotal = 0.00;
    pointsController.text = "";
    shekelText = "0.00";

    textPoint = "";

    pointsMessage = "first";
    notifyListeners();
  }

  Future<void> clearAllDataCouponPage() async {
    discountCoupoun = 0.00;
    discount = discountpoint - discountCoupoun;
    if (discount < 0) {
      discount = 0;
    }

    total = totalItems - discount;
    if (total < 0) {
      total = 0;
    }
    notifyListeners();
  }

  Future<void> changeDiscountCoupon(double dis) async {
    discountCoupoun = dis;
    notifyListeners();
  }

  Future<void> changeDiscountPoints(double dis) async {
    discountpoint = dis;
    notifyListeners();
  }

  Future<void> changeTotalItems(double dis) async {
    if (totalItems != dis) {
      totalItems = dis;
      notifyListeners();
    }
  }

  Future<void> changeTotal(double dis) async {
    double newTotal = dis < 0 ? 0 : dis;
    if (total != newTotal) {
      total = newTotal;
      notifyListeners();
    }
  }

  Future<void> clearTotal() async {
    if (total != 0.00) {
      total = 0.00;
      notifyListeners();
    }
  }

  void changeMessegePoint(String massege) {
    pointsMessage = massege;
    notifyListeners();
  }

  Future<void> changeValueCountryCode(String value) async {
    valueCode = value;
    notifyListeners();
  }

  double calculatePoints(double totalAmount) {
    return totalAmount;
  }

  double calculateValueInNIS(double points1) {
    double points = (points1 / 100) * 2;
    textPoint = points.toString();
    return points; // Since 1 point = 1 NIS
  }

  String determineLevel(double points) {
    if (points > 6000) {
      return 'Platinum';
    } else if (points >= 4000 && points <= 6000) {
      return 'Gold';
    } else if (points >= 2000 && points < 4000) {
      return 'Silver';
    } else {
      return 'No Level'; // Optional, if below 40 points
    }
  }

  // for endpoint (firebase/api)----------------------------------------------------------------------------------------------

  Future<void> updateUserPointsAndLevel(
      {required String phone,
      required String newAmount,
      required int enumNumber}) async {
    try {
      if (phone != "") {
        printLog("ssssss");

        await updatePointsFromAPI(
            phone: phone,
            newPoints: newAmount.toString(),
            enumNumber: enumNumber);
        printLog("ssssss2");
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'updateUserPointsAndLevel',
        fileName: 'points_controller.dart',
        lineNumber: 195,
      );
    }
  }

  Future<void> updateUserPointsAndLevelWhenDoSelectSize(
      {required String phone,
      required String newAmount,
      required int enumNumber,
      String gender = "",
      String sizes = ""}) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (querySnapshot.docs.isEmpty) {
        printLog("User not found");
        return;
      } else {
        printLog("User  founded");
        await updatePointsFromAPI(
            phone: phone, newPoints: newAmount, enumNumber: enumNumber);
        var userDoc = querySnapshot.docs.first;
        await userDoc.reference.update({'sizes': sizes, 'gender': gender});
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'updateUserPointsAndLevelWithoutMinus',
        fileName: 'points_controller.dart',
        lineNumber: 251,
      );
    }
  }

  Future<void> getUserPointsAndLevel(String phone) async {
    try {
      if (phone != "") {
        var querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: phone)
            .get();

        if (querySnapshot.docs.isEmpty) {
          printLog("User not found");
          points = "0";
          shekel = 0;
          historyPoints = [];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('points', points.toString());
        } else {
          // Assume only one user matches the query
          var userDoc = querySnapshot.docs.first;
          var userData = userDoc.data();

          // Retrieve points and level
          double points1 = (userData['points'] ?? 0).toDouble();
          points = points1.round().toString();

          shekel = calculateValueInNIS(double.tryParse(points) ?? 0).toInt();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('points', points.toString());
        }
        // String level = userData['level'] ?? 'No Level';
      } else {
        points = "0";
        shekel = 0;
        historyPoints = [];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('points', points.toString());
      }
      notifyListeners();
    } catch (e, stack) {
      points = "0";
      shekel = 0;
      historyPoints = [];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('points', points.toString());
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'getUserPointsAndLevel',
        fileName: 'points_controller.dart',
        lineNumber: 282,
      );
    }
  }

  Future<void> getPointsFromAPI(
      {required String phone, bool includeHistory = true}) async {
    final result = await apiPointsController.getPoints(
        phone: phone, includeHistory: includeHistory);

    result.fold(
      (failure) async {
        SentryService.captureError(
          exception: Exception("Error [${failure.code}]: ${failure.message}"),
        );

        points = "0";
        shekel = 0;
        historyPoints = [];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('points', points.toString());

        notifyListeners();
      },
      // RIGHT = Points
      (rightPoints) async {
        points = rightPoints.points.round().toString();

        shekel = calculateValueInNIS(double.tryParse(points) ?? 0).toInt();
        historyPoints = rightPoints.history;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('points', points.toString());
        notifyListeners();

        printLog("✅ Success: ${rightPoints.points} points");
      },
    );
  }

  Future<void> updatePointsFromAPI({
    required String phone,
    bool includeHistory = false,
    required String newPoints,
    required int enumNumber,
  }) async {
    printLog("error22222");

    final result = await apiPointsController.updatePoints(
        phone: phone,
        value: int.tryParse(newPoints) ?? 0, // safer parsing

        enumNumber: enumNumber);

    result.fold(
      (failure) async {
        // printLog("error");
        SentryService.captureError(
          exception: Exception("Error [${failure.code}]: ${failure.message}"),
        );

        return;
      },
      // RIGHT = Points
      (rightPoints) async {
        points = rightPoints.updatedPoints.round().toString();

        shekel = calculateValueInNIS(double.tryParse(points) ?? 0).toInt();
        historyPoints = rightPoints.history;

        printLog("✅ Success: ${rightPoints.points} points");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('points', points.toString());
        notifyListeners();
      },
    );
  }
}
