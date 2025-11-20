import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_firebase_model.dart';

class OrderController {
  final CollectionReference cartCollection =
      FirebaseFirestore.instance.collection('orders');

  Future<void> addUser(OrderFirebaseModel cartItem) {
    return cartCollection.doc(cartItem.id).set(cartItem.toMap());
  }

  Stream<List<OrderFirebaseModel>> getOrderItems() {
    return cartCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              OrderFirebaseModel.fromMap(doc.data() as Map<String, dynamic>?))
          .toList();
    });
  }
}
