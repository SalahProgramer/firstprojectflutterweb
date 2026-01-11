import 'package:fawri_app_refactor/salah/controllers/cart_controller.dart';
import 'package:fawri_app_refactor/salah/models/order/order.dart';
import 'package:fawri_app_refactor/salah/utilities/global/app_global.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../server/functions/functions.dart';
import '../models/items/item_model.dart';
import '../widgets/snackBarWidgets/snack_bar_style.dart';
import '../widgets/snackBarWidgets/snackbar_widget.dart';
import 'APIS/api_product_item.dart';

class ProductItemController extends ChangeNotifier {
  bool showTutorial = true;
  bool isFirstOpenItem = true;
  List<Item> allItemsData = [];
  Item? specificItemData;
  List<Item> allItems = [];
  bool isTrue = true;
  bool haveData = true;
  int numberPage = 1;
  Map<String, String> sizesItems = {};
  Map<String, int> indexItems = {};
  Map<String, String> basicQuantityItems = {};
  Map<String, int> valueQuantityItems = {};
  bool isLoadingButtonCart = false;
  bool noChoiceSize = false;
  Map<String, bool> inCart = {};
  CartController cartController = NavigatorApp.context.read<CartController>();

  // GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();

  bool update = false;
  FlareControls flareControls = FlareControls();
  ApiProductItemController api = NavigatorApp.context
      .read<ApiProductItemController>();

  Future<void> changeLoadingButtonCart(bool check) async {
    isLoadingButtonCart = check;
    notifyListeners();
  }

  Future<void> changeNoChoiceSize(bool check) async {
    noChoiceSize = check;
    notifyListeners();
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---check is First Open Item (is First Open Item)
  Future<void> checkFirstOpenItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstOpen = prefs.getBool('isFirstOpen') ?? true;
    isFirstOpenItem = isFirstOpen;
    if (isFirstOpenItem) {
      showTutorial = true;
      await prefs.setBool('isFirstOpen', false);
    }
    notifyListeners();
  }

