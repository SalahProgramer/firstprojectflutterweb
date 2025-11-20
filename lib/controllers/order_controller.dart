import '../core/utilities/global/app_global.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/utilities/print_looger.dart';
import '../models/order/order_detail_model.dart';
import '../models/user/order_check_model.dart';
import 'APIS/api_order_controlller.dart';

class OrderControllerSalah extends ChangeNotifier {
  TextEditingController reason = TextEditingController();
  int pageOrder = 0;
  Map<String, int> totalDiscountAfterDelete = {};
  OrderCheckModel? checkPendingOrder;

  bool isLoading1 = false;
  bool doMergeOrder = false;
  bool isLoading2 = false;

  int pageOrderNew = 1;
  int numberOrderNewest = 0;
  int pageOrderOldest = 1;
  int numberOrderOldest = 0;

  bool isLoading3 = false;

  ApiOrderController apiOrderController =
      NavigatorApp.context.read<ApiOrderController>();

  // .substring(0, 10);

  //------------------------------------------------------------------------

  List<OrderDetailModel> newestOrder = [
    OrderDetailModel(
      orderId: 0,
    )
  ];
  List<OrderDetailModel> newestOrderData = [];

  List<OrderDetailModel> oldestOrder = [
    OrderDetailModel(
      orderId: 0,
    )
  ];

//-------------------------------------------------------------------------

  Future<void> initialsOrders({required String phone}) async {
    await clear();
    final f1 = getNewestOrders(phone, 1);
    final f2 = getOlderOrders(phone, 1);
    await Future.wait([f1, f2]);
    printLog("finish initial order");
    notifyListeners();
  }

  Future<void> clear() async {
    pageOrderNew = 1;
    pageOrderOldest = 1;

    numberOrderNewest = 0;
    numberOrderOldest = 0;
    newestOrder = [
      OrderDetailModel(
        orderId: 0,
      )
    ];
    newestOrderData = [];

    oldestOrder = [
      OrderDetailModel(
        orderId: 0,
      )
    ];
  }

  Future<void> empty() async {
    pageOrderNew = 1;
    pageOrderOldest = 1;
    numberOrderNewest = 0;
    numberOrderOldest = 0;
    newestOrder = [
      OrderDetailModel(
        orderId: -1,
      )
    ];
    newestOrderData = [];

    oldestOrder = [
      OrderDetailModel(
        orderId: -1,
      )
    ];
  }

  Future<void> changeLoading1(bool load) async {
    isLoading1 = load;
    notifyListeners();
  }

  Future<void> changeDoMergeOrder(bool load) async {
    doMergeOrder = load;
    notifyListeners();
  }

  Future<void> setDiscountAfterDelete(String order, int load) async {
    totalDiscountAfterDelete[order] = load;
    notifyListeners();
  }

  Future<void> changeLoading2(bool load) async {
    isLoading2 = load;
    notifyListeners();
  }

  Future<void> changeLoading3(bool load) async {
    isLoading3 = load;
    notifyListeners();
  }

  Future<void> changePageOrder(int page) async {
    pageOrder = page;
    notifyListeners();
  }

  //----------get newest orders details ----------------------------------------------------------------------------------------------

  Future<void> getNewestOrders(String phone, int page) async {
    if (page == 1) {
      await clear();
    }

    Map<List<OrderDetailModel>, int> short = await apiOrderController
        .apiGetAllOrderDetails(phone: phone, type: "1", page: pageOrderNew);

    if (short.isEmpty || short.keys.first.isEmpty || short.values.first == 0) {
      if (page == 1) {
        newestOrder = [
          OrderDetailModel(
            orderId: -1,
          )
        ];
        newestOrderData = [];
        numberOrderNewest = 0;
      }
      notifyListeners();

      return;
    } else if (short.values.first != 0) {
      if (page == 1) {
        newestOrder = [];
      }
      newestOrder.addAll(short.keys.first);
      newestOrder = newestOrder.toSet().toList();
      newestOrderData = newestOrder.toSet().toList();
      newestOrder.removeWhere((element) =>
          element.status.toString().trim().toLowerCase() ==
              "merged_order_complete" ||
          element.status.toString().trim().toLowerCase() == "completed");

      newestOrderData.removeWhere(
        (element) =>
            element.status.toString().trim().toLowerCase() == "cancelled" ||
            element.status.toString().trim().toLowerCase() ==
                "merged_order_complete" ||
            element.status.toString().trim().toLowerCase() == "completed" ||
            element.status.toString().trim().toLowerCase() == "to cancel",
      );

      newestOrder = newestOrder.toSet().toList();
      newestOrderData = newestOrderData.toSet().toList();
      pageOrderNew++;
      numberOrderNewest = short.values.first;
      notifyListeners();
    }
  }

  //----------get older orders details ----------------------------------------------------------------------------------------------

  Future<void> getOlderOrders(String phone, int page) async {
    Map<List<OrderDetailModel>, int> short = await apiOrderController
        .apiGetAllOrderDetails(phone: phone, type: "2", page: pageOrderOldest);
    if (short.isEmpty || short.keys.first.isEmpty || short.values.first == 0) {
      if (page == 1) {
        oldestOrder = [
          OrderDetailModel(
            orderId: -1,
          )
        ];
        numberOrderOldest = 0;
      }

      notifyListeners();
      return;
    } else if (short.values.first != 0) {
      if (page == 1) {
        oldestOrder = [];
      }
      oldestOrder.addAll(short.keys.first);
      oldestOrder = oldestOrder.toSet().toList();

      numberOrderOldest = short.values.first;

      pageOrderOldest++;
      notifyListeners();
    }
  }

  //get check pending order ------------------------------------------------------------------------

  Future<void> getCheckPendingOrder({required String phone}) async {
    checkPendingOrder =
        await apiOrderController.apiCheckPendingOrder(phone: phone);
    notifyListeners();
  }
}
