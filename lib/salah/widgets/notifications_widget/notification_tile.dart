import 'package:fawri_app_refactor/salah/controllers/sub_main_categories_conrtroller.dart';
import 'package:fawri_app_refactor/salah/models/notifications/notificationsModel.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../views/pages/home/home_screen/home_screen.dart';

class NotificationListTile extends StatelessWidget {
  final NotificationsModel notification;

  const NotificationListTile({super.key, required this.notification});

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

  @override
  Widget build(BuildContext context) {
    final String title = notification.title;
    final String body = notification.body;
    final DateTime timestamp = notification.timestamp;

    SubMainCategoriesController subMainCategoriesController = context
        .watch<SubMainCategoriesController>();

    return InkWell(
      overlayColor: WidgetStateColor.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: (notification.url == null)
          ? null
          : () async {
              await subMainCategoriesController.clear();

              String url = notification.url ?? '';
              String notificationTitle = notification.title;

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
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.withValues(alpha: 0.12),
                    Colors.deepPurple.withValues(alpha: 0.3),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  size: 24.sp,
                  Icons.notifications_none,
                  color: Colors.deepPurple,
                  // size: 20.sp,
                ),
              ),
            ),
            title: Text(
              title,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
                color: Colors.black,
              ),
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
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade500),
                ),
              ],
            ),
            trailing: (notification.url != null)
                ? Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: Colors.grey.shade500,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
