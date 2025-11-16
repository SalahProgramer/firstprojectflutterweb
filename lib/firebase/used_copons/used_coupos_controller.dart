import 'package:cloud_firestore/cloud_firestore.dart';
import 'used_coupos_firebase_model.dart';

class UsedCoponsController {
  final CollectionReference cartCollection =
      FirebaseFirestore.instance.collection('used_copons');

  Future<void> addUsedCopon(UsedCoponsFirebaseModel usedCoponItem) {
    return cartCollection.doc(usedCoponItem.id).set(usedCoponItem.toMap());
  }
}
