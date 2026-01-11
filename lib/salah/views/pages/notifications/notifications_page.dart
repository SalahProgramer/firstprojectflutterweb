import 'package:fawri_app_refactor/salah/controllers/notification_controller.dart';
import 'package:fawri_app_refactor/salah/widgets/app_bar_widgets/app_bar_custom.dart';
import 'package:fawri_app_refactor/salah/widgets/notifications_widget/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with WidgetsBindingObserver {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<NotificationController>();
      await controller.loadNotifications();
      await controller.markAllAsRead();
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload notifications when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationController>().loadNotifications().then((_) {
        // Mark all as read again since user is on the page
        context.read<NotificationController>().markAllAsRead();
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    // Watch for real-time changes in notifications
    final notificationController = context.watch<NotificationController>();
    final notifications = notificationController.notifications;

    // Auto-mark all as read when new notifications arrive while on this page
    if (_isInitialized && notificationController.unreadCount > 0) {
      Future.microtask(() {
        context.read<NotificationController>().markAllAsRead();
      });
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: CustomAppBar(
        title: "الإشعارات",
        textButton: "رجوع",
        onPressed: () async {
          Navigator.of(context).maybePop();
        },
      ),
      body: Column(
        children: [
          // Warning banner when notifications are disabled
          if (!notificationController.notificationsEnabled)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade800,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "الإشعارات معطلة حالياً. يمكنك تفعيلها من صفحة الإعدادات",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Notifications list
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Ionicons.notifications_off,
                          size: 80.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "لا توجد إشعارات",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return NotificationListTile(
                        notification: notifications[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
