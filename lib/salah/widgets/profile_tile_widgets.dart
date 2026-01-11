import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onPressed;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
    this.trailing = const Icon(Icons.arrow_forward_ios_rounded, size: 12),
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      onTap: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
      title: Text(
        title,
        style: CustomTextStyle().heading1L.copyWith(
          color: Colors.black,
          fontSize: 10.sp,
        ),
      ),
      trailing: trailing,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      selectedColor: Colors.transparent,
      selectedTileColor: Colors.transparent,
      // selected: false,
      // enableFeedback: false,
      // autofocus: false,
      // tileColor: Colors.transparent,
      // dense: true,
    );
  }
}

class ProfileTilesCard extends StatelessWidget {
  final Widget child;

  const ProfileTilesCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      elevation: 0,
      child: child,
    );
  }
}

Widget get tilesDivider => const Divider(thickness: 1);
