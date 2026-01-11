import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/items/item_model.dart';
import '../utilities/global/app_global.dart';
import 'APIS/api_page_main_controller.dart';
import 'APIS/api_product_item.dart';

class FreeGiftController extends ChangeNotifier {
  int theTime = 0; // وقت المستخدم بالثواني
  bool repeat = true;
  bool repeatShow = true;
  DateTime? lastGiftDate; // تاريخ آخر مكافأة
  Timer? timer;
  Item theItemFree = Item(id: 0, title: "");

  ApiPageMainController api = NavigatorApp.context
      .read<ApiPageMainController>();
  ApiProductItemController api2 = NavigatorApp.context
      .read<ApiProductItemController>();

  /// **بدء تشغيل المؤقت عند فتح التطبيق**
  void userTimeFreeGiftDoTimer() {
    loadTheTime();
    startTimer();
  }

  /// **تشغيل المؤقت**
  void startTimer() {
    timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      theTime++;
      checkGiftEligibility(); // التحقق من إمكانية الحصول على الهدية
      saveTheTime();
      notifyListeners();
    });
  }

  /// **تحميل بيانات الوقت والهدية**
  Future<void> loadTheTime() async {
    final prefs = await SharedPreferences.getInstance();
    theTime = prefs.getInt('time_free_gift') ?? 0;
    String? lastGiftDateString = prefs.getString('last_gift_date');

    if (lastGiftDateString != null) {
      lastGiftDate = DateTime.parse(lastGiftDateString);
    }

    checkGiftEligibility(); // التحقق من إمكانية الحصول على هدية جديدة
    notifyListeners();
  }

  Future<void> changeRepeatLottie(bool check) async {
    repeat = check;
    notifyListeners();
  }

  /// **حفظ البيانات بعد تحديث الوقت**
  Future<void> saveTheTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('time_free_gift', theTime);
    if (lastGiftDate != null) {
      await prefs.setString('last_gift_date', lastGiftDate!.toIso8601String());
    }
  }

  /// **إعادة ضبط الوقت عند بدء التطبيق من جديد**
  Future<void> initialTimerFreeGift() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('time_free_gift', 0);
  }

  /// **تمييز أن المستخدم حصل على الهدية**
  Future<void> markGiftAsGiven() async {
    lastGiftDate = DateTime.now();
    saveTheTime();
    notifyListeners();
  }

  /// **التأكد من مرور شهر قبل منح هدية جديدة**
  void checkGiftEligibility() {
    if (lastGiftDate == null) return;

    DateTime now = DateTime.now();
    DateTime nextGiftDate = DateTime(
      lastGiftDate!.year,
      lastGiftDate!.month + 1,
      lastGiftDate!.day,
    );

    if (now.isAfter(nextGiftDate)) {
      notifyListeners();
    }
  }

  /// **التحقق مما إذا كان المستخدم يمكنه استلام هدية**
  Future<bool> canUse() async {
    if (lastGiftDate == null) return true;
    DateTime now = DateTime.now();
    DateTime nextGiftDate = DateTime(
      lastGiftDate!.year,
      lastGiftDate!.month + 1,
      lastGiftDate!.day,
    );
    //
    // printLog("the timer: $now");
    // printLog("the timer: $nextGiftDate");
    return now.isAfter(nextGiftDate);
  }

  /// **إيقاف المؤقت عند إغلاق التطبيق**
  Future<void> disposeTimerFreeGift() async {
    timer?.cancel();
    super.dispose();
  }

  /// **جلب بيانات العنصر المجاني**
  Future<void> getItemsViewedData({required String id}) async {
    var short = await api.apiSpecificItemData(id);
    theItemFree = short[0];
    notifyListeners();
  }

  Future<void> changeShow({required bool check}) async {
    repeatShow = check;
    notifyListeners();
  }
}
