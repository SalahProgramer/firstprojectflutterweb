import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/controllers/product_item_controller.dart';
import 'package:fawri_app_refactor/core/utilities/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:fawri_app_refactor/models/items/item_model.dart';
import 'package:fawri_app_refactor/core/utilities/style/text_style.dart';
import 'package:fawri_app_refactor/core/widgets/custom_button.dart';

class WidgetSizeItem extends StatefulWidget {
  final Item? item;

  const WidgetSizeItem({super.key, required this.item});

  @override
  State<WidgetSizeItem> createState() => _WidgetSizeItemState();
}

class _WidgetSizeItemState extends State<WidgetSizeItem> {
  @override
  Widget build(BuildContext context) {
    ProductItemController productItemController =
        context.watch<ProductItemController>();
    return DropdownButton2<String>(
      underline: SizedBox(),
      barrierDismissible: true,
      buttonStyleData: ButtonStyleData(
          elevation: 1,
          height: 33.h,
          padding: EdgeInsets.all(5.w),
          overlayColor: WidgetStateColor.transparent,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          )),
      iconStyleData: IconStyleData(
          icon: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.only(bottom: 2.h),
        child: IconSvg(
          nameIcon: Assets.icons.arrow,
          onPressed: null,
          backColor: Colors.transparent,
          colorFilter: ColorFilter.mode(
            Colors.black,
            BlendMode.srcIn,
          ),
        ),
      )),
      isDense: true,
      hint: ((widget.item?.variants?[0].size == "${widget.item!.id}"))
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: SizedBox(
                width: 30.w,
                height: 30.w,
                child: SpinKitFadingCircle(
                  color: Colors.black,
                  size: 20.h,
                ),
              ),
            )
          : Text(
              "اختر مقاسك",
              style: CustomTextStyle()
                  .heading1L
                  .copyWith(color: Colors.black, fontSize: 12.sp),
            ),
      dropdownStyleData: DropdownStyleData(
          elevation: 0,
          offset: calculateOffset(context),
          maxHeight: double.maxFinite,
          width: double.maxFinite,
          // Modify if needed
          scrollPadding: EdgeInsets.only(left: 5.w),
          scrollbarTheme: ScrollbarThemeData(
            radius: Radius.circular(50.r),
            thickness: WidgetStatePropertyAll(50),
            thumbColor: WidgetStateProperty.all(Colors.black),
            trackColor: WidgetStateProperty.all(Colors.black12),
            trackBorderColor: WidgetStateProperty.all(Colors.black26),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.white,
              border: Border.all(
                  color: Colors.black, width: 0.5, style: BorderStyle.solid),
              boxShadow: [
                BoxShadow(
                    color: Colors.white70,
                    spreadRadius: 20,
                    blurStyle: BlurStyle.inner,
                    blurRadius: 15)
              ])),
      menuItemStyleData: MenuItemStyleData(
          overlayColor: WidgetStateColor.transparent,
          height: 38.h,
          selectedMenuItemBuilder: (context, child) {
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              margin: EdgeInsets.only(right: 5.w, left: 0.w),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.yellow,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        blurStyle: BlurStyle.outer,
                        blurRadius: 5,
                        spreadRadius: 1)
                  ]),
              child: Text(
                productItemController.sizesItems[widget.item!.id.toString()]!,
                style: CustomTextStyle()
                    .heading1L
                    .copyWith(color: CustomColor.blueColor, fontSize: 12.sp),
              ),
            );
          },
          padding: EdgeInsets.zero),
      alignment: Alignment.center,
      onChanged: (value) async {
        int? index = widget.item!.variants
            ?.indexWhere((element) => element.size == value);
        await productItemController.changeSizesItem(
            widget.item!.id.toString(), value!, widget.item!, index!);
      },
      value: (widget.item!.variants == [])
          ? ""
          : (widget.item!.variants!.length == 1)
              ? productItemController.sizesItems[widget.item!.id.toString()]
              : productItemController.sizesItems[widget.item!.id.toString()],
      items: widget.item!.variants?.map((e) {
        return DropdownMenuItem(
          alignment: Alignment.center,
          value: e.size,
          child: Text(
            e.size.toString(),
            style: CustomTextStyle()
                .heading1L
                .copyWith(color: CustomColor.blueColor, fontSize: 12.sp),
          ),
        );
      }).toList(),
    );
  }

  Offset calculateOffset(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    final dropdownWidth = 200.w; // Set your dropdown width here
    final dropdownHeight = 150.w; // Set your dropdown height here

    return Offset(
      centerX - (dropdownWidth / 2) - 200.w,
      centerY - (dropdownHeight / 2) + 50.h,
    );
  }
}
