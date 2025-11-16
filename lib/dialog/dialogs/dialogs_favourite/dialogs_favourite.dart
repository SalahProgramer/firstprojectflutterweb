import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../salah/controllers/favourite_controller.dart';
import '../../../salah/controllers/page_main_screen_controller.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/widgets/custom_button.dart';
import '../../../salah/widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../salah/widgets/snackBarWidgets/snackbar_widget.dart';

Future<void> onPopDeleteFavouriteItem(
    {int? productId, String? text, void Function()? onPressed}) {
  return showGeneralDialog(
      context: NavigatorApp.navigatorKey.currentState!.context,
      barrierLabel: "ccc",
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        FavouriteController favouriteController =
            context.watch<FavouriteController>();

        PageMainScreenController pageMainScreenController =
            context.watch<PageMainScreenController>();

        return CupertinoAlertDialog(
          insetAnimationCurve: Curves.bounceInOut,
          title: Icon(CupertinoIcons.delete, color: CustomColor.primaryColor),
          content: Text(text ?? "هل أنت متأكد من حذف هذا المنتج؟",
              style: CustomTextStyle()
                  .heading1L
                  .copyWith(color: Colors.black54, fontSize: 12.sp)),
          actions: [
            CustomButtonWithIconWithoutBackground(
                text: "حذف",
                textIcon: "",
                height: 16.h,
                textStyle: CustomTextStyle()
                    .rubik
                    .copyWith(color: CustomColor.primaryColor, fontSize: 11.sp),
                onPressed: onPressed ??
                    () async {
                      await favouriteController.deleteItem(
                          productId: (productId));
                      await pageMainScreenController.changeIsFavourite(
                          (productId.toString()), false);
                      NavigatorApp.pop();
                      await showSnackBar(
                          title: "لقد تم حذف المنتج",
                          type: SnackBarType.success);
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
