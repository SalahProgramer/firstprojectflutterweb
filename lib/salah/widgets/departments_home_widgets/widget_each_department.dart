import 'dart:io';
import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/button_done.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utilities/global/app_global.dart';
import '../app_bar_widgets/app_bar_custom.dart';
import 'button_types.dart';

class WidgetEachDepartment extends StatefulWidget {
  final String? backgroundImage;
  final String? title;
  final String? subTitle;
  final bool check;
  final int style;
  final dynamic methodChangeLoading;
  final Map<String, bool>? isLoadingType;
  final List<dynamic> listStyle2;
  final void Function()? onPressedSure;
  final void Function()? onPressedSkip;

  final List<Widget>? children;

  const WidgetEachDepartment({
    super.key,
    this.backgroundImage,
    this.children,
    this.onPressedSure,
    this.title,
    required this.check,
    required this.style,
    required this.listStyle2,
    this.isLoadingType,
    this.methodChangeLoading,
    this.subTitle,
    this.onPressedSkip,
  });

  @override
  State<WidgetEachDepartment> createState() => _WidgetEachDepartmentState();
}

class _WidgetEachDepartmentState extends State<WidgetEachDepartment> {
  AnalyticsService analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title ?? "فوري",
        textButton: "رجوع",
        onPressed: () {
          NavigatorApp.pop();
        },
        actions: [],
        colorWidgets: Colors.white,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
          // color:  (widget.backgroundImage != "")
          //     ? null
          //     :Colors.white,
          image: (widget.backgroundImage == "")
              ? null
              : DecorationImage(
                  image: AssetImage(widget.backgroundImage!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.1),
                    BlendMode.dstATop,
                  ),
                ),
        ),
        child: Center(
          child: Column(
            children: [
              (widget.style == 2) ? SizedBox(height: 15.h) : SizedBox(),
              (widget.style == 2)
                  ? Text(
                      widget.subTitle.toString().trim(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    )
                  : SizedBox(),
              (widget.style == 1)
                  ? Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.25.sw),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: widget.children ?? [],
                        ),
                      ),
                    )
                  : Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 0.05.sw,
                          right: 0.05.sw,
                          top: 20.h,
                          bottom: 20.h,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 15.h,
                            horizontal: 5.w,
                          ),
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: GridView.builder(
                            scrollDirection: Axis.vertical,
                            clipBehavior: Clip.none,
                            physics: Platform.isIOS
                                ? ClampingScrollPhysics()
                                : AlwaysScrollableScrollPhysics(),
                            itemCount: widget.listStyle2.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 3.h,
                                  mainAxisSpacing: 3.h,
                                  childAspectRatio: 2,
                                ),
                            itemBuilder: (context, index) {
                              final dynamic currentItem =
                                  widget.listStyle2[index];
                              String sizeText;
                              String sizeSubtitle;

                              if (currentItem is Map) {
                                sizeText = currentItem["sizeText"] ?? '';
                                sizeSubtitle =
                                    currentItem["sizeSubtitle"] ?? '';
                              } else {
                                sizeText = currentItem.toString();
                                sizeSubtitle = '';
                              }

                              return ButtonTypes(
                                text: sizeText,
                                subtitle: sizeSubtitle,
                                haveBouncingWidget: false,
                                colorFilter: ColorFilter.mode(
                                  Colors.blueAccent,
                                  BlendMode.srcIn,
                                ),
                                isLoading: widget.isLoadingType?[sizeText],
                                iconName: '',
                                onPressed: () async {
                                  await analyticsService.logEvent(
                                    eventName: "department_grid_button_click",
                                    parameters: {
                                      "class_name": "WidgetEachDepartment",
                                      "button_name": "sizeText: $sizeText",
                                      "size_text": sizeText,
                                      "size_subtitle": sizeSubtitle,
                                      "time": DateTime.now().toString(),
                                    },
                                  );

                                  final bool currentLoadingState =
                                      widget.isLoadingType?[sizeText] ?? false;
                                  await widget.methodChangeLoading(
                                    sizeText,
                                    !currentLoadingState,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
              if (widget.check == true || widget.style == 2)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ButtonDone(
                          text: 'التالي',
                          borderRadius: 25.r,
                          haveBouncingWidget: false,
                          // isLoading: true,
                          backColor: Colors.black,
                          iconName: "",
                          onPressed: widget.onPressedSure,
                        ),
                      ),
                      Expanded(
                        child: ButtonDone(
                          text: 'تخطي',
                          borderRadius: 25.r,
                          haveBouncingWidget: false,
                          // isLoading: true,
                          backColor: Color.fromARGB(255, 171, 171, 171),
                          iconName: "",
                          onPressed: widget.onPressedSkip,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
