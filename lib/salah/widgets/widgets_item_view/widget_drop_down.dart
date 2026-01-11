import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:fawri_app_refactor/salah/controllers/product_item_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:fawri_app_refactor/salah/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../dialog/dialogs/dialog_item_view/dialog_drop_down_sizes.dart';
import '../../../gen/assets.gen.dart';
import '../../models/items/item_model.dart';

class WidgetDropDown extends StatelessWidget {
  final Item item;

  const WidgetDropDown({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController = context
        .watch<ProductItemController>();

    // double offsetYaxis = 0.09,   double offsetXaxis = 0,   int milliSecondDuration = 400
    return BouncingWidget(
      offsetYaxis: (item.variants?[0].size == "${item.id}")
          ? 0
          : ((productItemController.sizesItems[item.id.toString()].toString() ==
                    "") &&
                productItemController.noChoiceSize == true)
          ? 0.09
          : 0,
      offsetXaxis: 0,
      milliSecondDuration: 400,
      child: CustomButtonWithIconWithoutBackground(
        noChoiceSize: productItemController.noChoiceSize,
        text: (item.variants?[0].size == "${item.id}")
            ? ""
            : ((productItemController.sizesItems[item.id.toString()]
                      .toString() ==
                  ""))
            ? "اختر مقاسك"
            : productItemController.sizesItems[item.id.toString()].toString(),
        isLoading: (item.variants?[0].size == "${item.id}") ? true : false,
        textStyle: CustomTextStyle().heading1L.copyWith(
          color: Colors.black,
          fontSize: 12.sp,
        ),
        hasBackground: true,
        textIcon: Assets.icons.arrow,
        height: 28.h,
        elevation: 2,
        padding: EdgeInsets.only(right: 8.w, left: 3.w),
        onPressed: (item.variants?[0].size == "${item.id}")
            ? null
            : () async {
                item.variants = item.variants!.toSet().toList();

                return dialogDropDownSizes(item: item);
              },
      ),
    );
  }
}
