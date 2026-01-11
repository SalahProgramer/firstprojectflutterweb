import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../custom_button.dart';

class PointTile extends StatelessWidget {
  final int amount;
  final String title;
  final String date;
  final String pointicon;

  const PointTile({
    super.key,
    required this.amount,
    required this.title,
    required this.date,
    required this.pointicon,
  });

  @override
  Widget build(BuildContext context) {
    final isPlus = amount >= 0;
    final amountText = (isPlus ? '+' : '') + amount.toString();
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.grey.shade200, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 4),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyle().cairo.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: CustomColor.deepNavy,
            ),
          ),
          subtitle: Text(
            date,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: !isPlus
                  ? CustomColor.pointsContainerColor1
                  : CustomColor.pointsContainerColor2,
            ),
            child: IconSvgPicture(
              nameIcon: pointicon,
              heightIcon: 25.sp,
              colorFilter: ColorFilter.mode(
                !isPlus ? CustomColor.deepPurple : CustomColor.blueButtonColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          trailing: Text(
            amountText,
            style: CustomTextStyle().cairo.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: isPlus
                  ? CustomColor.greenTextColor
                  : CustomColor.errorColor,
            ),
          ),
        ),
      ),
    );
  }
}
