import 'package:fawri_app_refactor/salah/controllers/notification_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/notifications/notificationsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class IconNotifications extends StatefulWidget {
  final Color? color;

  const IconNotifications({super.key, this.color});

  @override
  State<IconNotifications> createState() => _IconNotificationsState();
}

class _IconNotificationsState extends State<IconNotifications>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationController>().loadNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationController>().loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    NotificationController notificationController =
        context.watch<NotificationController>();

    return Padding(
      padding: EdgeInsets.only(top: 8.h, right: 2.w, left: 2.w),
      child: Badge(
        alignment: Alignment.topRight,
        isLabelVisible: notificationController.unreadCount > 0,
        label: Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Text(
            notificationController.unreadCount.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        child: IconButton(
          icon: Icon(
            Icons.notifications_none_sharp,
            size: 21.sp,
            color: widget.color ?? Colors.black,
          ),
          onPressed: () {
            NavigatorApp.push(
              ShowCaseWidget(builder: (context) => const NotificationsPage()),
            );
          },
        ),
      ),
    );
  }
}
