class SelectedSizeModel {
  final String id;
  final String userId;
  final String categoryId;
  List<String> selectedSizes;

  SelectedSizeModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.selectedSizes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'selectedSizes': selectedSizes,
    };
  }

  factory SelectedSizeModel.fromMap(Map<String, dynamic>? map) {
    return SelectedSizeModel(
      id: map?['id'] ?? '',
      userId: map?['userId'] ?? '',
      categoryId: map?['categoryId'] ?? '',
      selectedSizes: List<String>.from(map?['selectedSizes'] ?? []),
    );
  }
}
