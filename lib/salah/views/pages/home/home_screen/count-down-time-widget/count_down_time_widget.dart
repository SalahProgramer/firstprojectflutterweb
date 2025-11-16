import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../constants/constant_data_convert.dart';
import '../../../../../controllers/page_main_screen_controller.dart';

class CountdownTimerWidget extends StatefulWidget {
  final bool hasAPI;
  final String type; // Assuming this is the initial time in "HH:MM:SS" format
  const CountdownTimerWidget(
      {super.key, required this.hasAPI, required this.type});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  String? endDate;
  Duration remainingTime = Duration.zero;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PageMainScreenController pageMainScreenController =
          context.read<PageMainScreenController>();
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
          'end_date_falsh', pageMainScreenController.flash?.endDate ?? "");
      endDate = pageMainScreenController.flash?.endDate.toString() ?? "";

      if (endDate != "") {
        _startCountdown();
      }
    });
    _loadEndDate();
  }

  // Load `endDate` from SharedPreferences
  Future<void> _loadEndDate() async {}

  // Start countdown based on `endDate`
  void _startCountdown() {
    DateTime endDateTime = DateTime.parse(endDate!);
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime = endDateTime.difference(DateTime.now());
        if (remainingTime.isNegative) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    return "${duration.inHours}:${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60)}";
  }

  @override
  Widget build(BuildContext context) {
    return (_formatDuration(remainingTime) != "0:0:0")
        ? (remainingTime.inHours > 0)
            ? Visibility(
                visible: widget.hasAPI,
                child: Opacity(
                  opacity: 0.7,
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    color: mainColor,
                    child: Center(
                      child: Text(
                        widget.type != "flash_sales"
                            ? widget.type
                            : "ينتهي خلال  ${_formatDuration(remainingTime)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox()
        : SizedBox();
  }
}
