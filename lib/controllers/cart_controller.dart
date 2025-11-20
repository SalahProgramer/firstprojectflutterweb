import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/database/models_DB/cart_model.dart';
import '../core/services/database/sql_database.dart';
import '../core/utilities/global/app_global.dart';
import '../core/utilities/print_looger.dart';
import '../core/widgets/snackBarWidgets/snack_bar_style.dart';
import '../core/widgets/snackBarWidgets/snackbar_widget.dart';
import '../models/available_model.dart';
import 'APIS/api_cart_controller.dart';
import 'favourite_controller.dart';

class CartController extends ChangeNotifier {
  bool firstShowDelete = true;
  bool isLoading = false;
  bool haveButton = true;

  // ItemScrollController scrollController = ItemScrollController();
  List<CartModel> cartItems = [];
  List<CartModel> inFavouriteCartItems = [];

  double totalItemsPrice = 0;
  int totalItemsPriceOfferTawseel = 0;
  List<bool> checkFavouriteInCart = [];
  List<String> itemsWillAddToCart = [];
  List<String> itemsOffers = [];
  List<CartModel> cartItemsOffers = [];

  SqlDb sqlDb = SqlDb();
  List<CartModel> availabilityItems = [];
  List<CartModel> notAvailabilityItems = [];
  List<CartModel> availabilityWithFalseItems = [];
  List<AvailableModel> availability = [];
  FavouriteController favouriteController =
      NavigatorApp.context.read<FavouriteController>();

  ApiCartController apiCartController =
      NavigatorApp.context.read<ApiCartController>();

//---------------------------------------------------------------------
// first show dialog learn how to delete

  Future<void> checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstOpen = prefs.getBool('first_Show_Delete_cart') ?? true;
    firstShowDelete = isFirstOpen;
    if (firstShowDelete) {
      await prefs.setBool('first_Show_Delete_cart', true);
    }
    notifyListeners();
  }

  //---------------------------------------------------------------------
// stop show

  Future<void> stopShowLearnDelete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_Show_Delete_cart', false);
    firstShowDelete = false;

    notifyListeners();
  }

  //---------------------------------------------------------------------
