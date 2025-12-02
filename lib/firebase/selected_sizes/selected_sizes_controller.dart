import 'package:fawri_app_refactor/firebase/selected_sizes/selected_sizes_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectedSizeService {
  final CollectionReference selectedSizesCollection =
      FirebaseFirestore.instance.collection('selected_sizes');

  Future<void> addSelectedSize(SelectedSizeModel selectedSize) {
    return selectedSizesCollection
        .doc(selectedSize.id)
        .set(selectedSize.toMap());
  }

  Future<void> deleteSelectedSizeById(String selectedSizeId) {
    return selectedSizesCollection.doc(selectedSizeId).delete();
  }

  Future<void> updateSelectedSize(SelectedSizeModel selectedSize) {
    return selectedSizesCollection
        .doc(selectedSize.id)
        .update(selectedSize.toMap());
  }

  Stream<List<SelectedSizeModel>> getSelectedSizes() {
    return selectedSizesCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              SelectedSizeModel.fromMap(doc.data() as Map<String, dynamic>?))
          .toList();
    });
  }

  Future<SelectedSizeModel?> getSelectedSizeByUserIdAndCategoryId(
      String userId, String categoryId) async {
    QuerySnapshot querySnapshot = await selectedSizesCollection
        .where('userId', isEqualTo: userId)
        .where('categoryId', isEqualTo: categoryId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return SelectedSizeModel.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>?);
    } else {
      return null;
    }
  }

  Future<List<SelectedSizeModel>> getSelectedSizesByUserId(
      String userId) async {
    QuerySnapshot querySnapshot =
        await selectedSizesCollection.where('userId', isEqualTo: userId).get();

    return querySnapshot.docs
        .map((doc) =>
            SelectedSizeModel.fromMap(doc.data() as Map<String, dynamic>?))
        .toList();
  }
}
