import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/items/item_model.dart';
import '../../utilities/style/text_style.dart';

class WidgetDescriptionText extends StatelessWidget {
  final Item? item;

  const WidgetDescriptionText({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: (item!.variants == []) ? 0.5 : 1,
      duration: Duration(milliseconds: 700),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),

          // Optional rounded corners
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent, // Disables ripple effect
            highlightColor: Colors.transparent, // Disables highlight effect
            dividerColor:
                Colors.transparent, // Optional: remove divider color if present
          ),
          child: ExpansionTile(
            collapsedBackgroundColor: Colors.transparent,
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.r)),
            ),
            showTrailingIcon: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
              side: BorderSide(color: Colors.black, width: 0.1),
            ),
            collapsedIconColor: Colors.black,
            tilePadding: EdgeInsets.symmetric(horizontal: 4.w),
            backgroundColor: Colors.transparent,
            enabled: true,
            clipBehavior: Clip.none,
            iconColor: Colors.black,
            leading: Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: Icon(Icons.sticky_note_2_outlined),
            ),
            title: Text(
              "تفاصيل المنتج",
              style: CustomTextStyle().heading1L.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(left: 4.w, right: 35.w, bottom: 6.h),
                  child: (item?.description?.isEmpty ?? false)
                      ? Text(
                          item?.title ?? "",
                          style: CustomTextStyle().heading1L.copyWith(
                            color: Colors.black87,
                            fontSize: 12.sp,
                          ),
                        )
                      : ListView.separated(
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 4.h),
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    maxLines: 2,
                                    item!.description?[index]
                                                .split(":")
                                                .length ==
                                            1
                                        ? ("${item!.description?[index].split(":").first}")
                                        : ("${item!.description?[index].split(":").first}: "),
                                    style: CustomTextStyle().heading1L.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                                if ((item!.description?[index]
                                        .split(":")
                                        .length) ==
                                    2)
                                  Flexible(
                                    flex: 2,
                                    child: Text(
                                      ("${item!.description?[index].split(":").last}"),
                                      style: CustomTextStyle().heading1L
                                          .copyWith(
                                            color: Colors.green,
                                            fontSize: 12.sp,
                                          ),
                                    ),
                                  ),
                              ],
                            );
                          },
                          shrinkWrap: true,
                          itemCount: item?.description?.length ?? 0,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
