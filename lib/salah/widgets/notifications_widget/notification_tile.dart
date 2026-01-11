import 'package:fawri_app_refactor/salah/constants/constant-categories/constant_data_convert.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/product_item_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/sub_main_categories_conrtroller.dart';
import 'package:fawri_app_refactor/salah/models/notifications/notifications_model.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../gen/assets.gen.dart';
import '../../../server/functions/functions.dart';
import '../../controllers/APIS/api_product_item.dart';
import '../../views/pages/home/home_screen/home_screen.dart';
import '../../views/pages/home/main_screen/product_item_view.dart';
import '../custom_button.dart';
import '../custom_image.dart';

class NotificationListTile extends StatefulWidget {
  final NotificationsModel notification;

  const NotificationListTile({super.key, required this.notification});

  @override
  State<NotificationListTile> createState() => _NotificationListTileState();
}

class _NotificationListTileState extends State<NotificationListTile> {
  bool _showImage = false;

  String _formatTimestamp(DateTime dateTime) {
    try {
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'الآن';
      } else if (difference.inHours < 1) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inDays < 1) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} يوم';
      } else {
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }

  void _toggleImageVisibility() {
    setState(() {
      _showImage = !_showImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.notification.title;
    final String body = widget.notification.body;

    final DateTime timestamp = widget.notification.timestamp;
    final bool hasImage =
        widget.notification.image != null &&
        widget.notification.image!.isNotEmpty;
    printLog(widget.notification.image);
    printLog("sku: ${widget.notification.sku}");

    SubMainCategoriesController subMainCategoriesController = context
        .watch<SubMainCategoriesController>();

    ProductItemController productItemController = context
        .watch<ProductItemController>();
    PageMainScreenController pageMainScreenController = context
        .watch<PageMainScreenController>();
    ApiProductItemController apiProductItemController = context
        .watch<ApiProductItemController>();

    return InkWell(
      overlayColor: WidgetStateColor.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      // Main card tap: navigate to the related page (product / URL) only.
      // Image expansion is handled separately on the image area itself.
      onTap: () async {
        // If notification has SKU, navigate to specific product
        if (widget.notification.sku != null &&
            widget.notification.sku!.isNotEmpty) {
          await pageMainScreenController.changePositionScroll(
            widget.notification.sku!,
            0,
          );
          await productItemController.clearItemsData();
          await apiProductItemController.cancelRequests();
          await productItemController.getSpecificProduct(
            widget.notification.sku!,
          );

          if (productItemController.isTrue == true &&
              productItemController.specificItemData != null) {
            NavigatorApp.push(
              ProductItemView(
                item: productItemController.specificItemData!,
                sizes: "",
              ),
            );
          }
        }
        // Otherwise, if notification has URL, navigate to HomeScreen
        else if (widget.notification.url != null &&
            widget.notification.url!.isNotEmpty) {
          await subMainCategoriesController.clear();

          String url = widget.notification.url!;
          String notificationTitle = widget.notification.title;

          NavigatorApp.push(
            HomeScreen(
              scrollController: subMainCategoriesController.scrollSlidersItems,
              type: "normal",
              title: notificationTitle,
              url: url,
              hasAppBar: true,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: ListTile(
            leading: Container(
              width: 42.w,
              decoration: BoxDecoration(
                color:
                    (hasImage
                            ? CustomColor.chrismasColor
                            : CustomColor.blueColor)
                        .withValues(alpha: 0.12),

                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconSvg(
                  nameIcon: hasImage
                      ? Assets.icons.tagSvgrepoCom
                      : Assets.icons.notificationsSvgrepoCom,
                  onPressed: () {},
                  colorFilter: ColorFilter.mode(
                    (hasImage
                        ? CustomColor.chrismasColor
                        : CustomColor.blueColor),
                    BlendMode.srcIn,
                  ),
                  backColor: Colors.transparent,
                  height: 40.w,
                  width: 40.w,
                ),
              ),
            ),

            title: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade500),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.black87.withValues(alpha: 0.8),
                  ),
                ),
                if (hasImage) ...[
                  SizedBox(height: 8.h),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleImageVisibility,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 950),
                      curve: Curves.easeInOut,
                      child: _showImage
                          ? CustomImageSponsored(
                              imageUrl: widget.notification.image!,
                              borderRadius: BorderRadius.circular(12.r),
                              boxFit: BoxFit.fill,
                            )
                          : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.touch_app,
                                            size: 10.sp,
                                            color: CustomColor.blueColor
                                                .withValues(alpha: 0.7),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'اضغط لمشاهدة الصورة',
                                            style: TextStyle(
                                              fontSize: 8.5.sp,
                                              color: CustomColor.blueColor
                                                  .withValues(alpha: 0.8),
                                              fontWeight: FontWeight.w500,
                                              height: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),

            trailing:
                (widget.notification.sku != null ||
                    widget.notification.url != null)
                ? InkWell(
                    onTap: () async {
                      // If notification has SKU, navigate to specific product
                      if (widget.notification.sku != null &&
                          widget.notification.sku!.isNotEmpty) {
                        await pageMainScreenController.changePositionScroll(
                          widget.notification.sku!,
                          0,
                        );
                        await productItemController.clearItemsData();
                        await apiProductItemController.cancelRequests();
                        await productItemController.getSpecificProduct(
                          widget.notification.sku!,
                        );

                        if (productItemController.isTrue == true &&
                            productItemController.specificItemData != null) {
                          NavigatorApp.push(
                            ProductItemView(
                              item: productItemController.specificItemData!,
                              sizes: "",
                            ),
                          );
                        }
                      }
                      // Otherwise, if notification has URL, navigate to HomeScreen
                      else if (widget.notification.url != null &&
                          widget.notification.url!.isNotEmpty) {
                        await subMainCategoriesController.clear();

                        String url = widget.notification.url!;
                        String notificationTitle = widget.notification.title;

                        NavigatorApp.push(
                          HomeScreen(
                            scrollController:
                                subMainCategoriesController.scrollSlidersItems,
                            type: "normal",
                            title: notificationTitle,
                            url: url,
                            hasAppBar: true,
                          ),
                        );
                      }
                    },
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: Colors.grey.shade500,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
