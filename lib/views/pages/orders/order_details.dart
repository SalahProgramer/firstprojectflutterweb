import '../../../core/utilities/global/app_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fawri_app_refactor/gen/assets.gen.dart';
import '../../../core/utilities/style/colors.dart';
import '../../../core/widgets/app_bar_widgets/app_bar_custom.dart';
import '../../../models/order/order_detail_model.dart';

class OrderDetails extends StatefulWidget {
  final bool done;
  final OrderDetailModel newestOrder;

  const OrderDetails(
      {super.key, required this.done, required this.newestOrder});

  @override
  State<OrderDetails> createState() => OrderDateState();
}

class OrderDateState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    String createdAtString = widget.newestOrder.createdAt.toString();
    DateTime createdAt = DateTime.parse(createdAtString.replaceAll('-', ''));
    DateTime threeDaysLater = createdAt.add(Duration(days: 3));
    String formattedDate =
        "${threeDaysLater.day.toString().padLeft(2, '0')}-${threeDaysLater.month.toString().padLeft(2, '0')}-${threeDaysLater.year}";

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Scaffold(
          appBar: CustomAppBar(
            title: "حالة طلبك",
            colorWidgets: Colors.white,
            textButton: "رجوع",
            actions: [],
            onPressed: () => NavigatorApp.pop(),
          ),
          body: SingleChildScrollView(
              //     child:  String orderStatus = snapshot.data["data"]["status"];
              // bool isPending = orderStatus == 'Pending';
              // bool isShipped = orderStatus == 'Shipped';
              // bool isReceived = orderStatus == 'Received';

              child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              statusOrderMethod(
                firstText: "تم تقديم طلبك",
                lines: true,
                checkImage: ((widget.newestOrder.status == "Pending") ||
                        (widget.newestOrder.status == "Shipped") ||
                        (widget.newestOrder.status == "Received"))
                    ? Assets.images.icons8CheckMark501.path
                    : Assets.images.icons8CheckMark50.path,
                secondText:
                    "تم استلام طلبك لدينا ${widget.newestOrder.createdAt.toString()}",
                image: Assets.images.icons8Received96.path,
                isBold: ((widget.newestOrder.status == "Pending") ||
                    (widget.newestOrder.status == "Shipped") ||
                    (widget.newestOrder.status == "Received")),
              ),
              SizedBox(height: 10),
              statusOrderMethod(
                lines: true,
                firstText: "تجهيز الطلب",
                secondText: "تم نقل طلبك",
                checkImage: ((widget.newestOrder.status == "Pending") ||
                        (widget.newestOrder.status == "Shipped") ||
                        (widget.newestOrder.status == "Received"))
                    ? Assets.images.icons8CheckMark501.path
                    : Assets.images.icons8CheckMark50.path,
                image: Assets.images.icons8ShippingToDoor64.path,
                isBold: ((widget.newestOrder.status == "Pending") ||
                    (widget.newestOrder.status == "Shipped") ||
                    (widget.newestOrder.status == "Received")),
              ),
              SizedBox(height: 10),
              statusOrderMethod(
                lines: true,
                firstText: "جاهز للنقل",
                secondText: "تم تجهيز الطلب",
                checkImage: ((widget.newestOrder.status == "Shipped") ||
                        (widget.newestOrder.status == "Received"))
                    ? Assets.images.icons8CheckMark501.path
                    : Assets.images.icons8CheckMark50.path,
                image: Assets.images.icons8ShoppingBag502.path,
                isBold: ((widget.newestOrder.status == "Shipped") ||
                    (widget.newestOrder.status == "Received")),
              ),
              SizedBox(height: 10),
              statusOrderMethod(
                lines: true,
                firstText: "تم الشحن",
                secondText: "جاري شحن طلبك الأن الى العنوان المطلوب",
                checkImage: ((widget.newestOrder.status == "Shipped") ||
                        (widget.newestOrder.status == "Received"))
                    ? Assets.images.icons8CheckMark501.path
                    : Assets.images.icons8CheckMark50.path,
                image: Assets.images.icons8Shipping50.path,
                isBold: ((widget.newestOrder.status == "Shipped")),
              ),
              SizedBox(height: 10),
              statusOrderMethod(
                lines: false,
                firstText: "تم التوصيل",
                checkImage: ((widget.newestOrder.status == "Received"))
                    ? Assets.images.icons8CheckMark501.path
                    : Assets.images.icons8CheckMark50.path,
                secondText: "تم توصيل طلبك , تجربة ممتعة!",
                image: Assets.images.icons8Delivery64.path,
                isBold: ((widget.newestOrder.status == "Received")),
              ),
            ],
          )),
        ),
        Material(
          child: Padding(
            padding: const EdgeInsets.only(right: 25, left: 25, bottom: 40),
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.5),
                  spreadRadius: 7,
                  blurRadius: 5,
                ),
              ], borderRadius: BorderRadius.circular(20), color: mainColor),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 25, right: 25, left: 25),
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 231, 231, 231),
                          borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "متوقع الوصول",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromARGB(255, 90, 90, 90),
                                    fontSize: 11),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 50,
                            width: 1,
                            color: Color.fromARGB(255, 163, 163, 163),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "رقم تتبع الطلبية",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromARGB(255, 90, 90, 90),
                                    fontSize: 11),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                widget.newestOrder.orderId
                                    .toString()
                                    .toString(),
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: Center(
                                child: Image.asset(
                                  Assets.images.icons8Paid30.path,
                                  height: 35,
                                  width: 35,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "المبلغ المطلوب عند الاستلام",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white),
                                ),
                                Text(
                                  "شيقل",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          "${double.parse(widget.newestOrder.totalPrice.toString()).toStringAsFixed(1)} ₪",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget statusOrderMethod(
      {String image = "",
      String checkImage = "",
      String firstText = "",
      String secondText = "",
      bool isBold = false,
      bool lines = true}) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Image.asset(
                  checkImage,
                  height: 15.w,
                  width: 15.w,
                  fit: BoxFit.cover,
                ),
              ),
              Visibility(
                visible: lines,
                child: Column(
                  children: List<Widget>.generate(7, (int index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Container(
                        width: 2,
                        height: 4,
                        color: Color(0xff1B425E),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                image,
                height: 30,
                width: 30,
              ),
            ],
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    firstText,
                    style: TextStyle(
                        fontWeight:
                            isBold ? FontWeight.bold : FontWeight.normal,
                        color: const Color.fromARGB(255, 87, 86, 86),
                        fontSize: 18),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    secondText,
                    style: TextStyle(
                        color: const Color.fromARGB(255, 43, 43, 43),
                        fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
