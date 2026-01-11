import 'package:fawri_app_refactor/firebase/user/user_controller.dart';
import 'package:fawri_app_refactor/salah/constants/constant-categories/constant_data_convert.dart';
import 'package:fawri_app_refactor/salah/controllers/cart_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/checks_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/custom_page_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/points_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/rating_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/notification_controller.dart';
import 'package:fawri_app_refactor/salah/controllers/showcase_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:fawri_app_refactor/salah/views/pages/cart/my_cart.dart';
import 'package:fawri_app_refactor/salah/views/pages/points/users_points.dart';
import 'package:fawri_app_refactor/salah/widgets/profile_tile_widgets.dart';
import 'package:fawri_app_refactor/salah/widgets/snackBarWidgets/snack_bar_style.dart';
import 'package:fawri_app_refactor/salah/widgets/snackBarWidgets/snackbar_widget.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:fawri_app_refactor/services/analytics/analytics_service.dart';
import 'package:fawri_app_refactor/dialog/dialogs/dialog_waiting/dialog_waiting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../../../pages/account_information/account_information.dart';
import '../../../controllers/birthday_controller.dart';
import '../../../controllers/order_controller.dart';
import '../../../controllers/favourite_controller.dart';
import '../../../localDataBase/sql_database.dart';
import '../../../../LocalDB/Database/data_base.dart';
import '../../../../LocalDB/Database/local_storage.dart';
import '../../../../LocalDB/Provider/address_provider.dart';
import '../../../utilities/style/colors.dart';
import '../orders/new_orders.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  String userId = "";

  setControllers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('user_id') ?? "";
    userId = userID;

    // Initialize notification controller
    NotificationController notificationController = context
        .read<NotificationController>();
    await notificationController.initializeNotificationStatus();

    setState(() {});
  }

  final RateMyApp rateMyApp = RateMyApp(
    minDays: 0,
    minLaunches: 1,
    remindDays: 0,
    appStoreIdentifier: "co.fawri.fawri",
    googlePlayIdentifier: "fawri.app.shop",
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      RatingController ratingController = context.read<RatingController>();
      await ratingController.getIsRating();
    });
    setControllers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Check notification permission when app resumes (user might have changed it in settings)
      NotificationController notificationController = context
          .read<NotificationController>();
      notificationController.initializeNotificationStatus();
    }
  }

  final UserService userService = UserService();

  deleteUser() async {
    try {
      await userService.deleteUserById(userId);
    } catch (e) {
      // Handle errors, show alerts, etc.
      printLog('Error deleting user: $e');
    }
  }

  _confirmDeleteUser({
    required PageMainScreenController pageMainScreenController,
    required CustomPageController customPageController,
    required ShowcaseController showcaseController,
    required PointsController pointsController,
    required ChecksController checksController,
    required OrderControllerSalah orderControllerSalah,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("هل تريد بالتأكيد حذف هذا حسابك"),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                  InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    
                    // Show waiting dialog
                    dialogWaiting();
                    
                    try {
                      // Delete user from Firebase
                      await deleteUser();
                      
                      // Clear user activity
                      await pageMainScreenController.clearUserActivity();
                      
                      // Reset all points data using controller method
                      await pointsController.resetAllPointsData();

                      // Clear all orders (previous and current)
                      await orderControllerSalah.clearAllOrders();

                      // Clear all databases (cart, favorites, phone, etc.)
                      await _clearAllUserData();
                      
                      // Clear SharedPreferences (including showcase flags)
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      await preferences.clear();
                      
                      // Reset showcase controller values in memory
                      showcaseController.resetShowcases();
                      
                      // Auto-create new user after deletion
                      await checksController.checkFirstSeen(); // Update firstScreen flag
                      await checksController.autoAddUser(); // Create new user
                      
                      // Reset to page index 0
                      await customPageController.changeIndexPage(0);
                      await customPageController.changeIndexCategoryPage(0);
                      
                      // Close waiting dialog
                      NavigatorApp.pop();
                      
                      showSnackBar(title: "تم حذف حسابك بنجاح!", type: SnackBarType.success);
                    } catch (e) {
                      // Close waiting dialog on error
                      NavigatorApp.pop();
                      printLog("Error deleting account: $e");
                      Fluttertoast.showToast(msg: "حدث خطأ أثناء حذف الحساب");
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: mainColor,
                    ),
                    child: Center(
                      child: Text(
                        "نعم",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: mainColor,
                    ),
                    child: Center(
                      child: Text(
                        "لا",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    CartController cartController = context.watch<CartController>();
    AnalyticsService analyticsService = AnalyticsService();
    PageMainScreenController pageMainScreenController = context
        .watch<PageMainScreenController>();
    CustomPageController customPageController = context
        .watch<CustomPageController>();
    OrderControllerSalah orderControllerSalah = context
        .watch<OrderControllerSalah>();
    PointsController pointsControllerClass = context.watch<PointsController>();
    NotificationController notificationController = context
        .watch<NotificationController>();
    BirthdayController birthdayController = context.watch<BirthdayController>();
    // Get ShowcaseController before clearing
    ShowcaseController showcaseController = context.watch<ShowcaseController>();
    ChecksController checksController = context.watch<ChecksController>();

    final hSpace = SizedBox(height: 10.h);
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            top: 40.h,
            left: 10.w,
            right: 10.w,
            bottom: 10.h,
          ),
          color: Colors.white,
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              ListView(
                // padding: const EdgeInsets.all(40.0),
                children: [
                  hSpace,
                  ProfileTilesCard(
                    child: Column(
                      children: [
                        ProfileTile(
                          icon: Icon(Icons.shopping_cart, color: Colors.black),
                          title: "السلة",
                          onPressed: () async {
                            await analyticsService.logEvent(
                              eventName: "profile_cart_pressed",
                              parameters: {
                                "class_name": "ProfileScreen",
                                "button_name": "ProfileTile (السلة)",
                                "time": DateTime.now().toString(),
                              },
                            );
                            await cartController.getCartItems();

                            NavigatorApp.push(MyCart());
                          },
                        ),
                        tilesDivider,
                        ProfileTile(
                          icon: Icon(Icons.favorite, color: Colors.black),
                          title: "المفضلة",
                          onPressed: () async {
                            await analyticsService.logEvent(
                              eventName: "profile_favourite_pressed",
                              parameters: {
                                "class_name": "ProfileScreen",
                                "button_name": "ProfileTile (المفضلة)",
                                "time": DateTime.now().toString(),
                              },
                            );
                            await customPageController.changeIndexPage(2);
                            await customPageController.changeIndexCategoryPage(
                              0,
                            );
                          },
                        ),
                        tilesDivider,
                        ProfileTile(
                          icon: Image(
                            image: AssetImage(Assets.images.orderDelivery.path),
                            height: 20.w,
                            width: 20.w,
                            // 90% of screen width
                            fit: BoxFit.contain,
                          ),
                          title: "طلباتي الحالية",
                          onPressed: () async {
                            await analyticsService.logEvent(
                              eventName: "profile_current_orders_pressed",
                              parameters: {
                                "class_name": "ProfileScreen",
                                "button_name": "ProfileTile (طلباتي الحالية)",
                                "time": DateTime.now().toString(),
                              },
                            );
                            await orderControllerSalah.changePageOrder(0);
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            String phone = prefs.getString('phone') ?? "";
                            NavigatorApp.push(
                              OrdersPages(userId: userId, phone: phone),
                            );
                          },
                        ),
                        tilesDivider,
                        ProfileTile(
                          icon: Image(
                            image: AssetImage(Assets.images.orderDelivery.path),
                            height: 20.w,
                            width: 20.w,
                            // 90% of screen width
                            fit: BoxFit.contain,
                          ),
                          title: "طلباتي السابقة",
                          onPressed: () async {
                            await analyticsService.logEvent(
                              eventName: "profile_previous_orders_pressed",
                              parameters: {
                                "class_name": "ProfileScreen",
                                "button_name": "ProfileTile (طلباتي السابقة)",
                                "time": DateTime.now().toString(),
                              },
                            );
                            await orderControllerSalah.changePageOrder(1);
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            String phone = prefs.getString('phone') ?? "";

                            NavigatorApp.push(
                              OrdersPages(userId: userId, phone: phone),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  hSpace,
                  ProfileTilesCard(
                    child: Column(
                      children: [
                        ProfileTile(
                          icon: Icon(Icons.person, color: Colors.black),
                          title: "المعلومات الشخصية",
                          onPressed: () async {
                            await analyticsService.logEvent(
                              eventName: "profile_account_info_pressed",
                              parameters: {
                                "class_name": "ProfileScreen",
                                "button_name":
                                    "ProfileTile (المعلومات الشخصية)",
                                "time": DateTime.now().toString(),
                              },
                            );
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String name = prefs.getString('name') ?? "";
                            String phone = prefs.getString('phone') ?? "";
                            String address = prefs.getString('address') ?? "";
                            String area = prefs.getString('area') ?? "";
                            String city = prefs.getString('city') ?? "";
                            String birthday =
                                prefs.getString('birthdate') ?? "";
                            pointsControllerClass.phoneProfileController.text =
                                phone;
                            pointsControllerClass.nameProfileController.text =
                                name;
                            birthdayController.birthdayProfileController.text =
                                birthday;
                            NavigatorApp.push(
                              AccountInformation(
                                address: address,
                                area: area,
                                city: city,
                                birthday: birthday,
                                name: name,
                                phone: phone,
                              ),
                            );
                          },
                        ),
                        tilesDivider,
                        ProfileTile(
                          icon: Icon(Icons.stars_sharp, color: Colors.black),
                          title: "نقاطي",
                          onPressed: () async {
                            await analyticsService.logEvent(
                              eventName: "profile_points_pressed",
                              parameters: {
                                "class_name": "ProfileScreen",
                                "button_name": "ProfileTile (نقاطي)",
                                "time": DateTime.now().toString(),
                              },
                            );
                            NavigatorApp.push(UsersPointsPage());
                          },
                        ),
                        tilesDivider,
                        ProfileTile(
                          icon: Icon(Icons.notifications, color: Colors.black),
                          title: "الإشعارات",
                          trailing: Switch(
                            value: notificationController.notificationsEnabled,
                            trackColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return CustomColor.blueColor;
                              }
                              return Colors.grey.shade700;
                            }),
                            thumbColor: const WidgetStatePropertyAll<Color>(
                              Colors.white,
                            ),
                            onChanged: (bool value) async {
                              await notificationController
                                  .handleNotificationToggle(value, context);
                              await analyticsService.logEvent(
                                eventName: value
                                    ? "notifications_on"
                                    : "notifications_off",
                                parameters: {
                                  "class_name": "ProfileScreen",
                                  "button_name": "الإشعارات",
                                  "status": value ? "on" : "off",
                                  "time": DateTime.now().toString(),
                                },
                              );
                            },
                          ),
                          onPressed: () {},
                        ),

                        // tilesDivider,
                        // ProfileTile(
                        //   icon: Icon(
                        //     Icons.bug_report,
                        //     color: Colors.orange,
                        //   ),
                        //   title: "اختبار Firebase",
                        //   onPressed: () async {
                        //     await notificationController.testFirebaseNotification(context);
                        //   },
                        //                         ),
                      ],
                    ),
                  ),
                  hSpace,
                  ProfileTilesCard(
                    child: Column(
                      children: [
                        // ProfileTile(
                        //   icon: Icon(
                        //     Icons.star_rate,
                        //     color: Colors.black,
                        //   ),
                        //   title: "قيم واربح",
                        //   onPressed: ((fetchController.showRateApp == true) &&
                        //           (ratingController.isRating == false) &&
                        //           (ratingController.hasPhone != ""))
                        //       ? () async {
                        //           rateMyApp.init().then((value) async {
                        //             for (var condition in rateMyApp.conditions) {
                        //               if (condition is DebuggableCondition) {
                        //                 printLog(condition.toString());
                        //               }
                        //             }
                        //
                        //             await ratingController.changeRateApp(0.0);
                        //             dialogRatingApp(rateMyApp: rateMyApp);
                        //           });
                        //         }
                        //       : null,
                        // ),
                        // tilesDivider,
                        ProfileTile(
                          icon: Icon(Icons.info, color: Colors.black),
                          title: "معلومات عنا",
                          onPressed: () async {
                            await analyticsService.logEvent(
                              eventName: "profile_about_pressed",
                              parameters: {
                                "class_name": "ProfileScreen",
                                "button_name": "ProfileTile (معلومات عنا)",
                                "time": DateTime.now().toString(),
                              },
                            );
                            final url = Uri.parse("https://www.fawri.co/about");
                            if (!await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            )) {
                              Fluttertoast.showToast(
                                msg:
                                    "لم يتم التمكن من الدخول الرابط , الرجاء المحاولة فيما بعد",
                              );
                            }
                          },
                        ),
                        tilesDivider,
                        ProfileTile(
                          icon: Icon(Icons.privacy_tip, color: Colors.black),
                          title: "سياسة الخصوصية",
                          onPressed: () async {
                            await analyticsService.logEvent(
                              eventName: "profile_privacy_policy_pressed",
                              parameters: {
                                "class_name": "ProfileScreen",
                                "button_name": "ProfileTile (سياسة الخصوصية)",
                                "time": DateTime.now().toString(),
                              },
                            );
                            final url0 = Uri.parse(
                              "https://www.fawri.co/privacy_policy",
                            );
                            if (!await launchUrl(
                              url0,
                              mode: LaunchMode.externalApplication,
                            )) {
                              Fluttertoast.showToast(
                                msg:
                                    "لم يتم التمكن من الدخول الرابط , الرجاء المحاولة فيما بعد",
                              );
                            }
                          },
                        ),
                        tilesDivider,
                        ProfileTile(
                          icon: Icon(Icons.privacy_tip, color: Colors.black),
                          title: "سياسة التبديل",
                          onPressed: () async {
                            await analyticsService.logEvent(
                              eventName: "profile_switch_policy_pressed",
                              parameters: {
                                "class_name": "ProfileScreen",
                                "button_name": "ProfileTile (سياسة التبديل)",
                                "time": DateTime.now().toString(),
                              },
                            );
                            final url1 = Uri.parse(
                              "https://www.fawri.co/switch_policy",
                            );
                            if (!await launchUrl(
                              url1,
                              mode: LaunchMode.externalApplication,
                            )) {
                              Fluttertoast.showToast(
                                msg:
                                    "لم يتم التمكن من الدخول الرابط , الرجاء المحاولة فيما بعد",
                              );
                            }
                          },
                        ),
                        tilesDivider,
                        ProfileTile(
                          icon: Icon(Icons.support, color: Colors.black),
                          title: "تواصل معنا للدعم",
                          onPressed: () async {
                            await analyticsService.logEvent(
                              eventName: "profile_support_pressed",
                              parameters: {
                                "class_name": "ProfileScreen",
                                "button_name": "ProfileTile (تواصل معنا للدعم)",
                                "time": DateTime.now().toString(),
                              },
                            );
                            final url2 = Uri.parse(
                              "https://www.facebook.com/FawriCOD?mibextid=LQQJ4d",
                            );
                            if (!await launchUrl(
                              url2,
                              mode: LaunchMode.externalApplication,
                            )) {
                              Fluttertoast.showToast(
                                msg:
                                    "لم يتم التمكن من الدخول الرابط , الرجاء المحاولة فيما بعد",
                              );
                            }
                          },
                        ),
                        tilesDivider,
                        ProfileTile(
                          icon: Icon(Icons.delete, color: Colors.black),
                          title: "حذف حسابي",
                          onPressed: () async {
                            await _confirmDeleteUser(
                              pageMainScreenController:
                                  pageMainScreenController,
                              showcaseController: showcaseController,
                              customPageController: customPageController,
                              pointsController: pointsControllerClass,
                              checksController: checksController,
                              orderControllerSalah: orderControllerSalah,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
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
        ),
      ),
    );
  }

  /// Clear all user data from databases and local storage
  Future<void> _clearAllUserData() async {
    try {
      // Clear SQL Database (Cart, Favorites, etc.)
      SqlDb sqlDb = SqlDb();
      await sqlDb.deleteData(sql: "DELETE FROM 'cart'");
      await sqlDb.deleteData(sql: "DELETE FROM 'favourite'");
      await sqlDb.deleteData(sql: "DELETE FROM 'itemViewed'");
      await sqlDb.deleteData(sql: "DELETE FROM 'bigCategoriesImages'");

      // Clear Address Database
      CartDatabaseHelper addressDb = CartDatabaseHelper();
      await addressDb.clearUserAddress();

      // Clear Local Storage (Hive)
      LocalStorage localStorage = LocalStorage();
      localStorage.favoriteDataBox.clear();
      localStorage.sizeDataBox.clear();

      // Clear Controllers
      if (NavigatorApp.context.mounted) {
        // Clear Cart Controller
        CartController cartController = NavigatorApp.context
            .read<CartController>();
        cartController.cartItems.clear();
        cartController.totalItemsPrice = 0;

        // Clear Favourite Controller
        FavouriteController favouriteController = NavigatorApp.context
            .read<FavouriteController>();
        favouriteController.favouriteItems.clear();

        // Clear Address Provider
        AddressProvider addressProvider = NavigatorApp.context
            .read<AddressProvider>();
        await addressProvider.clearAddress();
      }

      printLog("All user data cleared successfully");
    } catch (e) {
      printLog("Error clearing user data: $e");
    }
  }

  @override
  bool get wantKeepAlive => true;
}
