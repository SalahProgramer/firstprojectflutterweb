import 'dart:async';

import 'package:flutter/cupertino.dart';

class TimerController extends ChangeNotifier {
  Duration countDownDuration = Duration();
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  Timer? timer;
}
