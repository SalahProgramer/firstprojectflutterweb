import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/items/item_model.dart';
import '../../utilities/style/text_style.dart';
import '../custom_image.dart';
import '../custom_text.dart';

class UiSpecificItemMoreData extends StatelessWidget {
  final bool favourite;
  final bool inCart;
  final int index;
  final Item item;
  final List<Color>? bgColor;
  final Color? textPriceColor;

  const UiSpecificItemMoreData({
    super.key,
    required this.favourite,
    required this.index,
    required this.inCart,
    required this.item,
    this.bgColor,
    this.textPriceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        gradient: LinearGradient(
          colors:
              bgColor ??
              [
                Color(0xFFFFD700), // ذهبي
                Color(0xFFFFA500), // برتقالي ذهبي
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurStyle: BlurStyle.outer,
            blurRadius: 3,
            spreadRadius: 0.2,
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Color(0xFFF5F5F5),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: ImageSlideshow(
                      initialPage: 0,
                      indicatorColor: Colors.black,
                      indicatorBackgroundColor: Colors.grey,
                      onPageChanged: (value) {},
                      autoPlayInterval: item.vendorImagesLinks!.length == 1
                          ? 0
                          : (index % 2 != 0)
                          ? 0
                          : 3000,
                      isLoop: item.vendorImagesLinks!.length == 1
                          ? false
                          : true,
                      children: item.vendorImagesLinks!.map((url) {
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomImageSponsored(
                                  borderRadius: BorderRadius.circular(5.r),
                                  borderCircle: 5.r,
                                  boxFit: BoxFit.fill,
                                  padding: EdgeInsets.only(bottom: 17.h),
                                  imageUrl: url,
                                ),
                                Visibility(
                                  visible: inCart,
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 17.h),
                                    child: Container(
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(169, 0, 0, 0),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5.r),
                                          topLeft: Radius.circular(5.r),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "تم إضافته للسلة",
                                            style: CustomTextStyle().heading1L
                                                .copyWith(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 15,
                                            ),
                                            child: Image.asset(
                                              Assets.images.inCart.path,
                                              height: 22.w,
                                              width: 22.w,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 4.h,
                        left: 2.w,
                        right: 2.w,
                      ),
                      child: Center(
                        child: Text(
                          maxLines: 2,

                          overflow: TextOverflow.ellipsis,
                          item.title ?? "",
                          textDirection: TextDirection.rtl,

                          textAlign: TextAlign.center,

                          style: CustomTextStyle().heading1L.copyWith(
                            fontSize: 9.sp,
                            color: Colors.black,
                          ),
                          // textDecoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomText(
            fontSize: 9.sp,
            color: textPriceColor ?? Color(0xFF004AAD), // بني داكن,
            alignmentGeometry: Alignment.center,
            textDecoration: TextDecoration.none,
            text: item.newPrice,
          ),
        ],
      ),
    );
  }
}
