import 'dart:convert';
import 'package:fawri_app_refactor/salah/constants/constant-sizes/sizes_data_model.dart';
import 'package:fawri_app_refactor/salah/constants/constant-sizes/constant_sizes_json.dart'
    as constant_sizes_json;
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:http/http.dart' as http;

class SizesDataService {
  static SizesDataService? _instance;
  static SizesDataService get instance {
    _instance ??= SizesDataService._();
    return _instance!;
  }

  SizesDataService._();

  // Remote URL for sizes data (raw content from GitHub)
  static const String _remoteDataUrl =
      'https://raw.githubusercontent.com/Fawri-co/App-constant-data/main/constant_data_sizes.json';

  // App Sizes Data
  AppSizesData? appSizesData;

  // Initialize the service
  Future<void> initialize() async {
    await loadAppSizesData();
  }

  // Load all data with URL fetch, caching, and fallback
  Future<void> loadAppSizesData() async {
    try {
      // Try to load from remote URL first
      final remoteData = await fetchFromRemote();

      if (remoteData != null) {
        // Successfully loaded from remote
        appSizesData = AppSizesData.fromJson(remoteData);
        // Cache the data
        return;
      } else {
        appSizesData = AppSizesData.fromJson(
          constant_sizes_json.appSizesDataJson,
        );
      }
    } catch (e) {
      printLog('Error loading sizes from remote: $e');
    }

    // Fallback to local JSON data as last resort
    try {
      appSizesData = AppSizesData.fromJson(
        constant_sizes_json.appSizesDataJson,
      );
    } catch (e) {
      printLog('Error loading sizes from local data: $e');
      rethrow;
    }
  }

  // Fetch data from remote URL
  Future<Map<String, dynamic>?> fetchFromRemote() async {
    try {
      final response = await http
          .get(Uri.parse(_remoteDataUrl))
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );
      if (response.statusCode == 200) {
        printLog(_remoteDataUrl);
        final jsonData = json.decode(response.body);
        return jsonData as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      printLog('Error fetching sizes from remote: $e');
      return null;
    }
  }

  // Men Sizes
  Map<String, String> get menSizesList => appSizesData?.men.sizesList ?? {};

  Map<String, bool> get menSizesMap => appSizesData?.men.sizesMap ?? {};

  // Women Sizes
  Map<String, String> get womenSizesList => appSizesData?.women.sizesList ?? {};

  Map<String, bool> get womenSizesMap => appSizesData?.women.sizesMap ?? {};

  // Women Plus Sizes
  Map<String, String> get womenPlusSizesList =>
      appSizesData?.womenPlus.sizesList ?? {};

  // Kids Boys Sizes
  List<String> get kidsBoysSizesList =>
      appSizesData?.kidsBoys.sizesListSimple ?? [];

  Map<String, bool> get kidsBoysSizesData =>
      appSizesData?.kidsBoys.sizesMap ?? {};

  // Kids Girls Sizes
  List<String> get girlsKidsSizesList =>
      appSizesData?.kidsGirls.sizesListSimple ?? [];

  Map<String, bool> get girlsKidsSizesData =>
      appSizesData?.kidsGirls.sizesMap ?? {};

  // Women Shoes Sizes
  List<String> get womenShoesSizesList =>
      appSizesData?.womenShoes.sizesListSimple ?? [];

  Map<String, bool> get womenShoesSizesData =>
      appSizesData?.womenShoes.sizesMap ?? {};

  // Men Shoes Sizes
  List<String> get menShoesSizesList =>
      appSizesData?.menShoes.sizesListSimple ?? [];

  Map<String, bool> get menShoesSizesData =>
      appSizesData?.menShoes.sizesMap ?? {};

  // Kids Shoes Sizes
  List<String> get kidsShoesSizesList =>
      appSizesData?.kidsShoes.sizesListSimple ?? [];

  Map<String, bool> get kidsShoesSizesData =>
      appSizesData?.kidsShoes.sizesMap ?? {};

  // Underwear Sizes
  List<String> get underwearSizes =>
      appSizesData?.underwear.sizesListSimple ?? [];

  Map<String, bool> get underwearSleepwearSizesData =>
      appSizesData?.underwear.sizesMap ?? {};

  // Wedding and Events Sizes
  Map<String, bool> get weddingAndEventsData =>
      appSizesData?.weddingAndEvents.sizesMap ?? {};

  // Women and Baby (Infant) Sizes
  List<String> get womenAndBabySizesList =>
      appSizesData?.womenAndBaby.sizesListSimple ?? [];

  Map<String, bool> get womenAndBabySizesData =>
      appSizesData?.womenAndBaby.sizesMap ?? {};
}
