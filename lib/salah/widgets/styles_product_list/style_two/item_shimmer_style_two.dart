import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utilities/style/colors.dart';

class ItemShimmerStyleTwo extends StatelessWidget {
  final double? width;
  final bool hasAnimatedBorder;

  const ItemShimmerStyleTwo({
    super.key,
    required this.hasAnimatedBorder,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 8.h),
      child: Stack(
        alignment: Alignment.topRight,
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            width: width ?? 120.w,
            child: Column(
              children: [
                Expanded(
                  child: (hasAnimatedBorder)
                      ? Stack(
                          alignment: Alignment.topRight,
                          children: [
                            AnimatedGradientBorder(
                              glowSize: 1,
                              borderSize: 1.4,
                              gradientColors: [
                                CustomColor.primaryColor,
                                CustomColor.primaryColor.withValues(alpha: 0.2),
                              ],
                              borderRadius: BorderRadius.circular(20.r),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[500]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.w),
                              child: AnimatedGradientBorder(
                                glowSize: 0.5,
                                borderSize: 0.5,
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(0.r),
                                  bottomLeft: Radius.circular(5.r),
                                  topLeft: Radius.circular(5.r),
                                  topRight: Radius.circular(10.r),
                                ),
                                gradientColors: [
                                  Colors.red,
                                  CustomColor.primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                                ],
                                child: Container(
                                  width: 30.w,
                                  height: 30.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(0.r),
                                      bottomLeft: Radius.circular(5.r),
                                      topLeft: Radius.circular(5.r),
                                      topRight: Radius.circular(10.r),
                                    ),
                                  ),
                                  child: InkWell(
                                    overlayColor: WidgetStatePropertyAll(
                                      Colors.transparent,
                                    ),
                                    child: Icon(
                                      FontAwesome.heart,
                                      color: Colors.grey,
                                      size: 15.h,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Shimmer.fromColors(
                          baseColor: Colors.grey[500]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                        ),
                ),
                if (hasAnimatedBorder == false) SizedBox(height: 5.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
