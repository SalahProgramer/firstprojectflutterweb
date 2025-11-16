import 'package:fawri_app_refactor/gen/assets.gen.dart';
import 'package:fawri_app_refactor/salah/controllers/order_controller.dart';
import 'package:fawri_app_refactor/salah/utilities/style/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import '../../../constants/constant_data_convert.dart';
import '../../../controllers/custom_page_controller.dart';
import '../../../models/order/order_detail_model.dart';
import '../../../utilities/global/app_global.dart';
import '../../../widgets/app_bar_widgets/app_bar_custom.dart';
import '../../../widgets/lottie_widget.dart';
import '../../../widgets/widget_orders/widget_button_order.dart';
import '../../../widgets/widget_orders/widget_specidic_order.dart';
import '../pages.dart';

class OrdersPages extends StatefulWidget {
  final String phone;
  final String userId;

  const OrdersPages({super.key, required this.phone, required this.userId});

  @override
  State<OrdersPages> createState() => _OrdersPagesState();
}

class _OrdersPagesState extends State<OrdersPages> {
  late ScrollController scrollController;
  Set<int> triggeredIndexes = {}; // Track triggered indexes

  @override
  void initState() {
    scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      OrderControllerSalah orderControllerSalah =
          context.read<OrderControllerSalah>();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? phone = prefs.getString("phone");

      // Check if scroll controller is still mounted before adding listener
      if (!scrollController.hasClients) return;
      
      scrollController.addListener(() async {
        // Safety check: ensure scroll controller is still valid
        if (!scrollController.hasClients) return;
        int firstVisibleIndex = getFirstVisibleIndex();

        if (firstVisibleIndex != -1 && firstVisibleIndex % 7 == 0) {
          if (!triggeredIndexes.contains(firstVisibleIndex)) {
            triggeredIndexes.add(firstVisibleIndex);
            if (orderControllerSalah.pageOrder == 0) {
              if (phone != "") {
                await orderControllerSalah.getNewestOrders(phone ?? "", 2);
              }
            } else {
              if (phone != "") {
                await orderControllerSalah.getOlderOrders(phone ?? "", 2);
              }
            }
          }
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (scrollController.hasClients) {
      scrollController.dispose();
    }
    super.dispose();
  }

  int getFirstVisibleIndex() {
    if (scrollController.positions.isEmpty) return -1;

    try {
      for (int i = 0; i < scrollController.position.maxScrollExtent; i++) {
        final key = GlobalObjectKey(i);
        final context = key.currentContext;

        if (context != null) {
          final RenderBox itemBox = context.findRenderObject() as RenderBox;
          final position = itemBox.localToGlobal(Offset.zero).dy;

          if (position >= 0) {
            return i; // Return first fully visible index
          }
        }
      }
    } catch (e) {
      return -1;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    CustomPageController customPageController =
        context.watch<CustomPageController>();
    OrderControllerSalah orderControllerSalah =
        context.watch<OrderControllerSalah>();

    return Scaffold(
      appBar: CustomAppBar(
        title: "الطللبات",
        textButton: "رجوع",
        onPressed: () async {
          if (Navigator.of(context).canPop() == true) {
            NavigatorApp.pop();
          } else {
            NavigatorApp.pushReplacment(Pages());

            await customPageController.changeIndexPage(0);
            await customPageController.changeIndexCategoryPage(1);
          }
        },
        actions: [],
        colorWidgets: Colors.white,
      ),
      body: SafeArea(
          child: Column(children: [
        SizedBox(height: 10.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.w),
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black45,
                  blurStyle: BlurStyle.outer,
                  spreadRadius: 2,
                  blurRadius: 3)
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                order(orderControllerSalah.newestOrder, "طلباتك الحالية", 0,
                    orderControllerSalah),
                SizedBox(
                  width: 10.w,
                ),
                Container(
                  width: 3.w,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10.r),
                      bottom: Radius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                order(orderControllerSalah.oldestOrder, "طلباتك السابقة", 1,
                    orderControllerSalah),
              ],
            ),
          ),
        ),
        SizedBox(height: 5.h),
        (orderControllerSalah.pageOrder == 0)
            ? selected(
                selectOrder: orderControllerSalah.newestOrder,
                orderControllerSalah: orderControllerSalah)
            : selected(
                selectOrder: orderControllerSalah.oldestOrder,
                orderControllerSalah: orderControllerSalah)
      ])),
    );
  }

  Widget empty(int page) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            style: CustomTextStyle().heading1L.copyWith(
                  fontSize: 15.sp,
                  height: 1.2.h,
                  color: Colors.black,
                ),
            (page == 0) ? "لا يوجد طللبات حالية" : "لا يوجد طللبات سابقة",
          ),
          SizedBox(height: 5.h),
          LottieWidget(
            name: Assets.lottie.emptyOrder,
            width: 70.w,
            height: 70.w,
          )
        ],
      ),
    );
  }

  Widget order(List<OrderDetailModel> order, String title, int page,
      OrderControllerSalah orderControllerSalah) {
    return WidgetButtonOrder(
      title: title,
      page: page,
      number: ((order[0].orderId == -1) || (order[0].orderId == 0))
          ? 0.toString()
          : (page == 0)
              ? orderControllerSalah.numberOrderNewest.toString()
              : orderControllerSalah.numberOrderOldest
                  .toString()
                  .toString(), // Pass the length
    );
  }

  Widget selected(
      {required List<OrderDetailModel> selectOrder,
      required OrderControllerSalah orderControllerSalah}) {
    return ((selectOrder[0].orderId == 0)
        ? (Expanded(
            child: Center(
            child: SpinKitPulse(
              color: mainColor,
              size: 40.h,
            ),
          )))
        : ((selectOrder[0].orderId == -1)
            ? Expanded(
                child: Center(child: empty(orderControllerSalah.pageOrder)))
            : Expanded(
                child: Column(
                children: [
                  Text(
                    (orderControllerSalah.pageOrder == 0)
                        ? "الطللبات الحالية"
                        : "الطللبات السابقة",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyle().heading1L.copyWith(
                          fontSize: 15.sp,
                          height: 1.2.h,
                          color: Colors.black,
                        ),
                  ),
                  SizedBox(height: 5.h),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10.h),
                        itemCount: selectOrder.length,
                        controller: scrollController,
                        itemBuilder: (context, index) {
                          return WidgetSpecificOrder(
                            key: GlobalObjectKey(index),
                            index: index,
                            newestOrder: selectOrder[index],
                            userId: widget.phone,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ))));
  }
}
