import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../controllers/birthday_controller.dart';
import '../../../controllers/custom_page_controller.dart';
import '../../../core/firebase/user/user_model.dart';
import '../../../core/firebase/user/user_controller.dart';
import '../../../core/utilities/global/app_global.dart';
import '../../../core/utilities/style/colors.dart';
import '../../../core/utilities/style/text_style.dart';
import '../../../core/utilities/print_looger.dart';
import '../../../core/widgets/app_bar_widgets/app_bar_custom.dart';
import '../../../core/widgets/widgets_item_view/button_done.dart';
import '../../../core/widgets/snackBarWidgets/snack_bar_style.dart';
import '../../../core/widgets/snackBarWidgets/snackbar_widget.dart';
import '../../../core/dialogs/dialog_waiting/dialog_waiting.dart';
import '../pages.dart';
import '../orders/new_orders.dart';


class ChooseBirthdate extends StatefulWidget {
  final String name, userID, token, phoneController, selectedArea;
  final int select;

  const ChooseBirthdate(
      {super.key,
      required this.name,
      required this.userID,
      required this.phoneController,
      required this.token,
      required this.selectedArea,
      required this.select});

  @override
  State<ChooseBirthdate> createState() => _ChooseBirthdateState();
}

class _ChooseBirthdateState extends State<ChooseBirthdate> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      BirthdayController birthdayController =
          context.read<BirthdayController>();
      await birthdayController.changeBirthDay(
        DateFormat('MM-dd').format(DateTime.now()), // current date in MM-DD
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BirthdayController birthdayController = context.watch<BirthdayController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    return Scaffold(
      appBar: CustomAppBar(
        title: "فوري",
        textButton: "رجوع",
        onPressed: () async {
          if (widget.select == 0) {
            NavigatorApp.pop();

            await customPageController.changeIndexPage(0);
            await customPageController.changeIndexCategoryPage(1);
            NavigatorApp.pushReplacment(Pages());
          } else if (widget.select == 1) {
            NavigatorApp.pop();

            SharedPreferences prefs = await SharedPreferences.getInstance();

            String userID = prefs.getString('user_id') ?? "";
            String phone = prefs.getString('phone') ?? "";

            NavigatorApp.pushReplacment(OrdersPages(
              userId: userID.toString(),
              phone: phone,
            ));
          } else if (widget.select == 11) {
            NavigatorApp.pop();
          } else {
            NavigatorApp.pop();

            await customPageController.changeIndexPage(0);
            await customPageController.changeIndexCategoryPage(1);
            NavigatorApp.pushReplacment(Pages());
          }
        },
        actions: [],
        colorWidgets: Colors.white,
      ),
      body: Container(
        color: Color(0xffF5F5F5),
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
            child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Image.asset(
                  Assets.images.iconsss.path,
                  // height: 150,
                  width: 140.w,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Text(
                  "ما هو تاريخ ميلادك ؟ ",
                  style: CustomTextStyle().heading1L.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16.sp),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Text(
                  widget.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: CustomColor.primaryColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(" 🔥  للحصول على المزيد من الخصومات  🔥  ",
                    style: CustomTextStyle().heading1L.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14.sp)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Container(
                  color: Color(0xffD9D9D9),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: EasyDateTimeLine(
                      initialDate: DateTime.now(),
                      headerProps: EasyHeaderProps(showSelectedDate: true),
                      onDateChange: (selectedDate) async {
                        await birthdayController.changeBirthDay(
                            DateFormat('MM-dd').format(selectedDate));
                      },
                      activeColor: const Color(0xffB04759),
                      locale: "ar",
                      dayProps: EasyDayProps(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "اختر الجنس :",
                      style: CustomTextStyle().heading1L.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16.sp),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Radio(
                          value: 'male',
                          groupValue: birthdayController.selectedGender,
                          activeColor: Color(0xffB04759),
                          onChanged: (value) async {
                            await birthdayController
                                .changeSelectGender(value ?? "");
                          },
                        ),
                        Text(
                          'ذكر',
                          style: CustomTextStyle().heading1L.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14.sp),
                        ),
                        SizedBox(width: 20.w),
                        Radio(
                          value: 'female',
                          groupValue: birthdayController.selectedGender,
                          activeColor: Color(0xffB04759),
                          onChanged: (value) async {
                            await birthdayController
                                .changeSelectGender(value ?? "");
                          },
                        ),
                        Text(
                          'أنثى',
                          style: CustomTextStyle().heading1L.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14.sp),
                        ),
                        SizedBox(
                          width: 0.2.sw,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: ButtonDone(
                          text: "حفظ    ",
                          heightIconInStartEnd: 30.h,
                          widthIconInStartEnd: 30.h,
                          height: 45.w,
                          isLoading: birthdayController.isLoading,
                          iconName: Assets.icons.yes,
                          onPressed: () async {
                            await birthdayController.changeLoading(true);
                            if (birthdayController.selectedGender.isEmpty ||
                                birthdayController.selectedGender == "") {
                              await birthdayController.changeLoading(false);
                              await showSnackBar(
                                  title: 'الرجاء تحديد جنسك',
                                  type: SnackBarType.warning);
                            } else if (birthdayController.birthday == "") {
                              await birthdayController.changeLoading(false);
                            } else {
                              dialogWaiting();

                              printLog(birthdayController.birthday);
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('show_birthday', false);
                              await prefs.setString('gender',
                                  birthdayController.selectedGender.toString());
                              await prefs.setString(
                                  'birthdate', birthdayController.birthday);
                              UserItem updatedUser = UserItem(
                                name: widget.name.toString(),
                                id: widget.userID.toString(),
                                token: widget.token.toString(),
                                email: "${widget.userID}@email.com",
                                phone: widget.phoneController.toString(),
                                gender: birthdayController.selectedGender
                                    .toString(),
                                birthdate:
                                    birthdayController.birthday.toString(),
                                city: widget.selectedArea.toString(),
                                area: widget.selectedArea.toString(),
                                address: widget.selectedArea.toString(),
                                password: '123',
                              );
                              await userService.updateUser(updatedUser,
                                  updateBirthdate: true, updateGender: true);
                              await birthdayController.addBirthDay(
                                  widget.phoneController.toString());
                              await birthdayController.changeLoading(false);

                              await birthdayController.changeControllerBirthday(
                                  birthdayController.birthday);

                              NavigatorApp.pop();
                              showSnackBar(
                                  title: "لقد تم حفظ تاريخ ميلادك بنجاح 🎂",
                                  type: SnackBarType.success);
                              if (widget.select == 0) {
                                NavigatorApp.pop();
                                await customPageController.changeIndexPage(0);
                                await customPageController
                                    .changeIndexCategoryPage(1);
                                NavigatorApp.pushReplacment(Pages());
                              } else if (widget.select == 1) {
                                NavigatorApp.pop();
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String phone = prefs.getString('phone') ?? "";
                                String userID =
                                    prefs.getString('user_id') ?? "";
                                NavigatorApp.pushReplacment(OrdersPages(
                                  userId: userID.toString(),
                                  phone: phone,
                                ));
                              } else if (widget.select == 11) {
                                NavigatorApp.pop();
                              } else {
                                NavigatorApp.pop();
                                NavigatorApp.pushReplacment(Pages());
                              }
                            }
                          }),
                    ),
                    InkWell(
                      onTap: () async {
                        if (widget.select == 0) {
                          NavigatorApp.pop();

                          await customPageController.changeIndexPage(0);
                          await customPageController.changeIndexCategoryPage(1);
                          NavigatorApp.pushReplacment(Pages());
                        } else if (widget.select == 1) {
                          NavigatorApp.pop();

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          String userID = prefs.getString('user_id') ?? "";
                          String phone = prefs.getString('phone') ?? "";
                          NavigatorApp.pushReplacment(OrdersPages(
                            userId: userID.toString(),
                            phone: phone,
                          ));
                        } else if (widget.select == 11) {
                          NavigatorApp.pop();
                        } else {
                          NavigatorApp.pop();

                          NavigatorApp.pushReplacment(Pages());
                        }
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
              )
            ],
          ),
        )),
      ),
    );
  }

  final EasyInfiniteDateTimelineController controller =
      EasyInfiniteDateTimelineController();
  final UserService userService = UserService();
}
