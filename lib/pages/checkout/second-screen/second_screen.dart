import 'package:bouncerwidget/bouncerwidget.dart';
import 'package:fawri_app_refactor/firebase/user/user_controller.dart';
import 'package:fawri_app_refactor/pages/checkout/add-address/add_address.dart';
import 'package:fawri_app_refactor/salah/controllers/cart_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/checkout_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/custom_page_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/style/colors.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:fawri_app_refactor/salah/widgets/widget_text_field/can_custom_text_field.dart';
import 'package:fawri_app_refactor/salah/widgets/widgets_item_view/button_done.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fawri_app_refactor/LocalDB/Models/address_item_model.dart';
import 'package:fawri_app_refactor/LocalDB/Provider/address_provider.dart';
import 'package:fawri_app_refactor/firebase/user/user_model.dart';
import 'package:fawri_app_refactor/model/Area/area.dart';
import 'package:fawri_app_refactor/model/City/city.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:fawri_app_refactor/services/dialogs/checkout/area_city_service/area_city_service.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'dart:io' show Platform;
import '../../../dialog/dialogs/dialog_blocked/dialog_blocked.dart';
import '../../../dialog/dialogs/dialog_waiting/dialog_waiting.dart';
import '../../../dialog/dialogs/dialogs_order/dialog_merge_order.dart';
import '../../../dialog/dialogs/dialogs_order/dialogs_order.dart';
import '../../../salah/controllers/order_controller.dart';
import '../../../salah/controllers/points_controller.dart';
import '../../../salah/localDataBase/models_DB/cart_model.dart';
import '../../../salah/utilities/global/app_global.dart';
import '../../../salah/views/pages/pages.dart';
import '../../../salah/widgets/app_bar_widgets/app_bar_custom.dart';

class CheckoutSecondScreen extends StatefulWidget {
  final dynamic total;
  final dynamic totalWithoutDelivery;
  final dynamic delivery;

  final String initialCity;
  final String couponControllerText;
  final String pointControllerText;
  final bool usedWheelCoupon;

  const CheckoutSecondScreen(
      {super.key,
      required this.total,
      this.initialCity = "",
      required this.couponControllerText,
      required this.totalWithoutDelivery,
      required this.pointControllerText,
      required this.usedWheelCoupon,
      required this.delivery});

  @override
  State<CheckoutSecondScreen> createState() => _CheckoutSecondScreenState();
}

class _CheckoutSecondScreenState extends State<CheckoutSecondScreen> {
  bool editName = false;
  bool editPhone = false;
  bool chooseAddress = false;
  bool loading = false;
  bool coponed = false;
  City? selectedCity;
  AddressItem? selectedArea;
  String finalSelectedArea = "";
  City? selectedCity1;
  Area? selectedArea1;
  List<City> cities = [];
  List<Area> areas = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController cityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController couponController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController orderController = TextEditingController();
  final UserService userService = UserService();
  AnalyticsService analyticsService = AnalyticsService();

  // Helper method to get city names by region (English translated names as saved in DB)
  List<String> getCityNamesByRegion(String region) {
    if (region == "الداخل") {
      return ['Eilat', 'Jolan', 'Manateq', 'AL 67'];
    } else if (region == "القدس") {
      return ['Quds'];
    } else if (region == "الضفه الغربيه") {
      return [
        'Nablus',
        'Ramallah',
        'Jenin',
        'Tulkarem',
        'Qaliqilya',
        'Hebron',
        'beitlahm',
        'Jericho',
        'Salfit',
        'Tubas',
        'QudsV', // كفرعقب uses QudsV as translated name
      ];
    }
    return []; // Return empty list if no region selected
  }

  setControllers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? buy = prefs.getBool('buy') ?? false;

