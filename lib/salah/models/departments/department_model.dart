import '../constants/constant_model.dart';
import '../items/item_model.dart';

/// Model class representing the state of a department
class DepartmentModel {
  final List<Item> items;
  final List<CategoryModel> subCategories;
  final List<CategoryModel> selectedSubCategories;
  final CategoryModel? selectedSubCategory;
  final CategoryModel? selectedCategory;
  final int totalItems;
  final int currentPage;
  final int sortMode;
  final bool isLoading;
  final bool hasMoreData;
  final String selectedSizes;
  final Map<String, bool> loadingStates;
  final Map<String, double> scrollPositions;
  final Map<String, bool> favouriteStates;

  DepartmentModel({
    this.items = const [],
    this.subCategories = const [],
    this.selectedSubCategories = const [],
    this.selectedSubCategory,
    this.selectedCategory,
    this.totalItems = 0,
    this.currentPage = 1,
    this.sortMode = 2,
    this.isLoading = false,
    this.hasMoreData = true,
    this.selectedSizes = '',
    this.loadingStates = const {},
    this.scrollPositions = const {},
    this.favouriteStates = const {},
  });

  /// Create a copy of the model with updated fields
  DepartmentModel copyWith({
    List<Item>? items,
    List<CategoryModel>? subCategories,
    List<CategoryModel>? selectedSubCategories,
    CategoryModel? selectedSubCategory,
    CategoryModel? selectedCategory,
    int? totalItems,
    int? currentPage,
    int? sortMode,
    bool? isLoading,
    bool? hasMoreData,
    String? selectedSizes,
    Map<String, bool>? loadingStates,
    Map<String, double>? scrollPositions,
    Map<String, bool>? favouriteStates,
  }) {
    return DepartmentModel(
      items: items ?? this.items,
      subCategories: subCategories ?? this.subCategories,
      selectedSubCategories: selectedSubCategories ?? this.selectedSubCategories,
      selectedSubCategory: selectedSubCategory ?? this.selectedSubCategory,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      totalItems: totalItems ?? this.totalItems,
      currentPage: currentPage ?? this.currentPage,
      sortMode: sortMode ?? this.sortMode,
      isLoading: isLoading ?? this.isLoading,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      selectedSizes: selectedSizes ?? this.selectedSizes,
      loadingStates: loadingStates ?? this.loadingStates,
      scrollPositions: scrollPositions ?? this.scrollPositions,
      favouriteStates: favouriteStates ?? this.favouriteStates,
    );
  }

  /// Create an empty/reset department model
  factory DepartmentModel.empty() {
    return DepartmentModel(
      items: [],
      subCategories: [],
      selectedSubCategories: [],
      selectedSubCategory: null,
      selectedCategory: null,
      totalItems: 0,
      currentPage: 1,
      sortMode: 2,
      isLoading: false,
      hasMoreData: true,
      selectedSizes: '',
      loadingStates: {},
      scrollPositions: {},
      favouriteStates: {},
    );
  }
}

/// Model class for department filter configuration
class DepartmentFilterModel {
  final List<String> sizes;
  final List<String> tags;
  final String season;
  final int sortMode;
  final CategoryModel? category;
  final String? subCategory;

  DepartmentFilterModel({
    this.sizes = const [],
    this.tags = const [],
    this.season = '',
    this.sortMode = 2,
    this.category,
    this.subCategory,
  });

  /// Convert sizes list to comma-separated string
  String get sizesString => sizes.join(',');

  /// Convert tags list to comma-separated string
  String get tagsString => tags.join(',');

  DepartmentFilterModel copyWith({
    List<String>? sizes,
    List<String>? tags,
    String? season,
    int? sortMode,
    CategoryModel? category,
    String? subCategory,
  }) {
    return DepartmentFilterModel(
      sizes: sizes ?? this.sizes,
      tags: tags ?? this.tags,
      season: season ?? this.season,
      sortMode: sortMode ?? this.sortMode,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
    );
  }
}

/// Model class for department pagination state
class DepartmentPaginationModel {
  final int currentPage;
  final int totalItems;
  final bool hasMoreData;
  final bool isLoadingMore;

  DepartmentPaginationModel({
    this.currentPage = 1,
    this.totalItems = 0,
    this.hasMoreData = true,
    this.isLoadingMore = false,
  });

  DepartmentPaginationModel copyWith({
    int? currentPage,
    int? totalItems,
    bool? hasMoreData,
    bool? isLoadingMore,
  }) {
    return DepartmentPaginationModel(
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

