import 'package:fawri_app_refactor/LocalDB/Models/address_item_model.dart';
import 'package:fawri_app_refactor/LocalDB/Provider/address_provider.dart';
import 'package:fawri_app_refactor/dialog/dialogs/dialog_update_profile.dart';
import 'package:fawri_app_refactor/salah/controllers/points_controller.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/button_done.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../dialog/dialogs/dialog_phone/dialog_add_phone.dart';
import '../../salah/controllers/birthday_controller.dart';
import '../../salah/utilities/global/app_global.dart';
import '../../salah/utilities/style/colors.dart';
import '../../salah/utilities/style/text_style.dart';
import '../../salah/utilities/validations/validation.dart';
import '../../salah/views/pages/points/users_points.dart';
import '../../salah/widgets/app_bar_widgets/app_bar_custom.dart';
import '../../salah/widgets/widget_text_field/can_custom_text_field.dart';
import '../checkout/add-address/add_address.dart';
import '../chooses_birthdate/chooses_birthdate.dart';

class AccountInformation extends StatefulWidget {
  final dynamic name, address, area, city, phone, birthday;

  const AccountInformation({
    super.key,
    this.name,
    this.address,
    this.area,
    this.birthday,
    this.city,
    this.phone,
  });

  @override
  State<AccountInformation> createState() => AaccounIinformationState();
}

