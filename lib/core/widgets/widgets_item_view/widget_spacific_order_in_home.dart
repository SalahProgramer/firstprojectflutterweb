import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/order/order_detail_model.dart';
import '../../../views/pages/orders/order_details.dart';
import '../../utilities/global/app_global.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../custom_button.dart';
import '../lottie_widget.dart';
import '../snackBarWidgets/snack_bar_style.dart';
import '../snackBarWidgets/snackbar_widget.dart';
import 'button_done.dart';

class WidgetSpacificOrderInHome extends StatefulWidget {
  final int index;
  final OrderDetailModel newestOrder;
  final String userId;

  const WidgetSpacificOrderInHome(
      {super.key,
      required this.index,
      required this.newestOrder,
      required this.userId});

  @override
  State<WidgetSpacificOrderInHome> createState() =>
      _WidgetSpacificOrderInHomeState();
}

class _WidgetSpacificOrderInHomeState extends State<WidgetSpacificOrderInHome> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 4.w),
      child: Row(
        children: [
          Text(
            "${widget.index + 1}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyle().heading1L.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
          ),
          Expanded(
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              elevation: 7,
              shadowColor: CustomColor.blueColor,
              shape: RoundedRectangleBorder(
                  // side: BorderSide(color: Colors.black, width: 1),

                  borderRadius: BorderRadius.circular(10.r)),
              color: Colors.white,
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                ),
                child: Container(
                    height: 0.146.sh,
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.yellowAccent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              "حالة طلبك",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            LottieWidget(
                              name: Assets.lottie.order,
                              width: 35.w,
                              height: 35.w,
                            ),
                            Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Add spacing between the elements
                                  Text(
                                    "${double.parse(widget.newestOrder.totalPrice.toString()).toStringAsFixed(1)} ₪",
                                    textAlign: TextAlign.center,
                                    style: CustomTextStyle().heading1L.copyWith(
                                          color: CustomColor.chrismasColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                        ),
                                  ),
                                ]),
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                (widget.newestOrder.status?.toLowerCase() ==
                                        "shipped")
                                    ? "تم الشحن"
                                    : (widget.newestOrder.status
                                                ?.toLowerCase() ==
                                            "pending")
                                        ? "يتم تجهيز طلبك"
                                        : "",
                                style: TextStyle(
                                    color: (widget.newestOrder.status
                                                ?.toLowerCase() ==
                                            "shipped")
                                        ? Colors.green.shade700
                                        : (widget.newestOrder.status
                                                        ?.toLowerCase() ==
                                                    "pending" ||
                                                widget.newestOrder.status
                                                        ?.toLowerCase() ==
                                                    "completed")
                                            ? CustomColor.blueColor
                                            : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              widget.newestOrder.createdAt ?? "",
                              textAlign: TextAlign.center,
                              style: CustomTextStyle().heading1L.copyWith(
                                    color: CustomColor.blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.sp,
                                  ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  " # ${widget.newestOrder.orderId}",
                                  style: CustomTextStyle().heading1L.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.sp,
                                      ),
                                ),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 2.h),
                                  child: Tooltip(
                                      onTriggered: () {
                                        Clipboard.setData(ClipboardData(
                                            text: widget.newestOrder.orderId
                                                .toString()));
                                        showSnackBar(
                                            title: 'تم النسخ بنجاح!',
                                            type: SnackBarType.success);
                                      },
                                      triggerMode: TooltipTriggerMode.tap,
                                      message:
                                          widget.newestOrder.orderId.toString(),
                                      padding: EdgeInsets.zero,
                                      child: IconSvgPicture(
                                        nameIcon: Assets.icons.copy,
                                        heightIcon: 16.h,
                                        colorFilter: ColorFilter.mode(
                                            Colors.black, BlendMode.srcIn),
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ButtonDone(
                          text: 'تتبع الطلب',
                          iconName: Assets.icons.check,
                          borderRadius: 10.r,
                          height: 27.h,
                          heightIcon: 20.h,
                          widthIconInStartEnd: 20.w,
                          heightIconInStartEnd: 20.w,
                          haveBouncingWidget: false,
                          onPressed: () {
                            NavigatorApp.push(OrderDetails(
                              newestOrder: widget.newestOrder,
                              done: false,
                            ));
                          },
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
