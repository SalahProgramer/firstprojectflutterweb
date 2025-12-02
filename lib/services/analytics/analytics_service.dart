import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() => _instance;

  AnalyticsService._internal();

  final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
  static final FacebookAppEvents facebookAppEvents = FacebookAppEvents();

  // static Future<void> initialize() async {
  // }

  static Future<void> logAppLaunch() async {
    printLog('Facebook App Events initialized');
    await facebookAppEvents.logEvent(name: 'app_launch');
    printLog('Logged app launch event');
  }

  /// Log an event to both Firebase and Facebook
  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    // Firebase
    try {
      await firebaseAnalytics.logEvent(
        name: eventName,
        parameters:
            parameters == null ? null : Map<String, Object>.from(parameters),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Analytics Error: $e');
      }
    }

    // Facebook
    try {
      // Facebook requires all values as Strings
      final fbParams =
          parameters?.map((key, value) => MapEntry(key, value.toString()));

      await facebookAppEvents.logEvent(
        name: eventName,
        parameters: fbParams,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Facebook Analytics Error: $e');
      }
    }

    if (kDebugMode) {
      print('Logged event "$eventName" to both Firebase and Facebook.');
    }
  }

  /// Log a purchase to both Firebase and Facebook
  Future<void> logPurchase({
    required double amount,
    Map<String, String>? parameters,
  }) async {
    // Firebase
    try {
      await firebaseAnalytics.logEvent(
        name: 'purchase',
        parameters: {
          'amount': amount,
          ...?parameters,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Purchase Error: $e');
      }
    }

    // Facebook
    try {
      await facebookAppEvents.logPurchase(
        amount: amount,
        currency: "NIS",
        parameters: parameters,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Facebook Purchase Error: $e');
      }
    }

    if (kDebugMode) {
      print('Logged purchase to both Firebase and Facebook.');
    }
  }

  Future<void> logAddToCart({
    required String productId,
    required String productTitle,
    int quantity = 1,
    double price = 0.0,
    Map<String, String>? parameters,
  }) async {
    final eventParams = {
      "name": "AddToCart",
      "product_id": productId,
      "product_title": productTitle,
      "quantity": quantity,
      "price": price,
      "time": DateTime.now().toString(),
    };

    // Firebase
    try {
      await firebaseAnalytics.logEvent(
        name: "add_to_cart",
        parameters: Map<String, Object>.from(eventParams),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Firebase AddToCart Error: $e');
      }
    }

    // Facebook
    try {
      await facebookAppEvents.logAddToCart(
        id: productId,
        price: price,
        content: eventParams,
        type: '',
        currency: "NIS",
      );
    } catch (e) {
      if (kDebugMode) {
        print('Facebook Purchase Error: $e');
      }
    }

    if (kDebugMode) {
      print('Logged "add_to_cart" event to both Firebase and Facebook.');
    }
  }

  /// Log a "view content" event to both Firebase and Facebook
  Future<void> logViewContent({
    required String contentId,
    required String contentType,
    String? contentTitle,
    double? price,
    Map<String, dynamic>? parameters,
  }) async {
    final eventParams = {
      "name": "ViewContent",
      "content_id": contentId,
      "content_type": contentType,
      if (contentTitle != null) "content_title": contentTitle,
      if (price != null) "price": price,
      "time": DateTime.now().toString(),
      ...?parameters,
    };

    // Firebase
    try {
      await firebaseAnalytics.logEvent(
        name: "view_content",
        parameters: Map<String, Object>.from(eventParams),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Firebase ViewContent Error: $e');
      }
    }

    // Facebook
    try {
      await facebookAppEvents.logViewContent(
        id: contentId,
        content: parameters,
        price: price,
        currency: "NIS",
      );
    } catch (e) {
      if (kDebugMode) {
        print('Facebook ViewContent Error: $e');
      }
    }

    if (kDebugMode) {
      print('Logged "view_content" event to both Firebase and Facebook.');
    }
  }

  /// Log an "initiated checkout" event to both Firebase and Facebook
  Future<void> logInitiatedCheckout({
    required String checkoutId,
    required List<String> productIds,
    double? totalPrice,
    String currency = "NIS",
    Map<String, dynamic>? parameters,
  }) async {
    final eventParams = {
      "name": "initiated_checkout",
      "checkout_id": checkoutId,
      "product_ids": productIds.join(','),
      if (totalPrice != null) "total_price": totalPrice,
      "currency": currency,
      "time": DateTime.now().toString(),
      ...?parameters,
    };

    // Firebase
    try {
      await firebaseAnalytics.logEvent(
        name: "initiated_checkout",
        parameters: Map<String, Object>.from(eventParams),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Firebase InitiatedCheckout Error: $e');
      }
    }

    // Facebook
    try {
      await facebookAppEvents.logInitiatedCheckout(
        contentId: productIds.join(','),
        totalPrice: totalPrice,
        numItems: productIds.length,
        currency: "NIS",
      );
    } catch (e) {
      if (kDebugMode) {
        print('Facebook InitiatedCheckout Error: $e');
      }
    }

    if (kDebugMode) {
      print('Logged "initiated_checkout" event to both Firebase and Facebook.');
    }
  }

  Future<void> logAddToWishlist({
    required String productId,
    required String productTitle,
    int quantity = 1,
    double price = 0.0,
    Map<String, String>? parameters,
  }) async {
    final eventParams = {
      "name": "AddToWishlist",
      "product_id": productId,
      "product_title": productTitle,
      "quantity": quantity,
      "price": price,
      "time": DateTime.now().toString(),
      ...?parameters,
    };

    // Firebase
    try {
      await firebaseAnalytics.logEvent(
        name: "add_to_wishlist",
        parameters: Map<String, Object>.from(eventParams),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Firebase AddToWishlist Error: $e');
      }
    }

    // Facebook (log as a custom event)
    try {
      await facebookAppEvents.logAddToWishlist(
        currency: "NIS",
        content: eventParams,
        id: productId,
        type: '',
        price: price,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Facebook AddToWishlist Error: $e');
      }
    }

    if (kDebugMode) {
      print('Logged "add_to_wishlist" event to both Firebase and Facebook.');
    }
  }
}
