import '../models/constants/constant_model.dart';
import '../models/items/item_model.dart';
import '../models/departments/department_model.dart';
import '../controllers/APIS/api_departments_controller.dart';

/// Service class for department-related operations
/// Acts as a repository layer between controller and API
class DepartmentService {
  final ApiDepartmentsController _apiController;

  DepartmentService(this._apiController);

  /// Fetch department items based on filter criteria
  Future<List<Item>> fetchDepartmentItems({
    required DepartmentFilterModel filter,
    required int page,
    int? requestVersion,
  }) async {
    final category = filter.category ?? CategoryModel(
      name: '',
      subCategory: '',
      image: '',
      mainCategory: '',
      icon: '',
    );

    final sub = filter.subCategory ?? category.subCategory ?? '';
    final sizes = filter.sizesString;
    final selectTag = filter.tagsString;

    return await _apiController.apiPerfumeItem(
      category: category,
      sub: sub,
      sizes: sizes,
      page: page,
      numSort: filter.sortMode,
      selectTag: selectTag,
      season: filter.season,
      requestVersion: requestVersion,
    );
  }

  /// Build department filter from category and sizes
  DepartmentFilterModel buildFilter({
    required CategoryModel category,
    String sizes = '',
    String season = '',
    int sortMode = 2,
    List<String> tags = const [],
  }) {
    return DepartmentFilterModel(
      category: category,
      subCategory: category.subCategory,
      sizes: sizes.isNotEmpty ? sizes.split(',') : [],
      tags: tags,
      season: season,
      sortMode: sortMode,
    );
  }

  /// Extract selected sizes from loading states map
  String extractSelectedSizes(Map<String, bool>? loadingStates) {
    if (loadingStates == null) return '';
    
    return loadingStates.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(',');
  }

  /// Check if any loading state is active
  bool hasActiveLoadingState(Map<String, bool>? loadingStates) {
    if (loadingStates == null) return false;
    return loadingStates.values.any((value) => value);
  }

  /// Create empty department state
  DepartmentModel createEmptyState() {
    return DepartmentModel.empty();
  }

  /// Helper method to extract sizes from loading states map
  /// This encapsulates the logic that was duplicated across views
  static String extractSizesFromLoadingStates(Map<String, bool>? loadingStates) {
    if (loadingStates == null) return '';
    
    return loadingStates.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(',');
  }
}

