import 'package:fawri_app_refactor/server/functions/functions.dart';

class EnumPointsStatus {
  final DateTime? lastDate;
  final DateTime? nextUseDate;
  final bool canUse;

  EnumPointsStatus({this.lastDate, this.nextUseDate, required this.canUse});

  factory EnumPointsStatus.fromJson(Map<String, dynamic> json) {
    return EnumPointsStatus(
      lastDate: json['last_date'] != null
          ? DateTime.tryParse(json['last_date'])
          : null,
      nextUseDate: json['next_use_date'] != null
          ? DateTime.tryParse(json['next_use_date'])
          : null,
      canUse: json['can_use'] ?? true,
    );
  }

  // Create a default status with canUse = true (for empty maps)
  factory EnumPointsStatus.defaultStatus({bool canUse = false}) {
    return EnumPointsStatus(lastDate: null, nextUseDate: null, canUse: canUse);
  }

  // Calculate days remaining until next use
  int get daysUntilNextUse {
    if (canUse) return 0;

    final DateTime dateNew = DateTime.now();
    final Duration difference = nextUseDate!.difference(dateNew);

    // If the time is already passed, return 0
    if (difference.isNegative) return 0;

    // Round up: if there are leftover hours/minutes, count it as 1 more day
    final int daysLeft = (difference.inHours / 24).ceil();

    printLog("daysUntilNextUse: $daysLeft");
    printLog("nextUseDate: $nextUseDate");
    printLog("now: $dateNew");

    return daysLeft;
  }

  // Get formatted time remaining
  String get formattedTimeRemaining {
    if (nextUseDate == null) return "متاح قريباَ";

    final days = daysUntilNextUse;

    if (days > 0) {
      return "متبقي ${_getArabicDaysText(days)}";
    } else {
      return "متاح قريباَ";
    }
  }

  // Helper method to convert days to Arabic text
  String _getArabicDaysText(int days) {
    if (days == 1) return "يوم واحد";
    if (days == 2) return "يومان";
    if (days >= 3 && days <= 10) return "$days أيام";
    if (days == 11) return "أحد عشر يوماً";
    if (days == 12) return "اثنا عشر يوماً";
    if (days >= 13 && days <= 19) return "$days يوماً";
    if (days == 20) return "عشرون يوماً";
    if (days == 21) return "واحد وعشرون يوماً";
    if (days == 22) return "اثنان وعشرون يوماً";
    if (days >= 23 && days <= 29) return "$days يوماً";
    if (days == 30) return "ثلاثون يوماً";
    if (days >= 31) return "$days يوماً";
    return "$days يوم";
  }

  // Check if enough time has passed since last use
  bool get canUseNow {
    if (canUse) return true;
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'last_date': lastDate?.toIso8601String(),
      'next_use_date': nextUseDate?.toIso8601String(),
      'can_use': canUse,
    };
  }

  @override
  String toString() {
    return 'EnumPointsStatus(lastDate: $lastDate, nextUseDate: $nextUseDate, canUse: $canUse)';
  }
}
