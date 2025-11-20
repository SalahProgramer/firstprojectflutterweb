import 'dart:async';

import 'package:flutter/cupertino.dart';

class WheelController extends ChangeNotifier {
  int outComeWheel = 0;

  bool wasShowWheelCoupon = false;

  Future<void> changeWasShowWheelCoupon(bool check) async {
    wasShowWheelCoupon = check;
    notifyListeners();
  }

  Future<void> setOutcomeWheel(int output) async {
    outComeWheel = output;

    notifyListeners();
  }
}
