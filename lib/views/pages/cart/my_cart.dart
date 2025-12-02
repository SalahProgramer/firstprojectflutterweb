import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/custom_page_controller.dart';
import '../../../controllers/order_controller.dart';
import '../../../core/utilities/global/app_global.dart';
import '../../../core/utilities/routes.dart';
import '../../../core/utilities/print_looger.dart';
import '../../../core/utilities/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/utilities/style/text_style.dart';
import '../../../core/widgets/app_bar_widgets/app_bar_custom.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/empty_widget.dart';
import '../../../core/widgets/widgets_carts/how_to_delete_card.dart';
import '../../../core/widgets/widgets_carts/widget_each_card.dart';
import 'button_cart.dart';

class MyCart extends StatefulWidget {
  const MyCart({super.key});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  late ItemScrollController scrollController;
  late ItemScrollController scrollController1;

  @override
  void initState() {
    super.initState();
    // Initialize the ItemScrollController
    scrollController = ItemScrollController();
    scrollController1 = ItemScrollController();
    
    // Clear availabilities when cart opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearAndInitializeAvailability();
    });
  }

  void _clearAndInitializeAvailability() async {
    CartController cartController = context.read<CartController>();
    
    // Clear all availability data when opening cart
    await cartController.clearAvailabilities();
    
    // Initialize default availability data for all cart items if needed
    if (cartController.cartItems.isNotEmpty) {
      await cartController.initializeDefaultAvailability();
    }
    
    printLog("Cart opened - cleared and reinitialized availability data");
  }

  @override
  Widget build(BuildContext context) {
    CartController cartController = context.watch<CartController>();
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    OrderControllerSalah orderControllerSalah =
        context.watch<OrderControllerSalah>();

    return Scaffold(
      extendBody: (cartController.firstShowDelete) ? true : false,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "سلتي",
        textButton: "رجوع",
        onPressed: () async {
          if (Navigator.of(context).canPop() == true) {
            NavigatorApp.pop();
          } else {
            await customPageController.changeIndexPage(0);
            await customPageController.changeIndexCategoryPage(1);
            NavigatorApp.navigateToRemoveUntil(AppRoutes.pages);
          }
        },
        actions: [
          IconSvg(
            nameIcon: Assets.icons.order,
            onPressed: () async {
              await orderControllerSalah.changePageOrder(0);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String phone = prefs.getString('phone') ?? "";
              String userId = prefs.getString('user_id') ?? "";

              NavigatorApp.pushName(
                AppRoutes.ordersPages,
                arguments: {
                  'phone': phone,
                  'userId': userId,
                },
              );
            },
            backColor: Colors.transparent,
            height: 28.h,
          )
        ],
        colorWidgets: Colors.black,
      ),
      bottomNavigationBar: ButtonCart(
        scrollController: scrollController,
        scrollController1: scrollController1,
      ),
      body: (cartController.cartItems.isEmpty)
          ? Center(
              child: EmptyWidget(
                text: "لا يوجد منتجات بالسلة",
                hasButton: true,
                iconName: Assets.icons.cartEmpty,
              ),
            )
          : Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: Text(
                                  "عدد المنتجات بالسلة :",
                                  textDirection: TextDirection.rtl,
                                  overflow: TextOverflow.ellipsis,
                                  style: CustomTextStyle().heading1L.copyWith(
                                        color: Colors.black,
                                        fontSize: 14.sp,
                                      ),
                                ),
                              ),
                            ),
                            // Second row content (Cart items count)
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: Text(
                                  "${cartController.cartItems.length}",
                                  textDirection: TextDirection.rtl,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: CustomTextStyle().heading1L.copyWith(
                                        color: CustomColor.blueColor,
                                        fontSize: 15.sp,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.h),
                      SizedBox(
                        height: 23.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // First row content (مجموع القطع)
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: Text(
                                  "مجموع القطع : ",
                                  textDirection: TextDirection.rtl,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: CustomTextStyle().heading1L.copyWith(
                                        color: Colors.black,
                                        fontSize: 14.sp,
                                      ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "${cartController.totalItemsPrice.toString()} ₪",
                                textDirection: TextDirection.rtl,
                                overflow: TextOverflow.ellipsis,
                                style: CustomTextStyle().heading1L.copyWith(
                                      color: CustomColor.primaryColor,
                                      fontSize: 15.sp,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Expanded(
                        child: ScrollablePositionedList.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemScrollController: scrollController,
                          shrinkWrap: true,
                          itemCount: cartController.cartItems.length,
                          itemBuilder: (context, i) {
                            final reversedIndex =
                                cartController.cartItems.length - 1 - i;
                            // Get availability info, handling cases where availability list might be shorter
                            String availabilityInfo = "true";
                            if (reversedIndex < cartController.availability.length) {
                              var availabilityData = cartController.availability[reversedIndex];
                              if (availabilityData.availableQuantity != null && 
                                  availabilityData.availability == "false") {
                                availabilityInfo = "false, available quantity: ${availabilityData.availableQuantity}";
                              } else {
                                availabilityInfo = availabilityData.availability.toString();
                              }
                            }
                            
                            return WidgetEachCard(
                              index: reversedIndex,
                              cartItem: cartController.cartItems[reversedIndex],
                              avaliable: availabilityInfo,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (cartController.firstShowDelete) HowToDeleteCard(),
              ],
            ),
    );
  }
}
