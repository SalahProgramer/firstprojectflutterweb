import 'package:fawri_app_refactor/salah/controllers/page_main_screen_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../LocalDB/Database/local_storage.dart';
import '../../firebase/user/user_controller.dart';
import '../../firebase/user/user_model.dart';
import '../utilities/global/app_global.dart';
import 'custom_page_controller.dart';

class UserController extends ChangeNotifier {
  bool isLoading = false;
  final UserService userService = UserService();
  bool isSelectedSize = false;
  bool showCaseShown = false;
  String userId = "";

  UserItem? user;
  Map sizes = {};
  String sizesOutput = "";

  PageMainScreenController pageMainScreenController = NavigatorApp.context
      .read<PageMainScreenController>();
  CustomPageController customPageController = NavigatorApp.context
      .read<CustomPageController>();

  Future<void> setSizesArray({required String mainCategory}) async {
    if (mainCategory == "ملابس نسائيه") {
      sizes = LocalStorage().getSize("womenSizes");
    } else if (mainCategory == "ملابس رجاليه") {
      sizes = LocalStorage().getSize("menSizes");
    } else if (mainCategory == "ملابس نسائيه مقاس كبير") {
      sizes = LocalStorage().getSize("womenPlusSizes");
    } else if (mainCategory == "مستلزمات اعراس") {
      sizes = LocalStorage().getSize("Weddings & Events");
    } else if (mainCategory == "ملابس داخليه") {
      sizes = LocalStorage().getSize("Underwear_Sleepwear_sizes");
    }
    List trueSizes = (sizes).entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    sizesOutput = trueSizes.join(', ');
    notifyListeners();
  }

  Future<void> hasShowcaseBeenShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showCaseShown = prefs.getBool('showcaseShown') ?? false;
    notifyListeners();
  }

  // Function to mark the showcase as shown
  Future<void> markShowcaseAsShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showCaseShown = await prefs.setBool('showcaseShown', true);
    notifyListeners();
  }

  Future<void> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('user_id') ?? "";
    userId = userID;
    notifyListeners();
  }

  Future<void> getSelectedSizeAndUserIDAndShowCaseShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('user_id') ?? "";
    showCaseShown = prefs.getBool('showcaseShown') ?? false;
    bool isSelectedSizeShared = prefs.getBool('is_selected_size') ?? false;
    userId = userID;
    isSelectedSize = isSelectedSizeShared;
    notifyListeners();
  }

  void changeLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }
}
