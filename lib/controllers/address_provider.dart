import 'package:flutter/material.dart';
import '../core/services/database/address/data_base.dart';
import '../core/services/database/models_DB/address_item_model.dart';

class AddressProvider extends ChangeNotifier {
  List<AddressItem> _addressItems = [];
  CartDatabaseHelper dbHelper = CartDatabaseHelper();

  List<AddressItem> get addressItems => _addressItems;
  int get addressItemsCount => _addressItems.length;

  AddressProvider() {
    _init();
  }

  Future<void> _init() async {
    _addressItems = await dbHelper.getAddresses();
    notifyListeners();
  }

  Future<void> addToAddress(AddressItem item) async {
    // Insert the item into the database
    await dbHelper.insertAddressItem(item);

    // Refresh _addressItems with the latest data from the database
    _addressItems = await dbHelper.getUserAddresses();

    // Notify listeners after updating the list
    notifyListeners();
  }

  Future<void> removeFromAddress(int addressId) async {
    await dbHelper.deleteAddressItem(addressId);
    _addressItems.removeWhere((item) => item.id == addressId);
    notifyListeners();
  }

  Future<void> clearAddress() async {
    _addressItems.clear();
    notifyListeners();
  }

  void updateCartItem(AddressItem item) async {
    await dbHelper.updateAddressItem(item);
    _addressItems = await dbHelper.getUserAddresses();
    notifyListeners();
  }

  List<Map<String, dynamic>> getProductsArray() {
    List<Map<String, dynamic>> productsArray = [];

    for (AddressItem item in _addressItems) {
      Map<String, dynamic> productData = {
        'id': item.id,
        'user_id': item.userId,
        'name': item.name,
      };
      productsArray.add(productData);
    }

    return productsArray;
  }
}
