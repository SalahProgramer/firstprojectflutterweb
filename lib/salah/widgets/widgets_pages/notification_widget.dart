import 'package:fawri_app_refactor/salah/controllers/notification_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/services/notifications/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../gen/assets.gen.dart';
import '../../views/pages/notifications/notifications_page.dart';
import '../custom_button.dart';

class IconNotifications extends StatefulWidget {
  final Color? color;

  const IconNotifications({super.key, this.color});

  @override
  State<IconNotifications> createState() => _IconNotificationsState();
}

class _IconNotificationsState extends State<IconNotifications>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Load notifications immediately
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
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Reload notifications when app resumes from background
    if (state == AppLifecycleState.resumed) {
      await context.read<NotificationController>().loadNotifications();

      // Cancel any displayed notifications if settings are disabled
      await LocalNotificationService.cancelAllIfDisabled();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Watch for changes in notification controller
    NotificationController notificationController = context
        .watch<NotificationController>();

    // Only show badge when notifications are enabled
    bool showBadge =
        notificationController.notificationsEnabled &&
        notificationController.unreadCount > 0;

    return Padding(
      padding: EdgeInsets.only(top: 8.h, right: 2.w, left: 2.w),
      child: Badge(
        alignment: Alignment.topRight,
        isLabelVisible: showBadge,
        label: Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Text(
            notificationController.unreadCount.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        child: IconSvg(
          nameIcon: Assets.icons.notificationsSvgrepoCom,
          backColor: Colors.transparent,
          height: 40.w,
          width: 40.w,
          // heightIcon: 40.h,
          onPressed: () async {
            NavigatorApp.push(
              ShowCaseWidget(builder: (context) => const NotificationsPage()),
            );
          },
          colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
      ),
    );
  }
}
