import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utilities/style/colors.dart';
import '../custom_image.dart';

class CardPopUpShoes extends StatelessWidget {
  final double? height;
  final int itemCount;
  final dynamic eachImageUrl;

  const CardPopUpShoes({
    super.key,
    this.height,
    required this.itemCount,
    required this.eachImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: height ?? 0.35.sh,
      width: double.maxFinite,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: height ?? 0.35.sh,
                    width: double.maxFinite,
                    child: CarouselSlider.builder(
                      itemBuilder: (context, index, realIndex) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 15.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: CustomColor.blueColor,
                                blurStyle: BlurStyle.outer,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: CustomImageSponsored(
                            boxFit: BoxFit.cover,
                            imageUrl: eachImageUrl[index].vendorImagesLinks![0]
                                .toString(),
                            borderRadius: BorderRadius.circular(20.r),
                            width: double.maxFinite,
                            height: height ?? 0.35.sh,
                            padding: EdgeInsets.zero,
                            borderCircle: 20.r,
                          ),
                        );
                      },
                      options: CarouselOptions(
                        initialPage: 0,

                        scrollDirection: Axis.horizontal,
                        height: height ?? 0.35.sh,
                        enlargeCenterPage: true,

                        enlargeStrategy: CenterPageEnlargeStrategy.scale,

                        // pageViewKey: PageStorageKey(
                        //     widget.item.vendorImagesLinks[0].toString()),
                        viewportFraction: 0.7,
                        aspectRatio: 7,

                        // autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
                        autoPlayAnimationDuration: Duration(milliseconds: 3000),

                        // autoPlayInterval: Duration(milliseconds: 5900),
                        scrollPhysics: ClampingScrollPhysics(),
                        autoPlay: true,
                      ),
                      itemCount: itemCount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