// ChangeLLoading

  Future<void> changeLoading(bool loading) async {
    if (isLoading != loading) {
      isLoading = loading;
      notifyListeners();
    }
  }

  Future<void> changeButton(bool loading) async {
    if (haveButton != loading) {
      haveButton = loading;
      notifyListeners();
    }
  }

  //------------------------------------------------------------------------------------------
  //check items availability
  Future<void> checkProductAvailability(
      List<Map<String, dynamic>> items) async {
    try {
      if (items.isEmpty) {
        printLog("No items to check availability");
        return;
      }

      var response = await apiCartController.apiCheckProductAvailability(items);
      
      if (response.isEmpty) {
        printLog("Empty response from availability check");
        return;
      }

      // Clear previous data
      availabilityItems.clear();
      availabilityWithFalseItems.clear();
      notAvailabilityItems.clear();
      availability = response;
      
      int index = 0;
      bool pricesUpdated = false;

      printLog("Checking availability for ${response.length} items");
      
      for (var item in response) {
        if (index >= cartItems.length) {
          printLog("Index out of bounds: $index >= ${cartItems.length}");
          break;
        }

        String availabilityStatus = item.availability.toString().trim().toLowerCase();
        printLog("Item ${item.id}: $availabilityStatus, message: ${item.message}, price: ${item.price}");
        
        // Handle price updates if availability is true and there's a message and price
        if (availabilityStatus == "true" && 
            item.message != null && 
            item.message!.isNotEmpty && 
            item.price != null) {
          
          CartModel currentCartItem = cartItems[index];
          String newPriceString = "${item.price!.toStringAsFixed(2)} ₪";
          String newTotalPrice = totalPrice1(item.price!.toStringAsFixed(2), currentCartItem.quantity!);
          
          // Update the cart item price in database
          await updateDataWithPrice(
            id: currentCartItem.id,
            quantity: currentCartItem.quantity,
            newPrice: newPriceString,
            totalPrice: newTotalPrice,
          );
          
          // Update the cart item object
          currentCartItem.newPrice = newPriceString;
          currentCartItem.totalPrice = newTotalPrice;
          
          pricesUpdated = true;
          printLog("Updated price for item ${item.id}: ${item.price} -> $newPriceString");
        }
        
        if (availabilityStatus == "true") {
          availabilityItems.add(cartItems[index]);
        } else if (availabilityStatus == "false") {
          notAvailabilityItems.add(cartItems[index]);
        } else {
          availabilityWithFalseItems.add(cartItems[index]);
        }

        index++;
      }

      // Recalculate total if prices were updated
      if (pricesUpdated) {
        await _recalculateTotal();
      }

      printLog("Availability check completed: ${availabilityItems.length} available, ${notAvailabilityItems.length} not available, ${availabilityWithFalseItems.length} with false status");
      notifyListeners();
    } catch (e) {
      printLog("Error checking product availability: $e");
      // Reset availability data on error
      availabilityItems.clear();
      availabilityWithFalseItems.clear();
      notAvailabilityItems.clear();
      notifyListeners();
    }
  }

  // Helper method to recalculate total price
  Future<void> _recalculateTotal() async {
    double newTotalPrice = 0;
    
    for (var item in cartItems) {
      if (item.totalPrice != null) {
        String cleanPrice = item.totalPrice!.replaceAll("₪", "").trim();
        double price = double.tryParse(cleanPrice) ?? 0.0;
        newTotalPrice += price;
      }
    }
    
    totalItemsPrice = double.parse(newTotalPrice.toStringAsFixed(2));
    printLog("Recalculated total price: $totalItemsPrice");
  }

  // Clear all availability data
  Future<void> clearAvailabilities() async {
    try {
      // Clear all availability data
      availability.clear();
      availabilityItems.clear();
      notAvailabilityItems.clear();
      availabilityWithFalseItems.clear();
      
      printLog("Cleared all availability data");
      notifyListeners();
    } catch (e) {
      printLog("Error clearing availability data: $e");
    }
  }

  // Initialize default availability data for cart items
  Future<void> initializeDefaultAvailability() async {
    try {
      // Clear existing availability data first
      await clearAvailabilities();
      
      // Set default availability for all cart items
      for (var cartItem in cartItems) {
        availability.add(
          AvailableModel(
            id: cartItem.productId,
            availability: "true",
            message: null,
            price: null,
            availableQuantity: null,
          )
        );
      }
      
      printLog("Initialized default availability for ${availability.length} cart items");
      notifyListeners();
    } catch (e) {
      printLog("Error initializing default availability: $e");
    }
  }

  //-----------------------------------------------------------------------------------------
  //check have offer - REMOVED (no longer needed)

  // Offer-related methods removed - no longer needed
  
  // Method needed for no tawseel functionality
  Future<void> initCalculateItemOfferTawseel(int remainder) async {
    itemsWillAddToCart.clear();
    totalItemsPriceOfferTawseel = remainder;
    if (totalItemsPriceOfferTawseel < 0) {
      totalItemsPriceOfferTawseel = 0;
    }
    notifyListeners();
  }

  Future<void> calculateItemOfferTawseel(int remainder, int itemPrice) async {
    totalItemsPriceOfferTawseel = totalItemsPriceOfferTawseel - itemPrice.toInt();
    if (totalItemsPriceOfferTawseel < 0) {
      totalItemsPriceOfferTawseel = 0;
    }
    notifyListeners();
  }

