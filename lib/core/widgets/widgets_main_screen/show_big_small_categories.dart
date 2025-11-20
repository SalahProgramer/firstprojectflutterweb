import 'package:fawri_app_refactor/controllers/fetch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/core/utilities/style/text_style.dart';

class ShowBigSmallCategories extends StatelessWidget {
  final double? turn;
  final Color? color;
  final bool? isWhite;
  final void Function()? onTap;
  final bool isCategory;
  final MainAxisAlignment? alignment;

  const ShowBigSmallCategories(
      {super.key,
      this.turn,
      this.onTap,
      this.alignment,
      this.color,
      this.isWhite = true,
      this.isCategory = false});

  @override
  Widget build(BuildContext context) {
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    FetchController fetchController = context.watch<FetchController>();
    return InkWell(
      onTap: onTap ??
          () async {
            await pageMainScreenController.changeBigCategories();
          },
      overlayColor: WidgetStateColor.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(2.w),
        margin: EdgeInsets.all(2.w),
        alignment: Alignment.centerRight,
        width: double.maxFinite,
        child: Row(
          mainAxisAlignment: alignment ?? MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Text(
                  (pageMainScreenController.setBigCategories && isCategory)
                      ? "أعرض بشكل أقل"
                      : "أعرض بشكل أوسع",
                  style: CustomTextStyle().heading1L.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      height: 1.2.h,
                      color: color ??
                          ((fetchController.showEven == 1 && isWhite == true)
                              ? Colors.white
                              : Color.fromARGB(255, 21, 101, 167))),
                ),
              ],
            ),
            SizedBox(
              width: 4.w,
            ),
            AnimatedRotation(
              turns: turn ??
                  ((pageMainScreenController.setBigCategories && isCategory)
                      ? 1.25
                      : 1),
              duration: Duration(milliseconds: 1000),
              child: Icon(
                Icons.arrow_circle_left_outlined,
                color: color ??
                    ((fetchController.showEven == 1 && isWhite == true)
                        ? Colors.white
                        : Color.fromARGB(255, 21, 101, 167)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
