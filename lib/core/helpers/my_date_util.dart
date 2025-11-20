import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utilities/global/app_global.dart';

class MyDateUtil {
  static String getFormatedTime({
    required BuildContext context,
    required String time,
    bool onlyTime = false,
  }) {
    DateTime parsed = DateTime.parse(time);

    // Ensure it’s UTC first
    DateTime utcDateTime = parsed.toUtc();

    // Convert to Palestine time (UTC+3)
    DateTime palestineDateTime = utcDateTime.add(const Duration(hours: 6));

    // Format
    if (onlyTime) {
      return DateFormat('hh:mm a', "ar").format(palestineDateTime);
    }

    return DateFormat('yyyy-MM-dd hh:mm a', "en").format(palestineDateTime);
  }

  static String getLastMessageTime(
      {required BuildContext context,
      required String time,
      bool showYear = false}) {
    DateTime utcDateTime = DateTime.parse(time).toUtc();
    Duration palestineTimeOffset = const Duration(hours: 6);
    DateTime sent = utcDateTime.add(palestineTimeOffset);
    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }

    return showYear
        ? '${sent.day} ${getMonth(sent)} ${sent.year}'
        : '${sent.day} ${getMonth(sent)}';
  }

  static String getMessageTime({required String time, bool showYear = false}) {
    DateTime utcDateTime = DateTime.parse(time).toUtc();
    Duration palestineTimeOffset = const Duration(hours: 3);
    DateTime sent = utcDateTime.add(palestineTimeOffset);
    final DateTime now = DateTime.now();
    final formatTime =
        TimeOfDay.fromDateTime(sent).format(NavigatorApp.context);

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return '$formatTime - ${"اليوم"}';
    }

    String weekday = DateFormat.EEEE("en").format(sent);

    return now.year == sent.year
        ? '$formatTime - ${sent.day} $weekday'
        : '$formatTime - ${sent.day} $weekday ${sent.year}';
  }

  static String getLastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;

    if (i == -1) {
      return 'آخر ظهور غير متاح';
    }

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    final DateTime now = DateTime.now();

    if (now.day == time.day &&
        now.month == time.month &&
        now.year == time.year) {
      return 'آخر ظهور اليوم عند ${TimeOfDay.fromDateTime(time).format(context)}';
    }

    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'آخر ظهور أمس عند ${TimeOfDay.fromDateTime(time).format(context)}';
    }

    String month = getMonth(time);

    return 'آخر ظهور بتاريخ ${time.day} $month عند ${TimeOfDay.fromDateTime(time).format(context)}';
  }

  static String getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'يناير';
      case 2:
        return 'فبراير';
      case 3:
        return 'مارس';
      case 4:
        return 'أبريل';
      case 5:
        return 'مايو';
      case 6:
        return 'يونيو';
      case 7:
        return 'يوليو';
      case 8:
        return 'أغسطس';
      case 9:
        return 'سبتمبر';
      case 10:
        return 'أكتوبر';
      case 11:
        return 'نوفمبر';
      case 12:
        return 'ديسمبر';
    }
    return 'غير معروف';
  }
}
