import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../controllers/order_controller.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';

class WidgetButtonOrder extends StatefulWidget {
  final String title;
  final String number;
  final int page;
  const WidgetButtonOrder({
    super.key,
    required this.title,
    required this.number,
    required this.page,
  });

  @override
  State<WidgetButtonOrder> createState() => _WidgetButtonOrderState();
}

class _WidgetButtonOrderState extends State<WidgetButtonOrder> {
  @override
  Widget build(BuildContext context) {
    OrderControllerSalah orderControllerSalah = context
        .watch<OrderControllerSalah>();
    return Expanded(
      flex: 4,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () async {
          await orderControllerSalah.changePageOrder(widget.page);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: (orderControllerSalah.pageOrder == widget.page)
                ? CustomColor.blueColor
                : Colors.transparent,
            boxShadow: [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyle().heading1L.copyWith(
                    fontSize: 11.sp,
                    height: 1.2.h,
                    color: (orderControllerSalah.pageOrder == widget.page)
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                widget.number,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyle().heading1L.copyWith(
                  fontSize: 13.sp,
                  height: 1.2.h,
                  color: (orderControllerSalah.pageOrder == widget.page)
                      ? Colors.white
                      : CustomColor.blueColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