    // Ensure CheckoutController has the correct dropdownValue
    final checkoutController = context.read<CheckoutController>();
    if (widget.initialCity != "" && widget.initialCity != "اختر منطقتك") {
      if (checkoutController.dropdownValue != widget.initialCity) {
        await checkoutController.changeDropdownValue(widget.initialCity);
      }
    }

    if (buy) {
      String name = prefs.getString('name') ?? "";
      String phone = prefs.getString('phone') ?? "";
      editName = false;
      editPhone = false;
      chooseAddress = false;
      nameController.text = name.toString();
      phoneController.text = phone.toString();
    } else {
      editName = true;
      editPhone = true;
      chooseAddress = true;
      String phone = prefs.getString('phone') ?? "";
      String name = prefs.getString('name') ?? "";

      if (phone == "") {
        phoneController.text = "";
      } else {
        phoneController.text = phone.toString();
      }

      if (name == "") {
        nameController.text = "";
      } else {
        nameController.text = name.toString();
      }
    }
    // تحميل المدن بناءً على المنطقة (initialCity)
    if (widget.initialCity != "" && widget.initialCity != "اختر منطقتك") {
      cities = await CityService().loadCitiesByRegion(widget.initialCity);
    } else {
      cities = await CityService().loadCities();
    }
    final addressItems = context.read<AddressProvider>().addressItems;
    if (addressItems.isNotEmpty && selectedArea == null) {
      setState(() {
        finalSelectedArea = addressItems[0].name;
      });
    }
    setState(() {});
  }

  @override
  void initState() {
  WidgetsBinding.instance.addPostFrameCallback((_)async{

    await setControllers();
  });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CartController cartController = context.watch<CartController>();
    OrderControllerSalah orderControllerSalah =
        context.watch<OrderControllerSalah>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    PointsController pointsController = context.watch<PointsController>();
    PageMainScreenController pageMainScreenController =
        context.watch<PageMainScreenController>();
    CheckoutController checkoutController = context.watch<CheckoutController>();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: mainColor,
        child: Scaffold(

          bottomNavigationBar: BouncingWidget(
              child: ButtonDone(
                  text: "تأكيد عمليه الشراء",
                  iconName: Assets.icons.yes,
                  isLoading: orderControllerSalah.isLoading3,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    if (phoneController.text == "" ||
                        nameController.text == "") {
                      await orderControllerSalah.changeLoading3(false);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                              "الرجاء تعبئه جميع البيانات",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            actions: <Widget>[
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: mainColor,
                                      borderRadius: BorderRadius.circular(12.r)),
                                  child: Center(
                                    child: Text(
                                      "حسنا",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (selectedArea == null) {
                      await orderControllerSalah.changeLoading3(false);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                              "الرجاء إضافة العنوان",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            actions: <Widget>[
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 100,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: mainColor,
                                      borderRadius: BorderRadius.circular(12.r)),
                                  child: Center(
                                    child: Text(
                                      "حسنا",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      if (_formKey.currentState!.validate()) {
                        await orderControllerSalah.changeLoading3(true);
                        dialogWaiting();
                        final f1 = pageMainScreenController.getUserActivity(
                            phone: phoneController.text.trim().toString());

                        await Future.wait([f1]);
                        if (pageMainScreenController.userActivity.isActive ==
                            false) {
                          NavigatorApp.pop();

                          await showBlockedDialog();
                        }
                        List<CartModel> cartProvider = cartController.cartItems;
                        PackageInfo packageInfo =
                            await PackageInfo.fromPlatform();
                        String versionCode = packageInfo.version;
                        String platform = "";
                        if (kIsWeb) {
                          platform = "Web";
                        } else if (Platform.isAndroid) {
                          platform = 'Android';
                        } else if (Platform.isIOS) {
                          platform = 'IOS';
                        }
                        await orderControllerSalah.getCheckPendingOrder(
                            phone: phoneController.text.trim().toString());

                        if (orderControllerSalah.checkPendingOrder?.success ==
                            true) {
                          await dialogMergeOrder();
                        }

                        Map<int, String> orderSuccess = await addOrder(
                            context: context,
                            cartProvider: cartProvider,
                            address: selectedArea?.name.toString() ?? "",
                            city: selectedArea!.cityName.toString(),
                            phone: phoneController.text,
                            name: nameController.text,
                            description: (widget.pointControllerText
                                        .toString() ==
                                    "0")
                                ? "The version is: $platform,$versionCode\n${orderController.text}, delivery: ${widget.delivery.toString()}"
                                : "The version is: $platform,$versionCode\nused Point: ${widget.pointControllerText.toString()} (${pointsController.shekelText}) \n${orderController.text}, delivery: ${widget.delivery.toString()}",
                            total: widget.total.toString(),
                            copon: widget.couponControllerText,
                            areaID: selectedArea!.areaId.toString(),
                            areaName: selectedArea!.areaName.toString(),
                            cityID: selectedArea!.cityId.toString(),

                            // hasOrder: "",
                            hasOrder: (orderControllerSalah
                                        .checkPendingOrder?.success ==
                                    true)
                                ? ((orderControllerSalah.doMergeOrder)
                                    ? (orderControllerSalah
                                            .checkPendingOrder?.orderId
                                            .toString() ??
                                        "")
                                    : "")
                                : "",
                            delivery: widget.delivery);

                        if ((orderSuccess.containsKey(200) ||
                                orderSuccess.containsKey(201)) &&
                            (orderSuccess.values.first != "")) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String userID = prefs.getString('user_id') ?? "";
                          String? token = prefs.getString('device_token');
                          if (widget.usedWheelCoupon) {
                            await prefs.setBool("wheel_coupon", false);
                          }
                          await prefs.setString('name', nameController.text);
                          await prefs.setString(
                              'city', finalSelectedArea.toString());
                          await prefs.setString('area', areaController.text);
                          await prefs.setString('phone', phoneController.text);
                          await prefs.setString(
                              'address', finalSelectedArea.toString());
                          UserItem updatedUser = UserItem(
                            name: nameController.text,
                            id: userID,
                            token: token.toString(),
                            email: "$userID@email.com",
                            phone: phoneController.text,
                            gender: '',
                            birthdate: '',
                            city: finalSelectedArea.toString(),
                            area: finalSelectedArea.toString(),
                            address: finalSelectedArea.toString(),
                            password: '123',
                          );
                          try {
                            await userService.updateUser(updatedUser);
                            await getCoupunRedeem(couponController.text);
                            printLog(
                                "Usergggggggggggggggggggggggggggggggggggggggg");
                            printLog(widget.totalWithoutDelivery);
                            // Execute the two points update functions in parallel

                            // pointsController.updateUserPointsAndLevel(
                            //     phone: phoneController.text.toString(),
                            //     newAmount: widget.totalWithoutDelivery
                            //         .toString(),
                            //     enumNumber: 5),
                            if (widget.pointControllerText.toString() != "0") {
                              await pointsController.updateUserPointsAndLevel(
                                  phone: phoneController.text.toString(),
                                  newAmount:
                                      "-${widget.pointControllerText.toString()}",
                                  enumNumber: 6);
                            }

                            final f2 = pointsController.getPointsFromAPI(
                                phone: phoneController.text.trim().toString());
                            final f3 = orderControllerSalah.initialsOrders(
                                phone: phoneController.text.trim().toString());
                            await Future.wait([f2, f3]);

                            await cartController.deleteAllItemFromCart();

                            await pointsController.clearAllDataPointPage();
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setBool('buy', true);

                            await orderControllerSalah.changeLoading3(false);

                            NavigatorApp.pop();

                            NavigatorApp.pop();
                            NavigatorApp.pop();

                            dialogSuccessOrder(
                                userID: userID,
                                nameController: nameController,
                                phoneController: phoneController,
                                token: token.toString(),
                                selectedArea: selectedArea.toString());

                            await analyticsService.logPurchase(
                              amount:
                                  double.tryParse(widget.total.toString()) ??
                                      0.0,
                              parameters: {
                                "class_name": "CheckoutSecondScreen",
                                "button_name": "تأكيد عمليه الشراء",
                                "order_id": orderSuccess.values.first,
                                "total_price": widget.total.toString(),
                                "currency": "NIS",
                                "city": finalSelectedArea.toString(),
                                "area": areaController.text,
                                "time": DateTime.now().toString(),
                              },
                            );
                          } catch (e) {
                            await orderControllerSalah.changeLoading3(false);
                            NavigatorApp.pop();

                            NavigatorApp.pop();
                            NavigatorApp.pop();
                            NavigatorApp.pop();
                            NavigatorApp.pop();

                            await customPageController.changeIndexPage(0);

                            await customPageController
                                .changeIndexCategoryPage(1);

                            NavigatorApp.navigateToRemoveUntil(Pages());
                          }
                        } else {
                          await orderControllerSalah.changeLoading3(false);
                          NavigatorApp.pop();

                          await dialogErrorOrder();
                        }
                      }
                    }
                  })),
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: CustomAppBar(
                title: "فوري",
                textButton: "رجوع",
                onPressed: () {
                  NavigatorApp.pop();
                },
                actions: [],
                colorWidgets: Colors.white,
              )),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 25,
                left: 25,
              ),
              child: Form(
                  key: _formKey,
                  child: Column(
                  key: Key("1"),
                  children: [
                    Column(
                      spacing: 10.h,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  spacing: 10.h,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "أسم المستخدم",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: mainColor),
                                        ),
                                      ],
                                    ),
                                    editName
                                        ? CustomTextFormFieldProfile(
                                            hintText: "ادخل اسم المستخدم",
                                            // label: "اسم المستخدم",
                                            inputType: TextInputType.text,
                                            prefixIcon: Icon(
                                                CupertinoIcons.profile_circled),
                                            controller: nameController,
                                            hasFocusBorder: true,
                                            hasFill: true,
                                            textAlign: TextAlign.center,
                                            hasSeePassIcon: true,
                                            hintStyle: CustomTextStyle()
                                                .rubik
                                                .copyWith(
                                                    color: Colors.grey,
                                                    fontSize: 11.sp),
                                            textStyle: CustomTextStyle()
                                                .rubik
                                                .copyWith(
                                                    color: CustomColor.blueColor,
                                                    fontSize: 11.sp),
                                            controlPage: null,
                                            maxLines: 1)
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15, left: 25),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      nameController.text,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255, 83, 83, 83),
                                                          fontSize: 20),
                                                    ),
                                                    IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            editName = true;
                                                          });
                                                        },
                                                        icon: Icon(Icons.edit))
                                                  ],
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  height: 1,
                                                  color: Color.fromARGB(
                                                      255, 39, 38, 38),
                                                )
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Column(
                            spacing: 4.h,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "رقم الهاتف",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: mainColor),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              editPhone
                                    ? CustomTextFormFieldProfile(
                                        // label: 'رقم الهاتف',
                                        inputType: TextInputType.number,
                                        prefixIcon:
                                            Icon(CupertinoIcons.phone),
                                        validate: validatePhoneNumber,
                                        controller: phoneController,
                                        hintText: 'ادخل رقم الهاتف',
                                        hasFocusBorder: true,
                                        hasFill: true,
                                        textAlign: TextAlign.center,
                                        // keyboardType:
                                        //       TextInputType.number,
                                        hasSeePassIcon: true,
                                        hintStyle: CustomTextStyle().rubik.copyWith(
                                            color: Colors.grey, fontSize: 11.sp),
                                        textStyle: CustomTextStyle().rubik.copyWith(
                                            color: CustomColor.blueColor,
                                            fontSize: 11.sp),
                                        controlPage: null,
                                        maxLines: 1)
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            right: 15, left: 25),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  phoneController.text,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 83, 83, 83),
                                                      fontSize: 20),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        editPhone = true;
                                                      });
                                                    },
                                                    icon: Icon(Icons.edit))
                                              ],
                                            ),
                                            Container(
                                              width: double.infinity,
                                              height: 1,
                                              color:
                                                  Color.fromARGB(255, 39, 38, 38),
                                            )
                                          ],
                                        ),
                                      ),

                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "العنوان : ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Consumer<AddressProvider>(
                      builder: (context, addressprovider, _) {
                        List<AddressItem> allAddressItems =
                            addressprovider.addressItems;

                        // Filter addresses based on the selected region from CheckoutController
                        List<AddressItem> addressItems = allAddressItems;
                        String currentRegion = checkoutController.dropdownValue;

                        printLog("=== Address Filter Debug ===");
                        printLog("Current Region: $currentRegion");
                        printLog("Total Addresses: ${allAddressItems.length}");

                        if (currentRegion != "" && currentRegion != "اختر منطقتك") {
                          List<String> allowedCities = getCityNamesByRegion(currentRegion);
                          printLog("Allowed Cities: $allowedCities");

                          addressItems = allAddressItems.where((address) {
                            printLog("Checking address: ${address.name} - City: ${address.cityName}");
                            return allowedCities.contains(address.cityName);
                          }).toList();

                          printLog("Filtered Addresses Count: ${addressItems.length}");
                        }

                        // Check if the currently selected address is still in the filtered list
                        bool isSelectedAreaValid = selectedArea != null &&
                            addressItems.any((item) => item.id == selectedArea!.id);

                        AddressItem? selectedValue;
                        if (addressItems.isNotEmpty) {
                          if (isSelectedAreaValid) {
                            selectedValue = addressItems.firstWhere(
                              (item) => item.id == selectedArea!.id
                            );
                          } else {
                            selectedValue = addressItems[0];
                            // Update selectedArea if it's not valid for this region
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  selectedArea = addressItems[0];
                                  finalSelectedArea = addressItems[0].name;
                                });
                              }
                            });
                          }
                        }

                        return Visibility(
                          visible: addressItems.isNotEmpty,
                          child: DropdownButtonFormField<AddressItem>(
                            hint: Text("اختر العنوان"),

                            borderRadius: BorderRadius.circular(12.r),
                            value: selectedValue,
                            items: addressItems
                                .map((address) => DropdownMenuItem<AddressItem>(
                                      value: address,
                                      child: Text(address.name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedArea = value! as AddressItem?;
                                finalSelectedArea = value.name;
                              });

                            },
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: mainColor, width: 2.0),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 1.0, color: mainColor),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15, right: 15, left: 15, bottom: 10),
                      child: InkWell(
                        onTap: () async {
                          // The region is already set in CheckoutController, just navigate
                          NavigatorApp.push(AddAddress());
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Image.asset(
                                Assets.images.add.path,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "اضافة عنوان جديد ؟ ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 5, right: 15, left: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "ملاحظات",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: SizedBox(
                            height: 80,
                            width: double.infinity,
                            child: TextField(
                              controller: orderController,
                              obscureText: false,
                              maxLines: 5,
                              textInputAction: TextInputAction.done,

                              decoration: InputDecoration(

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide:
                                      BorderSide(color: mainColor, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide:

                                      BorderSide(width: 1.0, color: mainColor),
                                ),
                                hintText: "أضف ملاحظاتك",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء أدخل رقم الهاتف';
    }
    if (value.length != 10) {
      return 'يجب أن يكون مجموع خانات الهاتف 10 أرقام';
    }
    if (!value.startsWith('05')) {
      return 'رقم الهاتف يجب ان يبدأ ب 05';
    }
    return null;
  }
}
