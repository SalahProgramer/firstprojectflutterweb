import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../salah/controllers/product_item_controller.dart';
import '../../../salah/models/items/item_model.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/utilities/style/colors.dart';
import '../../../salah/utilities/style/text_style.dart';
import '../../../salah/widgets/custom_button.dart';

Future<void> dialogDropDownSizes({required Item item}) {
  return showDialog(
    context: NavigatorApp.context,
    builder: (context) {
      ProductItemController productItemController = context
          .watch<ProductItemController>();

      return GestureDetector(
        onTap: () {
          NavigatorApp.pop();
        },
        child: Container(
          color: Colors.white30,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 70.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: CustomColor.secondaryColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Text(
                                  "اختر مقاسك",
                                  style: CustomTextStyle().heading1L.copyWith(
                                    color: Colors.black,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -10.w,
                            // Adjust this for horizontal alignment
                            top: -27.h,

                            // Adjust this for vertical alignment
                            child: IconSvg(
                              nameIcon: Assets.icons.cancel,
                              height: 22.h,
                              colorFilter: ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                              onPressed: () => NavigatorApp.pop(),
                              backColor: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: CustomColor.secondaryColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 5.h),
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: item.variants!.length,
                          itemBuilder: (context, index) => Center(
                            child: InkWell(
                              onTap: () async {
                                await productItemController.changeSizesItem(
                                  item.id.toString(),
                                  item.variants![index].size.toString(),
                                  item,
                                  index,
                                );
                                await productItemController.changeNoChoiceSize(
                                  false,
                                );
                                NavigatorApp.pop();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                margin: EdgeInsets.symmetric(
                                  vertical: 5.h,
                                  horizontal: 5.w,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color:
                                      (productItemController
                                              .sizesItems[item.id.toString()]
                                              .toString()
                                              .trim() ==
                                          item.variants![index].size
                                              .toString()
                                              .trim())
                                      ? Colors.black
                                      : Colors.white,
                                  boxShadow: [],
                                ),
                                child: Text(
                                  item.variants![index].size.toString(),
                                  style: CustomTextStyle().heading1L.copyWith(
                                    color:
                                        (productItemController
                                                .sizesItems[item.id.toString()]
                                                .toString()
                                                .trim() ==
                                            item.variants![index].size
                                                .toString()
                                                .trim())
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
