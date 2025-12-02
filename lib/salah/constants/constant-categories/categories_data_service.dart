import 'dart:convert';
import 'package:fawri_app_refactor/salah/constants/constant-categories/categories_data_model.dart';
import 'package:fawri_app_refactor/salah/constants/constant-categories/constant_data_json.dart'
    as constant_data_json;
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:http/http.dart' as http;

class CategoriesDataService {
  static CategoriesDataService? _instance;
  static CategoriesDataService get instance {
    _instance ??= CategoriesDataService._();
    return _instance!;
  }

  CategoriesDataService._();

  // Remote URL for category data (raw content from GitHub)
  static const String _remoteDataUrl =
      'https://raw.githubusercontent.com/Fawri-co/App-constant-data/main/constant_data.json';

  // App Constant Data
  AppConstantData? appConstantData;

  // Initialize the service
  Future<void> initialize() async {
    await loadAppConstantData();
  }

  // Load all data with URL fetch, caching, and fallback
  Future<void> loadAppConstantData() async {
    try {
      // Try to load from remote URL first
      final remoteData = await fetchFromRemote();
      
      if (remoteData != null) {
        // Successfully loaded from remote
        appConstantData = AppConstantData.fromJson(remoteData);
        // Cache the data
        return;
      }
      else{
        appConstantData = AppConstantData.fromJson(constant_data_json.appConstantDataJson);



      }
    } catch (e) {
      printLog('Error loading from remote: $e');
    }

    // Fallback to local JSON data as last resort
    try {
      appConstantData = AppConstantData.fromJson(constant_data_json.appConstantDataJson);
    } catch (e) {
      print('Error loading from local data: $e');
      rethrow;
    }
  }

  // Fetch data from remote URL
  Future<Map<String, dynamic>?> fetchFromRemote() async {
    try {
      final response = await http.get(
        Uri.parse(_remoteDataUrl),
      ).timeout(
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
      printLog('Error fetching from remote: $e');
      return null;
    }
  }
  

  // Categories Lists
  List<CategoryItem> get basicCategories =>
      appConstantData?.basicCategories ?? [];

  List<CategoryItem> get secondaryCategories =>
      appConstantData?.secondaryCategories ?? [];

  // Tags Lists
  List<Tag> get tags => appConstantData?.tags ?? [];

  List<Tag> get tagsMen => appConstantData?.tagsMen ?? [];

  List<Tag> get womenTags => appConstantData?.womenTags ?? [];

  // Detailed Categories Lists
  List<CategoryItem> get men => appConstantData?.men ?? [];
  List<CategoryItem> get women => appConstantData?.women ?? [];
  List<CategoryItem> get womenPlus => appConstantData?.womenPlus ?? [];
  List<CategoryItem> get allkids => appConstantData?.allkids ?? [];
  List<CategoryItem> get girls => appConstantData?.girls ?? [];
  List<CategoryItem> get boys => appConstantData?.boys ?? [];
  List<CategoryItem> get womenAndBaby => appConstantData?.womenAndBaby ?? [];
  List<CategoryItem> get allShoes => appConstantData?.allShoes ?? [];
  List<CategoryItem> get menShoes => appConstantData?.menShoes ?? [];
  List<CategoryItem> get womenShoes => appConstantData?.womenShoes ?? [];
  List<CategoryItem> get kidsShoes => appConstantData?.kidsShoes ?? [];
  List<CategoryItem> get underWare => appConstantData?.underWare ?? [];
  List<CategoryItem> get home => appConstantData?.home ?? [];
  List<CategoryItem> get apparel => appConstantData?.apparel ?? [];
  List<CategoryItem> get beauty => appConstantData?.beauty ?? [];
  List<CategoryItem> get electronics => appConstantData?.electronics ?? [];
  List<CategoryItem> get bags => appConstantData?.bags ?? [];
  List<CategoryItem> get sports => appConstantData?.sports ?? [];
  List<CategoryItem> get kids => appConstantData?.kids ?? [];
  List<CategoryItem> get perfume => appConstantData?.perfume ?? [];
}

