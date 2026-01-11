import 'package:fawri_app_refactor/salah/controllers/fetch_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class BoxArrival extends StatelessWidget {
  const BoxArrival({super.key});

  @override
  Widget build(BuildContext context) {
    FetchController fetchController = context.watch<FetchController>();
    return Padding(
      padding: (fetchController.showEven == 1)
          ? EdgeInsets.only(top: 2.h)
          : EdgeInsets.zero,
      child: Container(
        height: 30.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: (fetchController.showEven != 0)
                ? ((fetchController.showEven == 1)
                      ? [Colors.white, Colors.white]
                      : [
                          CustomColor.eidColor,
                          CustomColor.eidColor.withValues(alpha: 0.7),
                        ])
                : [
                    CustomColor.primaryColor,
                    CustomColor.primaryColor.withValues(alpha: 0.7),
                  ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(name: "وصل حديثا", showEven: fetchController.showEven),
              text(name: "New Arrival", showEven: fetchController.showEven),
            ],
          ),
        ),
      ),
    );
  }

  Text text({required String name, required int showEven}) {
    return Text(
      name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14.sp,
        color: (showEven == 1) ? CustomColor.primaryColor : Colors.white,
      ),
    );
  }
}