//----------------------------------------------------------------------
// Database--------------------------------------------------------

  Future<int> insertData(
      {required String? id,
      required String? image,
      required String? title,
      required String? newPrice,
      required String? oldPrice,
      required int? productId,
      required String? favourite,
      required String? shopId,
      required String? size,
      required int? basicQuantity,
      required String? hasOffer,
      required int? quantity,
      required String? employee,
      required String? sku,
      required String? vendorSku,
      required String? placeInHouse,
      required String? nickname,
      required int? indexVariants,
      required int? variantId,

      required String tags,
      required String? totalPrice}) async {
    title = title!.replaceAll("'s", " ");
    int response = await sqlDb.insertData(
        sql:
            "INSERT INTO 'cart' ('id','image','title','new_price','old_price','product_id','favourite','shopId','size','basic_quantity','quantity','employee','sku','vendor_sku','place_in_warehouse','nickname','indexVariants','variantId','total_price','has_offer','tags') VALUES ('$id','$image','$title','$newPrice','$oldPrice',$productId,'$favourite','$shopId','$size',$basicQuantity,$quantity,'$employee','$sku','$vendorSku','$placeInHouse','$nickname',$indexVariants,$variantId,'$totalPrice','$hasOffer','$tags')");

    if (response > 0) {
      await getCartItems();
    }
    return response;
  }

  Future<int> insertDataToAddCartAfter(
      {required String? id,
      required String? image,
      required String? title,
      required String? newPrice,
      required String? oldPrice,
      required int? productId,
      required String? favourite,
      required String? shopId,
      required String? size,
      required int? basicQuantity,
      required String? hasOffer,
      required int? quantity,
      required String? employee,
      required String? sku,
      required String? vendorSku,
      required String? placeInHouse,
      required String? nickname,
      required int? indexVariants,
      required int? variantId,
      required String? totalPrice}) async {
    title = title!.replaceAll("'s", " ");
    int response = await sqlDb.insertData(
        sql:
            "INSERT INTO 'cart' ('id','image','title','new_price','old_price','product_id','favourite','shopId','size','basic_quantity','quantity','employee','sku','vendor_sku','place_in_warehouse','nickname','indexVariants','variantId','total_price','has_offer') VALUES ('$id','$image','$title','$newPrice','$oldPrice',$productId,'$favourite','$shopId','$size',$basicQuantity,$quantity,'$employee','$sku','$vendorSku','$placeInHouse','$nickname',$indexVariants,$variantId,'$totalPrice','$hasOffer')");

    if (response > 0) {
      // await getCartItems();
    }
    notifyListeners();
    return response;
  }

  Future<void> deleteItem({required String? id}) async {
    await sqlDb.insertData(sql: "DELETE FROM 'cart' WHERE id='$id'");
    await getCartItems();
  }

  Future<void> deleteItemAddedToCart() async {
    printLog("${itemsWillAddToCart.length}ffffffffffffffffffffffffffffff");

    for (int i = 0; i < itemsWillAddToCart.length; i++) {
      await sqlDb.insertData(
          sql: "DELETE FROM 'cart' WHERE id='${itemsWillAddToCart[i]}'");
    }
    itemsWillAddToCart.clear();
    totalItemsPriceOfferTawseel = 0;
    notifyListeners();
  }

  Future<void> deleteAllItem({required String? idList}) async {
    await sqlDb.insertData(sql: "DELETE FROM 'cart' WHERE id IN ($idList)");
    await getCartItems();
  }

  Future<void> deleteAllItemFromCart() async {
    await sqlDb.deleteData(sql: "DELETE FROM 'cart'");
    await getCartItems();
    notifyListeners();
  }

  Future<void> getCartItems() async {
    try {
      List<Map> response = await sqlDb.readData(sql: "SELECT * FROM 'cart'");
      List<CartModel> newCartItems = CartModel.fromJsonList(response);
      
      // Only update if cart items have changed
      if (cartItems.length != newCartItems.length || 
          !_areCartItemsEqual(cartItems, newCartItems)) {
        cartItems = newCartItems;
        
        // Calculate total price and initialize default availability
        double newTotalPrice = 0;
        availability.clear();
        
        for (var item in cartItems) {
          if (item.totalPrice != null) {
            String cleanPrice = item.totalPrice!.replaceAll("₪", "").trim();
            double price = double.tryParse(cleanPrice) ?? 0.0;
            newTotalPrice += price;
          }
          // Initialize with default availability
          availability.add(AvailableModel(
            id: item.productId, 
            availability: "true",
            message: null,
            price: null,
            availableQuantity: null,
          ));
        }
        
        totalItemsPrice = double.parse(newTotalPrice.toStringAsFixed(2));

        // Clear availability lists
        availabilityItems.clear();
        notAvailabilityItems.clear();
        availabilityWithFalseItems.clear();
        
        // Update favourite items
        favouriteController.getFavouriteItems();
        
        notifyListeners();
      }
    } catch (e) {
      printLog("Error getting cart items: $e");
      // Reset cart items on error
      cartItems.clear();
      totalItemsPrice = 0;
      availability.clear();
      notifyListeners();
    }
  }

  // Helper method to compare cart items
  bool _areCartItemsEqual(List<CartModel> list1, List<CartModel> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id || 
          list1[i].quantity != list2[i].quantity ||
          list1[i].totalPrice != list2[i].totalPrice) {
        return false;
      }
    }
    return true;
  }

  Future<void> getCartItemsAfterOffer() async {
    totalItemsPrice = 0;
    for (var i in cartItems) {
      totalItemsPrice = totalItemsPrice +
          double.parse(i.totalPrice!.replaceAll("₪", "").trim().toString());
      availability.add(AvailableModel(id: i.productId, availability: "true"));
    }
    String f = totalItemsPrice.toStringAsFixed(2);
    totalItemsPrice = double.parse(f);

    favouriteController.getFavouriteItems();
    availabilityItems.clear();
    notAvailabilityItems.clear();

    availabilityWithFalseItems.clear();
    notifyListeners();
  }

  Future<bool> checkCartItem({required String id}) async {
    List<Map> response =
        await sqlDb.readData(sql: "SELECT id FROM 'cart'  WHERE id ='$id'");

    if (response.toString() == "[]") {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> checkCartItemById({required int productId}) async {
    List<Map> response = await sqlDb.readData(
        sql: "SELECT quantity FROM 'cart'  WHERE product_id =$productId");

    if (response.toString() == "[]") {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> checkCartItemByIdToViewed({required int productId}) async {
    List<Map> response = await sqlDb.readData(
        sql: "SELECT * FROM 'cart'  WHERE product_id =$productId");

    if (response.toString() == "[]") {
      return false;
    } else {
      return true;
    }
  }

  Future<int> checkCartItemQuantity({required String id}) async {
    List<Map> response = await sqlDb.readData(
        sql: "SELECT quantity FROM 'cart'  WHERE id ='$id'");

    return response.first['quantity'];
  }

  bool checkCartItemProductId({int? productId, String? selectedSize}) {
    return cartItems.any((item) {
      if (selectedSize != "") {
        return item.productId == productId && item.size == selectedSize;
      } else {
        return item.productId == productId;
      }
    });
  }

  Future<int> updateData(
      {required String? id,
      required int? quantity,
      required String? totalPrice}) async {
    int response = await sqlDb.updateData(
        sql:
            "UPDATE `cart` SET  `quantity` = $quantity,`total_price` = '$totalPrice' WHERE `id` = '$id';"); //return the integer the raw   (if 0 mean failed the mission  else 1 is success)
    if (response == 0) {
      return 0;
    } else {
      return 1;
    }
  }

  Future<int> updateDataWithPrice(
      {required String? id,
      required int? quantity,
      required String? newPrice,
      required String? totalPrice}) async {
    int response = await sqlDb.updateData(
        sql:
            "UPDATE `cart` SET  `quantity` = $quantity, `new_price` = '$newPrice', `total_price` = '$totalPrice' WHERE `id` = '$id';");
    if (response == 0) {
      return 0;
    } else {
      return 1;
    }
  }

  Future<void> doOperation(
      {required String? id,
      required int? quantity,
      required String? operation,
      required int? basicQuantity,
      required String? price}) async {
    if ((quantity! >= basicQuantity!) && operation == "+") {
      showSnackBar(title: "لا يمكنك إضافة المزيد!", type: SnackBarType.warning);
    } else {
      switch (operation) {
        case "+":
          quantity = (quantity) + 1;

          break;
        default:
          if (quantity == 1) {
            quantity = 1;
          } else {
            quantity = (quantity) - 1;
          }
      }

      await updateData(
          id: id,
          quantity: quantity,
          totalPrice: totalPrice1(price.toString(), quantity));
      await getCartItems();
    }
  }

  String totalPrice1(String price, int quantity) {
    double total;

    String cleaned = price.replaceAll('₪', '');
    double value = double.parse(cleaned);
    total = value * quantity;
    String f = total.toStringAsFixed(2);
    total = double.parse(f);
    return "$total ₪";
  }

  // discountPrice1 method removed - no longer needed for offers
}
