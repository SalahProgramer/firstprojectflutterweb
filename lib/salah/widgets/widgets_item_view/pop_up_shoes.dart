import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/points_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/widgets/app_bar_widgets/app_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../dialog/dialogs/dialog_phone/dialog_add_phone.dart';
import '../../../dialog/dialogs/dialogs_spin_and_points/dialogs_points.dart';
import '../../controllers/search_controller.dart';
import '../../utilities/audio_player_extensions.dart';
import '../../utilities/style/colors.dart';
import '../../utilities/style/text_style.dart';
import '../custom_button.dart';
import 'button_done.dart';
import 'card_each_pop_up_shoes.dart';

class PopUpShoes extends StatefulWidget {
  final bool isMale;

  const PopUpShoes({super.key, required this.isMale});

  @override
  State<PopUpShoes> createState() => _PopUpShoesState();
}

class _PopUpShoesState extends State<PopUpShoes> {
  final FixedExtentScrollController scrollController =
      FixedExtentScrollController();

  @override
  Widget build(BuildContext context) {
    SearchItemController searchItemController =
        context.watch<SearchItemController>();
    PointsController pointsController = context.watch<PointsController>();

    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 20.h),
        child: SizedBox(
          height: 85.h,
          // Constrain the height to prevent it from taking too much space

          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: ButtonDone(
                    text: "حفظ    ",
                    heightIconInStartEnd: 30.h,
                    widthIconInStartEnd: 30.h,
                    height: 45.w,
                    isLoading: searchItemController.isLoadingPopUpShoes,
                    iconName: Assets.icons.yes,
                    onPressed: (searchItemController
                            .listSelectedSizesPopUpShoes.isNotEmpty)
                        ? () async {
                            await searchItemController
                                .changeLoadingPopUpShoes(true);
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            String phone = prefs.getString('phone') ?? "";
                            if (phone == "") {
                              await showAddPhone(goToSpin: false);
                              phone = prefs.getString('phone') ?? "";
                            }
                            if (phone != "") {
                              phone = prefs.getString('phone') ?? "";
                              String sizesSet = searchItemController
                                  .listSelectedSizesPopUpShoes
                                  .join(',');
                              await pointsController
                                  .updateUserPointsAndLevelWhenDoSelectSize(
                                      phone: phone,
                                      newAmount: '3',
                                      enumNumber: 3,
                                      gender:
                                          (widget.isMale) ? "male" : "female",
                                      sizes: sizesSet);

                              final f1 = pageMainScreenController
                                  .getUserActivity(phone: phone);
                              final f2 = pointsController.getPointsFromAPI(
                                  phone: phone);
                              await Future.wait([f1, f2]);

                              await searchItemController
                                  .changeLoadingPopUpShoes(false);
                              NavigatorApp.pop();

                              final player = AudioPlayer();

                              // Play audio when the dialog opens
                              player.playAsset(Assets.audios.iDidItMessageTone);
                              // Stop the audio after 5 seconds
                              Future.delayed(const Duration(seconds: 3),
                                  () async {
                                await player.stop();
                              });

                              await prefs.setBool('show_pop_up_shoes', false);

                              await dialogGetPointPopUpShoes("3 نقاط");
                            }
                          }
                        : null),
              ),
              InkWell(
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                overlayColor: WidgetStateColor.transparent,
                highlightColor: WidgetStateColor.transparent,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('show_pop_up_shoes', false);

                  NavigatorApp.pop();
                },
                child: Text(
                  "تخطي",
                  style: CustomTextStyle().heading1L.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14.sp),
                ),
              )
            ],
          ),
        ),
      ),
      appBar: CustomAppBar(
        title: "اختر مقاسك",
        textButton: "رجوع",
        actions: [],
        colorWidgets: Colors.white,
        onPressed: () {
          NavigatorApp.pop();
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardPopUpShoes(
                itemCount: searchItemController.popUpShoesData.length,
                height: 0.46.sh,
                eachImageUrl: searchItemController.popUpShoesData,
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(
                "الرجاء اختيار نمرة حذائك لتجربة أكثر متعة!",
                textAlign: TextAlign.center,
                style: CustomTextStyle()
                    .heading1L
                    .copyWith(color: Colors.black, fontSize: 18.sp),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                // width: double.maxFinite,
                margin: EdgeInsets.only(left: 4.w, right: 4.w),
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(12.r),
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: Colors.black,
                  //       blurRadius: 10,
                  //       blurStyle: BlurStyle.outer)
                  // ],
                  color: Colors.transparent,
                ),
                child: ChipsChoice<String>.multiple(
                  clipBehavior: Clip.antiAlias,
                  wrapped: true,
                  onChanged: (value) async {
                    // await searchItemController.setListSizesPopUpShoes(value);
                  },
                  value: searchItemController.listSelectedSizesPopUpShoes,
                  choiceCheckmark: true,
                  mainAxisAlignment: MainAxisAlignment.center,
                  choiceItems: C2Choice.listFrom(
                    source: searchItemController.sizesPopUpShoes,
                    value: (index, item) => item,
                    label: (index, item) => item,
                  ),
                  choiceBuilder: (item, i) {
                    bool isSelected = searchItemController
                        .listSelectedSizesPopUpShoes
                        .contains(item.value);

                    return InkWell(
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      overlayColor: WidgetStateColor.transparent,
                      highlightColor: WidgetStateColor.transparent,
                      onTap: () async {
                        // printLog(value.toString()+"dddddddddddddddddddddddd");

                        await searchItemController
                            .setListSizesPopUpShoes(item.value.toString());
                      },
                      child: Container(
                        margin: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: isSelected
                              ? CustomColor.blueColor
                              : Colors
                                  .transparent, // Change color when selected
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5.r,
                              color: Colors.black,
                              blurStyle: BlurStyle.outer,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 7.w, right: 7.w, bottom: 0.h, top: 4.h),
                          child: (isSelected)
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 4.h),
                                      child: IconSvg(
                                        nameIcon: Assets.icons.yes,
                                        onPressed: null,
                                        width: 29.w,
                                        height: 29.w,
                                        colorFilter: ColorFilter.mode(
                                            Colors.white, BlendMode.srcIn),
                                        backColor: Colors.transparent,
                                      ),
                                    ),
                                    Text(
                                      item.label,
                                      style:
                                          CustomTextStyle().heading1L.copyWith(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors
                                                        .black, // Change text color when selected
                                                fontSize: 24.sp,
                                              ),
                                    )
                                  ],
                                )
                              : Text(
                                  item.label,
                                  style: CustomTextStyle().heading1L.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors
                                                .black, // Change text color when selected
                                        fontSize: 24.sp,
                                      ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
