import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

void printLog(dynamic msg) {
  var logger = Logger();
  if (kDebugMode) {
    logger.d("Fawri: $msg");
  }
}