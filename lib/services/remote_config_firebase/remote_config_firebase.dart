import 'dart:convert';

import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:fawri_app_refactor/salah/utilities/sentry_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseRemoteConfigClass {
  final remoteConfig = FirebaseRemoteConfig.instance;
  final int cacheDuration = 3600;

  Future<String> initilizeConfig() async {
    final season = await _getCachedOrFetch('season', fetchSeason);

    return season;
  }

  Future<String> getDomain() async {
    return _getCachedOrFetch('domain', _fetchDomain);
  }

  Future<String> getCategoryIDKey1() async {
    return _getCachedOrFetch('FeaturesUrl_1', _fetchCategoryIDKey1);
  }

  Future<String> getCategoryIDKey2() async {
    return _getCachedOrFetch('FeaturesUrl_2', _fetchCategoryIDKey2);
  }

  Future<String> getCategoryIDKey3() async {
    return _getCachedOrFetch('FeaturesUrl_3', _fetchCategoryIDKey3);
  }

  Future<String> getMenPrice() async {
    return _getCachedOrFetch('MenPrice', fetchMenPrice);
  }

  Future<String> getOtherPrice() async {
    return _getCachedOrFetch('OtherPrice', fetchOtherPrice);
  }

  Future<String> getWomenPrice() async {
    return _getCachedOrFetch('WomenPrice', fetchWomenPrice);
  }

  Future<String> getBigPrice() async {
    return _getCachedOrFetch('BigPrice', fetchBigPrice);
  }

  Future<String> getKidsPrice() async {
    return _getCachedOrFetch('KidsPrice', fetchKidsPrice);
  }

  Future<String> _getCachedOrFetch(
      String key, Future<String> Function() fetchFunction) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Check if cache is valid
    final cachedTime = prefs.getInt('${key}_cache_time') ?? 0;
    if (currentTime - cachedTime < cacheDuration) {
      final cachedValue = prefs.getString(key) ?? '';

      return cachedValue;
    }

    final fetchedValue = await fetchFunction();

    // Save to cache
    prefs.setString(key, fetchedValue);
    prefs.setInt('${key}_cache_time', currentTime);

    return fetchedValue;
  }

  Future<String> fetchSeason() async {
    await _configureRemoteConfig();
    final value = remoteConfig.getString('season');

    return value;
  }

  Future<String> fetchFreeShip() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('FreeShip');
  }

  Future<String> fetchMarque() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('marque');
  }

  Future<bool> fetchShowRateApp() async {
    await _configureRemoteConfig();
    return remoteConfig.getBool('show_rate_App');
  }

  Future<String> fetchItemIdFreeGift() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('item_id_free_gift');
  }

  Future<String> fetchCategoryName() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('category_name');
  }

  Future<List<dynamic>> fetchDiscountCategories() async {
    String? categoriesString;

    await _configureRemoteConfig();
    categoriesString = remoteConfig.getString('DiscountCategories');

    final categories = jsonDecode(categoriesString) as List<dynamic>;

    return categories;
  }

  Future<String> fetchCategoryDesc() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('category_description');
  }

  Future<String> fetchCategoryImage() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('category_image_url');
  }

  Future<String> fetchCategoryPath() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('category_path');
  }

  Future<String> _fetchDomain() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('domain');
  }

  Future<String> _fetchCategoryIDKey1() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('FeaturesUrl_1');
  }

  Future<String> _fetchCategoryIDKey2() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('FeaturesUrl_2');
  }

  Future<String> _fetchCategoryIDKey3() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('FeaturesUrl_3');
  }

  Future<String> fetchKidsPrice() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('KidsPrice');
  }

  Future<String> fetchMenPrice() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('MenPrice');
  }

  Future<String> fetchOtherPrice() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('OtherPrice');
  }

  Future<String> fetchShow11() async {
    await _configureRemoteConfig();

    return remoteConfig.getString('show_11_11');
  }

  Future<String> fetchLastUpdate() async {
    await _configureRemoteConfig();

    return remoteConfig.getString('last_version');
  }

  Future<bool> fetchForceUpdate() async {
    await _configureRemoteConfig();
    final forceUpdate = remoteConfig.getBool('force_update');
    return forceUpdate;
  }

  Future<String> fetchOffer() async {
    await _configureRemoteConfig();

    return remoteConfig.getString('offer');
  }

  Future<int> fetchShowEven() async {
    await _configureRemoteConfig();
    return remoteConfig.getInt('show_even');
  }

  Future<bool> fetchShowFormFawri() async {
    await _configureRemoteConfig();
    return remoteConfig.getBool('show_form_fawri');
  }

  Future<String> fetchURL11() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('url_11_11');
  }

  Future<String> fetchWomenPrice() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('WomenPrice');
  }

  Future<String> fetchBigPrice() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('BigPrice');
  }

  Future<String> fetchtitleHomePage() async {
    await _configureRemoteConfig();
    return remoteConfig.getString('titleHomePage');
  }

  Future<void> _configureRemoteConfig() async {
    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 100),
        minimumFetchInterval: Duration(seconds: 100),
      ));

      await remoteConfig.fetchAndActivate();
    } catch (e, stackTrace) {
      await SentryService.captureError(
        exception: e,
        stackTrace: stackTrace,
        functionName: "_configureRemoteConfig",
        fileName: "remote_config_firebase.dart",
        lineNumber: 225,
        extraData: {
          "fetch_timeout": 100,
          "minimum_fetch_interval": 100,
        },
      );

      printLog('Remote Config error: $e');
      printLog('Stack trace: $stackTrace');
    }
  }
}
