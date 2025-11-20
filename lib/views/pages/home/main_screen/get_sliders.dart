import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/widgets/slider-widget/slider_widget.dart';
import '../../../../models/slider_model.dart';

class Sliders extends StatefulWidget {
  final List<SliderModel> sliders;
  final bool withCategory;
  final bool click;
  final bool showShadow;
  const Sliders(
      {super.key,
      required this.sliders,
      required this.withCategory,
      required this.click,
      required this.showShadow});

  @override
  State<Sliders> createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      child: (widget.sliders.isEmpty)
          ? SizedBox(
              height: 0.28.sh,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[500]!,
                highlightColor: Colors.grey[100]!,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 17.h),
                  child: Container(
                    height: 0.28.sh,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            )
          : SlideImage(
              withCategory: widget.withCategory,
              click: widget.click,
              showShadow: widget.showShadow,
              sliderImage: widget.sliders,
            ),
    );
  }
}
