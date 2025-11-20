
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../core/services/database/models_DB/favourite_model.dart';
import '../core/services/database/sql_database.dart';
import '../core/utilities/global/app_global.dart';
import '../models/items/item_model.dart';
import 'APIS/api_product_item.dart';
import 'cart_controller.dart';

class FavouriteController extends ChangeNotifier {
  List<FavouriteModel> favouriteItems = [];
  List<bool> checkInCart = [];
  Item? item;
  SqlDb sqlDb = SqlDb();

  ApiProductItemController api =
      NavigatorApp.context.read<ApiProductItemController>();

  // ---Get Item Data,Ids ,all items data and clear itemsData (get data,IDS,all items data and clear)
  Future<void> getItemData(Item item1) async {
    List<Item> data = await api.apiItemData(item1, sizes: "", page: 1);
    if (data != []) {
      item = data[0];
      notifyListeners();
    }
  }

  Future<void> insertData({
    required String? id,
    required String? image,
    required String? title,
    required String? newPrice,
    required String? oldPrice,
    required String? tags,
    required int? productId,
    required int? variantId,

  }) async {
    title = title!.replaceAll("'s", " ");

    int response = await sqlDb.insertData(
        sql:
            "INSERT INTO 'favourite' ('id','image','title','new_price','old_price','product_id','variantId','tags') VALUES ('$id','$image','$title','$newPrice','$oldPrice',$productId,$variantId,'$tags')");

    if (response > 0) {
      await getFavouriteItems();
    }
  }

  Future<void> deleteItem({required int? productId}) async {
    await sqlDb.insertData(
        sql: "DELETE FROM 'favourite' WHERE product_id=$productId");

    await getFavouriteItems();
  }

  bool checkFavouriteItemProductId({int? productId}) {
    return favouriteItems.any((item) {
      return item.productId == productId;
    });
  }

  Future<void> getFavouriteItems() async {
    CartController cartController = NavigatorApp.context.read<CartController>();
    List<Map> response = await sqlDb.readData(sql: "SELECT * FROM 'favourite'");
    favouriteItems = FavouriteModel.fromJsonList(response);
    checkInCart.clear();
    for (var i in favouriteItems) {
      checkInCart.add(
          await cartController.checkCartItemById(productId: i.productId ?? 0));
    }
    notifyListeners();
  }

  Future<bool> checkFavouriteItem({required int? productId}) async {
    List<Map> response = await sqlDb.readData(
        sql:
            "SELECT product_id FROM 'favourite'  WHERE product_id = $productId");

    if (response.toString() == "[]") {
      return false;
    } else {
      return true;
    }
  }
}
