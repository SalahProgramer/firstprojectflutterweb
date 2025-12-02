import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:fawri_app_refactor/salah/controllers/fetch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';

class Titles extends StatefulWidget {
  final String text;
  final double? heightText;
  final int flag;
  final int showEven;

  const Titles(
      {super.key,
      required this.text,
      this.heightText,
      required this.flag,
      required this.showEven});

  @override
  State<Titles> createState() => _TitlesState();
}

class _TitlesState extends State<Titles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 700), // Duration of the animation
      vsync: this,
    );

    _colorAnimation = ColorTween(
            begin: (widget.showEven == 1)
                ? Colors.white.withValues(alpha: 0.5)
                : CustomColor.blueColor.withValues(alpha: 0.5),
            end:
                ((widget.showEven == 1)) ? Colors.white : CustomColor.blueColor)
        .animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FetchController fetchController = context.watch<FetchController>();
    return Container(
      alignment: Alignment.centerRight,
      // width: double.maxFinite,
      padding: EdgeInsets.only(right: 2.w),
      margin: EdgeInsets.only(right: 2.w),
      child: Align(
          alignment: Alignment.centerRight,
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.r),
                        topRight: Radius.circular(5.r))
                    // ,color: CustomColor.eidColor
                    ),
                child: BouncingWidget(
                  child: Text(
                    widget.text,
                    style: CustomTextStyle().heading1L.copyWith(
                          fontSize: 17.sp,
                          height: widget.heightText ?? 1.2.h,
                          color: (fetchController.showEven == 1 &&
                                  widget.flag == 1)
                              ? Colors.white
                              : Colors.black,
                        ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedBuilder(
                    animation: _colorAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 3.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          color:
                              _colorAnimation.value, // Animate the line color
                        ),
                        // Thickness of the line
                        width: double.maxFinite,
                      );
                    },
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
