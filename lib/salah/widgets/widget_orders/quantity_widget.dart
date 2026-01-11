import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/order/order.dart';
import '../../utilities/style/text_style.dart';

class QuantityWidget extends StatefulWidget {
  final SpecificOrder specificOrder;

  const QuantityWidget({super.key, required this.specificOrder});

  @override
  State<QuantityWidget> createState() => _QuantityWidgetState();
}

class _QuantityWidgetState extends State<QuantityWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                clipBehavior: Clip.none,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  alignment: Alignment.center,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  shadowColor: Colors.transparent,
                  overlayColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  elevation: 0,
                ),
                onPressed: () {},
                child: Text(
                  widget.specificOrder.size.toString(),
                  style: CustomTextStyle().heading1L.copyWith(
                    color: Colors.black,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          Row(
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
              SizedBox(width: 5.w),
              Text(
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                widget.specificOrder.quantity.toString(),
              ),
              SizedBox(width: 5.w),
            ],
          ),
        ],
      ),
    );
  }
}
