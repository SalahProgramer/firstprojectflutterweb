import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import '../core/services/sentry/sentry_service.dart';
import '../core/utilities/global/app_global.dart';
import '../core/utilities/print_looger.dart';
import 'APIS/api_rating_controller.dart';

class RatingController extends ChangeNotifier {
  double rateSpeedDelivery = 0.0;
  double rateQuality = 0.0;
  double rateSizes = 0.0;
  double rateApp = 0.0;
  bool isLoading = false;
  bool isRating = false;
  String hasPhone = "";
  String text = "";
  ApiRatingController apiRatingController =
      NavigatorApp.context.read<ApiRatingController>();

  TextEditingController descriptionText = TextEditingController();

  Future<void> changeText(String rate) async {
    text = rate;
    notifyListeners();
  }

  Future<void> changeRatingSpeedDelivery(double rate) async {
    rateSpeedDelivery = rate;
    notifyListeners();
  }

  Future<void> changeRateQuality(double rate) async {
    rateQuality = rate;
    notifyListeners();
  }

  Future<void> changeRateSizes(double rate) async {
    rateSizes = rate;
    notifyListeners();
  }

  Future<void> changeRateApp(double rate) async {
    rateApp = rate;
    notifyListeners();
  }

  Future<void> getIsRating() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isRating = prefs.getBool("has_do_rate") ?? false;
    hasPhone = prefs.getString("phone") ?? "";
    notifyListeners();
  }

  Future<void> changeLoading(bool rate) async {
    isLoading = rate;
    notifyListeners();
  }

  Future<void> updateGetRating({
    required String phone,
    required double rate1,
    required double rate2,
    required double rate3,
    required String description,
  }) async {
    try {
      // Fetch user data from Firestore
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // User not found, handle the error or return
        printLog("User not found");
        return;
      } else {
        printLog("User  founded");

        // Assume only one user matches the query
        var userDoc = querySnapshot.docs.first;
        var currentData = userDoc.data();

        // Get current points, default to 0 if not set
        double currentPoints = currentData['points']?.toDouble() ?? 0.0;

        double updatedPoints = currentPoints + 3.0;
        String newLevel = determineLevel(updatedPoints);

        Map<String, dynamic> scores = {
          "speed_delivery": rate1,
          "quality_items": rate2,
          "sizes": rate3,
          "description": description
        };

        // Update user points and level in Firestore
        await userDoc.reference.update({
          'rating': scores,
          'points': updatedPoints,
          'level': newLevel,
        });
      }
    } catch (e, stack) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stack,
        functionName: 'updateGetRating',
        fileName: 'rating_controller.dart',
        lineNumber: 105,
      );
    }
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

  Future<bool> addFeedBckInServer({
    required int orderId,
    required int deliverySpeed,
    required int itemsQuality,
    required int sizesFit,
    required String description,
  }) async {
    return await apiRatingController.apiAddFeedBckInServer(
        deliverySpeed: deliverySpeed,
        description: description,
        itemsQuality: itemsQuality,
        orderId: orderId,
        sizesFit: sizesFit);
  }
}
