import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/firebase/remote_config_firebase/remote_config_firebase.dart';

class FetchController extends ChangeNotifier {
  String categoryName = "";
  String categoryDesc = "";
  String categoryImage = "";
  String categoryPath = "";
  String featuresUrl3 = "";
  String marque = "";
  String offer = "";
  String url_11 = "";
  bool setBigCategories = false;
  String setShow11 = "false";
  bool wheelCoupon = false;
  bool showRateApp = false;
  bool showFormFawri = true;
  int showEven = 0;

  String season = "";
  List<int> discountCategories = [];

  Future<String> getVersion() async {
    String lastVersion = await FirebaseRemoteConfigClass().fetchLastUpdate();

    return lastVersion;
  }

  Future<bool> getUpdate() async {
    bool forceUpdate = await FirebaseRemoteConfigClass().fetchForceUpdate();

    return forceUpdate;
  }

  Future<String> getOffer() async {
    String offer = await FirebaseRemoteConfigClass().fetchOffer();

    return offer;
  }

  Future<void> getWheelCoupon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.getBool("wheel_coupon") ?? false;
    notifyListeners();
  }

  Future<void> showFawrForm() async {
    final remoteConfig = FirebaseRemoteConfigClass();

    var showForm = await remoteConfig.fetchShowFormFawri();
    showFormFawri=showForm;
    notifyListeners();
  }
  Future<void> setControllers() async {
    final remoteConfig = FirebaseRemoteConfigClass();

    var showE = await remoteConfig.fetchShowEven();
    var discountCategories0 = await remoteConfig.fetchDiscountCategories();
    var show111 = await remoteConfig.fetchShow11();
    url_11 = (await remoteConfig.fetchURL11()).toString();
    featuresUrl3 = (await remoteConfig.getCategoryIDKey3()).toString();
    categoryName = (await remoteConfig.fetchCategoryName()).toString();
    marque = (await remoteConfig.fetchMarque()).toString();
    categoryDesc = (await remoteConfig.fetchCategoryDesc()).toString();
    categoryImage = (await remoteConfig.fetchCategoryImage()).toString();
    categoryPath = (await remoteConfig.fetchCategoryPath()).toString();
    offer = (await remoteConfig.fetchOffer()).toString();
    season = await remoteConfig.initilizeConfig();
    showRateApp = await remoteConfig.fetchShowRateApp();

    setShow11 = show111.toString();
    showEven = showE;

    discountCategories = discountCategories0
        .map((category) => int.tryParse(category.toString()) ?? 0)
        .toList();

    notifyListeners();
  }
}
