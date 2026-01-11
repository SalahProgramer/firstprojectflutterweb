import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/widget_drop_down.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_item_controller.dart';
import '../../models/items/item_model.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../custom_button.dart';

class QuantityView extends StatefulWidget {
  final Item? item;

  const QuantityView({super.key, required this.item});

  @override
  State<QuantityView> createState() => _QuantityViewState();
}

class _QuantityViewState extends State<QuantityView> {
  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController = context
        .watch<ProductItemController>();
    printLog(widget.item?.variants?[0].size.toString() == "${widget.item!.id}");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WidgetDropDown(item: widget.item!),

              // WidgetSizeItem(
              //   item: widget.item,
              // )
            ],
          ),
          AnimatedOpacity(
            opacity:
                ((widget.item?.variants?[0].size.toString() ==
                    "${widget.item!.id}"))
                ? 0
                : ((productItemController.sizesItems[widget.item!.id.toString()]
                          .toString() ==
                      ""))
                ? 0
                : 1,
            duration: Duration(milliseconds: 200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    "عدد الكمية :",
                    style: CustomTextStyle().heading1L.copyWith(
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      (productItemController.basicQuantityItems[widget.item?.id
                              .toString()
                              .trim()] ==
                          null)
                      ? false
                      : (int.tryParse(
                              productItemController
                                      .basicQuantityItems[widget.item?.id
                                          .toString()
                                          .trim()]
                                      ?.toString() ??
                                  '',
                            ) ==
                            1)
                      ? false
                      : true,
                  child: IconSvg(
                    nameIcon: Assets.icons.add,
                    onPressed: () async {
                      await productItemController.doIncrement(
                        widget.item!.id.toString(),
                        productItemController.indexItems[widget.item!.id
                            .toString()]!,
                        widget.item!,
                      );
                    },
                    width: 35.w,
                    backColor: Colors.transparent,
                    colorFilter: ColorFilter.mode(
                      CustomColor.blueColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                (productItemController.basicQuantityItems[widget.item?.id
                            .toString()
                            .trim()] !=
                        null)
                    ? (int.tryParse(
                                productItemController
                                        .basicQuantityItems[widget.item?.id
                                            .toString()
                                            .trim()]
                                        ?.toString() ??
                                    '',
                              ) ==
                              1)
                          ? SizedBox(width: 5.w)
                          : SizedBox(width: 0.w)
                    : SizedBox(width: 0.w),
                ((widget.item?.variants?[0].size == "${widget.item!.id}") ||
                        ((productItemController
                                .sizesItems[widget.item?.id.toString()]
                                .toString() ==
                            "")))
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: SpinKitFadingCircle(
                          color: Colors.black,
                          size: 20.h,
                        ),
                      )
                    : Text(
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        (productItemController.valueQuantityItems == {})
                            ? "1"
                            : (productItemController
                                  .valueQuantityItems[widget.item?.id
                                      .toString()
                                      .trim()]
                                  .toString()),
                      ),
                (productItemController.basicQuantityItems[widget.item?.id
                            .toString()
                            .trim()] !=
                        null)
                    ? (int.tryParse(
                                productItemController
                                        .basicQuantityItems[widget.item?.id
                                            .toString()
                                            .trim()]
                                        ?.toString() ??
                                    '',
                              ) ==
                              1)
                          ? SizedBox(width: 5.w)
                          : SizedBox(width: 0.w)
                    : SizedBox(width: 0.w),
                Visibility(
                  visible:
                      (productItemController.basicQuantityItems[widget.item?.id
                              .toString()
                              .trim()] ==
                          null)
                      ? false
                      : (int.tryParse(
                              productItemController
                                      .basicQuantityItems[widget.item?.id
                                          .toString()
                                          .trim()]
                                      ?.toString() ??
                                  '',
                            ) ==
                            1)
                      ? false
                      : true,
                  child: IconSvg(
                    nameIcon: Assets.icons.remove,
                    onPressed: () async {
                      await productItemController.doDecrement(
                        widget.item!.id.toString(),
                        productItemController.indexItems[widget.item!.id
                            .toString()]!,
                        widget.item!,
                      );
                    },
                    width: 35.w,
                    backColor: Colors.transparent,
                    colorFilter: ColorFilter.mode(
                      CustomColor.blueColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
