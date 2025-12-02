import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../salah/controllers/cart_controller.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/widgets/custom_button.dart';
import '../../../salah/widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../salah/widgets/snackBarWidgets/snackbar_widget.dart';
import '../../../salah/widgets/widgets_carts/widget_each_cart_delete.dart';
import '../../../salah/widgets/widgets_item_view/button_done.dart';
import '../dialogs_favourite/dialogs_favourite.dart';

AnalyticsService analyticsService = AnalyticsService();

Future<void> onPopDeleteCartItem({required String id}) {
  return showGeneralDialog(
      context: NavigatorApp.navigatorKey.currentState!.context,
      barrierLabel: "ccc",
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        CartController cartController = context.watch<CartController>();

        return CupertinoAlertDialog(
          insetAnimationCurve: Curves.bounceInOut,
          title: Icon(CupertinoIcons.delete, color: CustomColor.primaryColor),
          content: Text("هل أنت متأكد من حذف هذا المنتج؟",
              style: CustomTextStyle()
                  .rubik
                  .copyWith(color: Colors.black54, fontSize: 12.sp)),
          actions: [
            CustomButtonWithIconWithoutBackground(
                text: "حذف",
                textIcon: "",
                height: 16.h,
                textStyle: CustomTextStyle()
                    .rubik
                    .copyWith(color: CustomColor.primaryColor, fontSize: 11.sp),
                onPressed: () async {
                  await analyticsService.logEvent(
                    eventName: "delete_cart_item_dialog_confirm",
                    parameters: {
                      "class_name": "DialogsCartDeleteAndCheckAvailable",
                      "button_name": "حذف من السلة",
                      "time": DateTime.now().toString(),
                    },
                  );
                  await cartController.deleteItem(id: (id));
                  showSnackBar(
                      title: " لقد تم حذف المنتج بنجاح",
                      type: SnackBarType.success,
                      description: '');
                  NavigatorApp.pop();
                }),
            CustomButtonWithIconWithoutBackground(
                text: "رجوع",
                textIcon: "",
                height: 16.h,
                textStyle: CustomTextStyle()
                    .rubik
                    .copyWith(color: Colors.black, fontSize: 11.sp),
                onPressed: () async {
                  Navigator.pop(context);
                })
          ],
        );
      });
}

Future<void> dialogCheckItemsAvailable() {
  return showDialog(
    context: NavigatorApp.context,
    builder: (context) {
      CartController cartController = context.watch<CartController>();
      return GestureDetector(
        onTap: () {
          NavigatorApp.pop();
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: 0.98.sw,
            margin: EdgeInsets.only(bottom: 5.h),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black,
                      blurRadius: 30,
                      blurStyle: BlurStyle.inner)
                ]),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconSvg(
                          nameIcon: Assets.icons.cancel,
                          onPressed: () {
                            NavigatorApp.pop();
                          },
                          backColor: Colors.transparent,
                          height: 30.w,
                          width: 30.w,
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.only(left: 30.w),
                          child: BouncingWidget(
                            child: IconSvg(
                              nameIcon: Assets.icons.sadFace,
                              onPressed: null,
                              colorFilter: null,
                              backColor: Colors.transparent,
                              height: 60.w,
                              width: 60.w,
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    Text(
                      "للأسف!\nهذه المنتجات التي لم تعد متوفرة",
                      textAlign: TextAlign.center,
                      style: CustomTextStyle()
                          .rubik
                          .copyWith(fontSize: 18.sp, color: Colors.black),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: ClampingScrollPhysics(),
                        // shrinkWrap: true,
                        // reverse: true,
                        itemCount: cartController.notAvailabilityItems.length,
                        itemBuilder: (context, i) {
                          // double total = item.price * item.quantity;

                          return WidgetEachCardDelete(
                            index: i,
                            item: cartController.notAvailabilityItems[i],
                          );
                        },
                      ),
                    ),
                    ButtonDone(
                      text: 'حذف جميع المنتجات',
                      backColor: CustomColor.primaryColor,
                      iconName: Assets.icons.delete,
                      haveBouncingWidget: false,
                      onPressed: () async {
                        await onPopDeleteFavouriteItem(
                            text: "هل أنت متأكد من حذف المنتجات؟",
                            onPressed: () async {
                              String idList = "";
                              if (cartController.notAvailabilityItems.length ==
                                  1) {
                                idList = cartController
                                    .notAvailabilityItems[0].id
                                    .toString();
                              } else {
                                List<String?> ids = cartController
                                    .notAvailabilityItems
                                    .map((cart) => cart.id)
                                    .toList();
                                idList = ids.map((id) => "'$id'").join(", ");
                              }

                              await cartController.deleteAllItem(
                                  idList: idList);
                              showSnackBar(
                                title: " تم حذف جميع المنتجات الغير متوفرة",
                                type: SnackBarType.success,
                              );
                              NavigatorApp.pop();
                              NavigatorApp.pop();
                            });
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
