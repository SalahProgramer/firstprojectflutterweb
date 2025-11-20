import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import '../../../controllers/points_controller.dart';
import '../../../core/helpers/my_date_util.dart';
import '../../../core/utilities/global/app_global.dart';
import '../../../core/utilities/style/colors.dart';
import '../../../core/utilities/style/text_style.dart';
import '../../../core/widgets/app_bar_widgets/app_bar_custom.dart';
import '../../../core/widgets/lottie_widget.dart';
import '../../../core/widgets/points_widgets/date_widget.dart';
import '../../../core/widgets/points_widgets/points_widget.dart';


class UsersPointsPage extends StatelessWidget {
  const UsersPointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    PointsController pointsController = context.watch<PointsController>();

    final Map<int, String> pointIcons = {
      1: Assets.icons.bird,
      2: Assets.icons.wheel,
      3: Assets.icons.sizes,
      4: Assets.icons.review,
      5: Assets.icons.buy,
      6: Assets.icons.redeemPoints,
      7: Assets.icons.cancelOrder,
    };
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: "",
        textButton: "رجوع",
        textColor: Colors.white,
        onPressed: () {
          NavigatorApp.pop();
        },
        actions: [],
        colorWidgets: Colors.white,
      ),
      body: Container(
          // alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CustomColor.deepPurple,
                CustomColor.mediumPurple,
                CustomColor.brightBlue,
                CustomColor.skyBlue,
                CustomColor.lightBlue,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            image: DecorationImage(
              filterQuality: FilterQuality.high,
              fit: BoxFit.cover,
              image: AssetImage(Assets.images.backg.path),
            ),
          ),
          child: SafeArea(
              top: true,
              bottom: false,
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  spacing: 10.h,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("مجموع النقاط",
                                      style: CustomTextStyle().cairo),
                                  Text("${pointsController.points} نقطة",
                                      style: CustomTextStyle().cairo.copyWith(
                                            fontWeight: FontWeight.w700,
                                          )),
                                  Text(
                                    "رصيدك الحالي : ${pointsController.shekel} شيكل",
                                    style: CustomTextStyle().cairo.copyWith(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w200,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Image(
                                image: AssetImage(
                                  Assets.images.fawriArabic.path,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String phone = prefs.getString('phone') ?? "";
                          await pointsController.getPointsFromAPI(phone: phone);
                        },
                        strokeWidth: 2,
                        color: CustomColor.blueColor,
                        child: Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50.r),
                              topRight: Radius.circular(50.r),
                            ),
                          ),
                          child: (pointsController.historyPoints == null ||
                                  (pointsController.historyPoints!.isEmpty))
                              ? Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 5.h,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 20.w),
                                        child: LottieWidget(
                                          name: Assets.lottie.noPoints,
                                        ),
                                      ),
                                      Text("لا يوجد بيانات",
                                          style:
                                              CustomTextStyle().cairo.copyWith(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ))
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding:
                                      EdgeInsets.only(right: 20.w, top: 20.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 10.h,
                                    children: [
                                      Text(
                                        'تاريخ النقاط',
                                        style:
                                            CustomTextStyle().pacifico.copyWith(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.black,
                                                ),
                                      ),
                                      Expanded(
                                        child: ListView.separated(
                                          separatorBuilder: (context, index) =>
                                              SizedBox(
                                            height: 10.h,
                                          ),
                                          itemCount: pointsController
                                              .historyPoints!.length,
                                          padding: EdgeInsets.only(
                                              bottom: 20.h, right: 5.w),
                                          itemBuilder: (context, index) {
                                            final currentPoint =
                                                pointsController
                                                    .historyPoints![index];

                                            // Format the date into yyyy-MM-dd (ignore time part)
                                            final currentDate =
                                                DateFormat('yyyy-MM-dd').format(
                                                    DateTime.parse(currentPoint
                                                        .date
                                                        .toIso8601String()));

                                            // Previous item’s date (if exists)
                                            String? previousDate;
                                            if (index > 0) {
                                              final prevPoint = pointsController
                                                  .historyPoints![index - 1];
                                              previousDate = DateFormat(
                                                      'yyyy-MM-dd')
                                                  .format(DateTime.parse(
                                                      prevPoint.date
                                                          .toIso8601String()));
                                            }
                                            // Show header only if first item OR different date than previous
                                            bool showHeader = (index == 0 ||
                                                currentDate != previousDate);

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (showHeader)
                                                  DateTitle(
                                                    label: currentDate ==
                                                            DateFormat(
                                                                    'yyyy-MM-dd')
                                                                .format(DateTime
                                                                    .now())
                                                        ? "اليوم"
                                                        : MyDateUtil
                                                                .getFormatedTime(
                                                            context: context,
                                                            time: currentPoint
                                                                .date
                                                                .toIso8601String(),
                                                          )
                                                            .split(" ")
                                                            .first, // just date part
                                                  ),
                                                PointTile(
                                                  amount: currentPoint.value,
                                                  title: currentPoint.reason,
                                                  date: MyDateUtil
                                                      .getFormatedTime(
                                                          context: context,
                                                          time: currentPoint
                                                              .date
                                                              .toIso8601String(),
                                                          onlyTime: true),
                                                  pointicon: pointIcons[
                                                          currentPoint
                                                              .enumPoint] ??
                                                      "heart",
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ]))),
    );
  }
}