class AaccounIinformationState extends State<AccountInformation> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    PointsController pointsControllerClass = context.watch<PointsController>();
    BirthdayController birthdayController = context.watch<BirthdayController>();
    final Color backColor = Colors.black.withValues(alpha: 0.025);
    return Scaffold(
      backgroundColor: Colors.grey[250],
      appBar: CustomAppBar(
        title: "فوري",
        backgroundColor: Colors.black,
        textButton: "رجوع",
        textColor: Colors.white,
        onPressed: () {
          NavigatorApp.pop();
        },
        actions: [],
        colorWidgets: Colors.black,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 12.w, left: 12.w, right: 12.w),
        child: ButtonDone(
          text: "تحديث المعلومات",
          haveBouncingWidget: false,
          iconName: Assets.icons.yes,
          isLoading: pointsControllerClass.loadingSaveProfile,
          onPressed: () async {
            FocusScope.of(context).unfocus();
            if (formKey.currentState!.validate()) {
              await pointsControllerClass.changeLoadingSaveProfile(true);
              await dialogUpdateProfile(
                phone: pointsControllerClass.phoneProfileController.text
                    .trim()
                    .toString(),
                name: pointsControllerClass.nameProfileController.text
                    .trim()
                    .toString(),
              ).whenComplete(() {
                FocusScope.of(context).unfocus();
              });

              // Unfocus AFTER the dialog is dismissed

              await pointsControllerClass.changeLoadingSaveProfile(false);
            } else {
              return;
            }
          },
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.only(top: 35, right: 25, left: 25),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        NavigatorApp.push(UsersPointsPage());
                      },
                      borderRadius: BorderRadius.circular((25.r)),
                      child: Container(
                        width: double.maxFinite,
                        // height: 0.3.sh,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular((25.r)),
                          boxShadow: [
                            BoxShadow(
                              blurStyle: BlurStyle.outer,
                              color: Colors.black,
                              spreadRadius: 2,
                              blurRadius: 10.r,
                            ),
                          ],
                          image: DecorationImage(
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover,
                            image: AssetImage(Assets.images.backg.path),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 10.h),
                            Center(
                              child: ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (Rect bounds) {
                                  return RadialGradient(
                                    center: Alignment.topLeft,
                                    radius: 1.0,
                                    colors: <Color>[
                                      Colors.black,
                                      Colors.black,
                                      Colors.black,
                                      Colors.black,
                                    ],
                                    tileMode: TileMode.mirror,
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  "رصيد النقاط المتوفرة",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                numAndText(
                                  text: "  نقطة  ",
                                  num: "${pointsControllerClass.points} ",
                                ),
                                SizedBox(width: 15.h),
                                Container(
                                  width: 3.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10.r),
                                      bottom: Radius.circular(10.r),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15.h),
                                numAndText(
                                  text: "  شيكل  ",
                                  num: "${pointsControllerClass.shekel} ",
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: backColor,
                          ),
                          padding: EdgeInsets.only(
                            left: 12.w,
                            right: 12.w,
                            bottom: 25.w,
                            top: 10.w,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 30.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        children: [
                                          SizedBox(height: 10.h),
                                          CustomTextFormFieldProfile(
                                            hintText: "ادخل اسم المستخدم",
                                            label: "اسم المستخدم",
                                            inputType: TextInputType.text,
                                            prefixIcon: Icon(
                                              CupertinoIcons.profile_circled,
                                            ),
                                            controller: pointsControllerClass
                                                .nameProfileController,
                                            hasFocusBorder: true,
                                            hasFill: true,
                                            textAlign: TextAlign.center,
                                            hasSeePassIcon: true,
                                            hintStyle: CustomTextStyle().rubik
                                                .copyWith(
                                                  color: Colors.grey,
                                                  fontSize: 11.sp,
                                                ),
                                            textStyle: CustomTextStyle().rubik
                                                .copyWith(
                                                  color: CustomColor.blueColor,
                                                  fontSize: 11.sp,
                                                ),
                                            controlPage: null,
                                            validate: (p0) =>
                                                Validation.checkText(
                                                  p0 ?? "",
                                                  "الإسم",
                                                ),
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        SizedBox(height: 10.h),
                                        CustomTextFormFieldProfile(
                                          hintText: "056-123-4567",
                                          label: "رقم الهاتف",
                                          inputType: TextInputType.number,
                                          prefixIcon: Icon(
                                            CupertinoIcons.phone,
                                          ),
                                          controller: pointsControllerClass
                                              .phoneProfileController,
                                          hasFocusBorder: true,
                                          maxLength: 10,
                                          hasFill: true,
                                          textAlign: TextAlign.center,
                                          hasSeePassIcon: true,
                                          hintStyle: CustomTextStyle().rubik
                                              .copyWith(
                                                color: Colors.grey,
                                                fontSize: 11.sp,
                                              ),
                                          textStyle: CustomTextStyle().rubik
                                              .copyWith(
                                                color: CustomColor.blueColor,
                                                fontSize: 11.sp,
                                              ),
                                          controlPage: null,
                                          validate: (p0) =>
                                              Validation.checkPhoneNumber(
                                                p0 ?? "",
                                              ),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        SizedBox(height: 10.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: CustomTextFormFieldProfile(
                                                hintText: "00/00/0000",
                                                label: "تاريخ الميلاد",
                                                onTap: () async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences.getInstance();

                                                  String phone =
                                                      prefs.getString(
                                                        'phone',
                                                      ) ??
                                                      "";
                                                  if (phone == "") {
                                                    await showAddPhone(
                                                      goToSpin: false,
                                                    );
                                                    phone =
                                                        prefs.getString(
                                                          'phone',
                                                        ) ??
                                                        "";
                                                  }

                                                  if (phone != "") {
                                                    NavigatorApp.push(
                                                      ChooseBirthdate(
                                                        name: "",
                                                        phoneController: phone,
                                                        select: 11,
                                                        selectedArea: "",
                                                        token: "",
                                                        userID: "",
                                                      ),
                                                    );
                                                  }
                                                },
                                                prefixIcon: Icon(
                                                  FontAwesome.birthday_cake,
                                                ),
                                                inputType: TextInputType.text,
                                                controller: birthdayController
                                                    .birthdayProfileController,
                                                hasFocusBorder: true,
                                                hasTap: true,
                                                hasFill: false,
                                                textAlign: TextAlign.center,
                                                hasSeePassIcon: true,
                                                hintStyle: CustomTextStyle()
                                                    .rubik
                                                    .copyWith(
                                                      color: Colors.grey,
                                                      fontSize: 11.sp,
                                                    ),
                                                textStyle: CustomTextStyle()
                                                    .rubik
                                                    .copyWith(
                                                      color:
                                                          CustomColor.blueColor,
                                                      fontSize: 11.sp,
                                                    ),
                                                controlPage: null,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Consumer<AddressProvider>(
                                builder: (context, addressprovider, _) {
                                  List<AddressItem> addressItems =
                                      addressprovider.addressItems;

                                  return Column(
                                    children: [
                                      SizedBox(height: 15.h),
                                      Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Stack(
                                            alignment: Alignment.topCenter,
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                  top: 20.h,
                                                  bottom: 20.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.black,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.r,
                                                      ),
                                                ),
                                                child: Visibility(
                                                  visible: true,
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      minHeight:
                                                          (addressItems.isEmpty)
                                                          ? 0.005.sh
                                                          : 0.1.sh,
                                                      maxHeight: 0.24.sh,
                                                    ),
                                                    child: ListView.separated(
                                                      separatorBuilder:
                                                          (context, index) =>
                                                              SizedBox(
                                                                height: 4.h,
                                                              ),
                                                      // physics: A(),
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          addressItems.length,
                                                      itemBuilder: (context, index) {
                                                        AddressItem item =
                                                            addressItems[index];
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12.r,
                                                                ),
                                                            // border: Border.all(
                                                            //     color: Colors.black,
                                                            //     width: 1)
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                6.w,
                                                              ),
                                                          margin:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 4.w,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                "${index + 1}  )  ",
                                                              ),
                                                              Text(
                                                                item.name,
                                                                style: CustomTextStyle()
                                                                    .heading1L
                                                                    .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12.sp,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: -15.h,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 5.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        CustomColor.blueColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    "العناوين",
                                                    style: CustomTextStyle()
                                                        .heading1L
                                                        .copyWith(
                                                          color: Colors.white,
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Positioned(
                                            bottom: -12.h,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12.w,
                                                vertical: 5.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  NavigatorApp.push(
                                                    const AddAddress(
                                                      loadAllCities:
                                                          true, // Load all cities from account_information
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: Image.asset(
                                                        Assets.images.add.path,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      "اضافة عنوان جديد ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 12.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -30.h,
                          child: CircleAvatar(
                            radius: 35.r,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(90.r),
                              child: Image(
                                image: AssetImage(Assets.images.image.path),

                                // 90% of screen width
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.only(top: 50),
                    //   child: ButtonWidget(
                    //       name: "حفظ",
                    //       height: 50,
                    //       width: double.infinity,
                    //       BorderColor: MAIN_COLOR,
                    //       OnClickFunction: () {},
                    //       BorderRaduis: 40,
                    //       ButtonColor: MAIN_COLOR,
                    //       NameColor: Colors.white),
                    // )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget numAndText({required String num, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            num.toString().trim(),
            textDirection: TextDirection.rtl,
            style: CustomTextStyle().heading1L.copyWith(
              color: CustomColor.chrismasColor,
              fontSize: 23.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            text.trim(),
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
