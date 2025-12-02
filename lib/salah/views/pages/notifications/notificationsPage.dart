import 'package:fawri_app_refactor/salah/controllers/notification_controller.dart';
import 'package:fawri_app_refactor/salah/widgets/app_bar_widgets/app_bar_custom.dart';
import 'package:fawri_app_refactor/salah/widgets/notifications_widget/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<NotificationController>();
      await controller.loadNotifications();
      await controller.markAllAsRead();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
      context.read<NotificationController>().loadNotifications();
    
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final notificationController = context.watch<NotificationController>();
    final notifications = notificationController.notifications;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: CustomAppBar(
        title: "الإشعارات",
        textButton: "رجوع",
        onPressed: () async {
          Navigator.of(context).maybePop();
        },
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off,
                      size: 80.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    "لا توجد إشعارات",
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ListView.builder(
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