  Future<void> stopTutorial() async {
    // tutorialActive = false;
    showTutorial = false;
    isFirstOpenItem = false;

    // });
    notifyListeners();
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---counter quantity (counter quantity)
  Future<void> doIncrement(String id, int index, Item item) async {
    if (valueQuantityItems[id]! >= int.parse(basicQuantityItems[id]!)) {
      showSnackBar(title: "لا يمكنك إضافة المزيد!", type: SnackBarType.warning);
    } else {
      valueQuantityItems[id] = (valueQuantityItems[id] ?? 0) + 1;
      inCart[id] = await cartController.checkCartItem(id: "${id}00$index");

      basicQuantityItems[id] = item.variants![index].quantity.toString();

      if (inCart[id] == true) {
        int quantity = await cartController.checkCartItemQuantity(
          id: "${id}00$index",
        );
        if (valueQuantityItems[id] != quantity) {
          inCart[id] = false;
          update = true;
        }
      }
      notifyListeners();
    }
  }

  Future<void> doDecrement(String id, int index, Item item) async {
    if (valueQuantityItems[id] == 1) {
      inCart[id] = await cartController.checkCartItem(id: "${id}00$index");

      if (inCart[id] == true) {
        valueQuantityItems[id] = 1;

        int quantity = await cartController.checkCartItemQuantity(
          id: "${id}00$index",
        );
        if (valueQuantityItems[id] != quantity) {
          inCart[id] = false;
          update = true;
        }
      } else {
        update = false;
      }
    } else {
      valueQuantityItems[id] = (valueQuantityItems[id] ?? 0) - 1;

      inCart[id] = await cartController.checkCartItem(id: "${id}00$index");

      basicQuantityItems[id] = item.variants?[index].quantity.toString() ?? "0";

      if (inCart[id] == true) {
        int quantity = await cartController.checkCartItemQuantity(
          id: "${id}00$index",
        );
        if (valueQuantityItems[id] != quantity) {
          inCart[id] = false;
          update = true;
        }
      } else {}
    }
    notifyListeners();
  }

  //--------------------------------------------------------------------------------------------------------------
  // ---Get Item Data,Ids ,all items data and clear itemsData (get data,IDS,all items data and clear)
  Future<void> getItemData(Item item, String sizes) async {
    List<Item> data = [];
    if (haveData == true) {
      data = await api.apiItemData(item, sizes: sizes, page: numberPage);
    }
    if (numberPage == 1) {
      allItems.clear();
    }
    if (data != []) {
      allItems.addAll(data);

      //first item-----------------------------------------------------
      for (var item in List.from(allItems)) {
        final id = item.id.toString();
        if ((item.variants?.length == 1) &&
            ((item.variants?[0].size ?? "") != "")) {
          inCart[id] = await cartController.checkCartItem(id: "${id}000");

          sizesItems[id] = item.variants?[0].size.toString() ?? "";
          indexItems[id] = 0;
          basicQuantityItems[id] = item.variants?[0].quantity.toString() ?? "0";
          if (inCart[id] == true) {
            valueQuantityItems[id] = await cartController.checkCartItemQuantity(
              id: "${id}000",
            );
          } else {
            valueQuantityItems[id] = 1;
          }

          update = false;
        } else if (((item.variants?.length ?? 0) > 1)) {
          int index = 0;
          bool flag = false;
          for (var i in (item.variants ?? [])) {
            printLog(i);
            inCart[id] = await cartController.checkCartItem(
              id: "${id}00$index",
            );
            if (inCart[id] == true) {
              flag = true;
              break;
            }
            index++;
          }
          if (flag == true) {
            sizesItems[id] = item.variants?[index].size.toString() ?? "0";
            indexItems[id] = index;
            basicQuantityItems[id] =
                item.variants?[0].quantity.toString() ?? "0";

            valueQuantityItems[id] = await cartController.checkCartItemQuantity(
              id: "${id}00$index",
            );
            update = false;
          } else {
            sizesItems[id] = ((item.variants?.length ?? 0) > 1)
                ? ""
                : (item.variants?.isEmpty ?? false)
                ? ""
                : item.variants?[0].size.toString() ?? "";
            indexItems[id] = 0;
            basicQuantityItems[id] = (item.variants?.isEmpty ?? false)
                ? "0"
                : item.variants?[0].quantity.toString() ?? "0";

            valueQuantityItems[id] = 1;
            update = false;
          }
        } else {
          sizesItems[id] = "";
          indexItems[id] = 0;
          basicQuantityItems[id] = "0";

          valueQuantityItems[id] = 0;
        }
      }
      numberPage++;
      notifyListeners();
    } else {
      haveData = false;

      notifyListeners();
    }
  }

  Future<void> getItemDataBestOrFlash(Item item, String sizes) async {
    List<Item> data = [];
    if (haveData == true) {
      data = await api.apiItemDataBestOrFlash(
        item,
        sizes: sizes,
        page: numberPage,
      );
    }
    if (numberPage == 1) {
      allItems.clear();
    }
    if (data != []) {
      allItems.addAll(data);

      //first item-----------------------------------------------------
      for (var item in List.from(allItems)) {
        final id = item.id.toString();
        if ((item.variants?.length == 1) &&
            ((item.variants?[0].size ?? "") != "")) {
          inCart[id] = await cartController.checkCartItem(id: "${id}000");

          sizesItems[id] = item.variants?[0].size.toString() ?? "";
          indexItems[id] = 0;
          basicQuantityItems[id] = item.variants?[0].quantity.toString() ?? "0";
          if (inCart[id] == true) {
            valueQuantityItems[id] = await cartController.checkCartItemQuantity(
              id: "${id}000",
            );
          } else {
            valueQuantityItems[id] = 1;
          }

          update = false;
        } else if (((item.variants?.length ?? 0) > 1)) {
          int index = 0;
          bool flag = false;
          for (var i in (item.variants ?? [])) {
            printLog(i);
            inCart[id] = await cartController.checkCartItem(
              id: "${id}00$index",
            );
            if (inCart[id] == true) {
              flag = true;
              break;
            }
            index++;
          }

          if (flag == true) {
            sizesItems[id] = item.variants?[index].size.toString() ?? "0";
            indexItems[id] = index;
            basicQuantityItems[id] =
                item.variants?[0].quantity.toString() ?? "0";

            valueQuantityItems[id] = await cartController.checkCartItemQuantity(
              id: "${id}00$index",
            );
            update = false;
          } else {
            sizesItems[id] = ((item.variants?.length ?? 0) > 1)
                ? ""
                : (item.variants?.isEmpty ?? false)
                ? ""
                : item.variants?[0].size.toString() ?? "";
            indexItems[id] = 0;
            basicQuantityItems[id] = (item.variants?.isEmpty ?? false)
                ? "0"
                : item.variants?[0].quantity.toString() ?? "0";

            valueQuantityItems[id] = 1;
            update = false;
          }
        } else {
          sizesItems[id] = "";
          indexItems[id] = 0;
          basicQuantityItems[id] = "0";

          valueQuantityItems[id] = 0;
        }
      }
      notifyListeners();
      //ids items-----------------------------------------------------
    } else {
      haveData = false;

      notifyListeners();
    }
  }

  Future<void> getItemDataSpecificInOrder(
    Item item,
    String sizes,
    SpecificOrder specificOrder,
  ) async {
    allItems = [];
    List<Item>? data = await api.apiItemData(
      item,
      sizes: sizes,
      haveSimilar: false,
      page: 1,
    );

    if (data != []) {
      allItems.add(data[0]);
      update = false;
      notifyListeners();
    }
  }

  Future<void> changeSizesItem(
    String id,
    String size,
    Item item,
    int index,
  ) async {
    inCart[id] = await cartController.checkCartItem(id: "${id}00$index");
    sizesItems[id] = size;
    indexItems[id] = index;

    basicQuantityItems[id] = item.variants?[index].quantity.toString() ?? "0";

    if (inCart[id] == true) {
      int quantity = await cartController.checkCartItemQuantity(
        id: "${id}00$index",
      );
      valueQuantityItems[id] = quantity;
    } else {
      valueQuantityItems[id] = 1;
      update = false;
    }

    // printLog(inCart[id]);
    notifyListeners();
  }

  Future<void> clearItemsData() async {
    allItems.clear();
    numberPage = 1;
    haveData = true;
    notifyListeners();
  }

  //---------------------------------------------------------------------------------------
  // get Specific Id from share Url

  Future<void> getSpecificProduct(id) async {
    var response = await api.apiGetSpecificProduct(id);
    if (response == null) {
      showSnackBar(title: " لا يوجد نتيجة !!", type: SnackBarType.error);
      isTrue = false;

      notifyListeners();
    } else {
      specificItemData = response;
      isTrue = true;

      if ((specificItemData?.variants?.length == 1) &&
          (specificItemData?.variants?[0].size != "")) {
        inCart[id] = await cartController.checkCartItem(id: "${id}000");

        sizesItems[id] = specificItemData?.variants?[0].size.toString() ?? "";
        indexItems[id] = 0;
        basicQuantityItems[id] =
            specificItemData?.variants?[0].quantity.toString() ?? "0";
        if (inCart[id] == true) {
          valueQuantityItems[id] = await cartController.checkCartItemQuantity(
            id: "${id}000",
          );
        } else {
          valueQuantityItems[id] = 1;
        }

        update = false;
      } else if (((specificItemData?.variants?.length ?? 0) > 1)) {
        int index = 0;
        bool flag = false;
        for (var i in specificItemData?.variants ?? []) {
          printLog(i);
          inCart[id] = await cartController.checkCartItem(id: "${id}00$index");
          if (inCart[id] == true) {
            flag = true;
            break;
          }
          index++;
        }
        if (flag == true) {
          sizesItems[id] =
              specificItemData?.variants?[index].size.toString() ?? "0";
          indexItems[id] = index;
          basicQuantityItems[id] =
              specificItemData?.variants?[0].quantity.toString() ?? "0";

          valueQuantityItems[id] = await cartController.checkCartItemQuantity(
            id: "${id}00$index",
          );
          update = false;
        } else {
          sizesItems[id] = ((specificItemData?.variants?.length ?? 0) > 1)
              ? ""
              : (specificItemData?.variants?.isEmpty ?? false)
              ? ""
              : specificItemData?.variants?[0].size.toString() ?? "";
          indexItems[id] = 0;
          basicQuantityItems[id] =
              (specificItemData?.variants?.isEmpty ?? false)
              ? ""
              : specificItemData?.variants?[0].quantity.toString() ?? "0";

          valueQuantityItems[id] = 1;
          update = false;
        }
      } else {
        sizesItems[id] = "";
        indexItems[id] = 0;
        basicQuantityItems[id] = "0";

        valueQuantityItems[id] = 0;
      }
      notifyListeners();
    }
  }
}
