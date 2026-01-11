import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'user_model.dart';

class UserService {
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');

  Future<void> addUser(UserItem userItem) {
    return userCollection.doc(userItem.id).set(userItem.toMap());
  }

  Future<void> deleteUserById(String userId) {
    return userCollection.doc(userId).delete();
  }

  Future<void> updateUser(
    UserItem userItem, {
    bool updateBirthdate = true,
    bool updateGender = true,
  }) async {
    try {
      // Check if the phone number already exists in the collection
      QuerySnapshot querySnapshot = await userCollection
          .where('phone', isEqualTo: userItem.phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If phone number exists, update the corresponding document
        DocumentReference docRef = querySnapshot.docs.first.reference;

        Map<String, dynamic> updateData = {};
        if (updateBirthdate) {
          updateData['birthdate'] = userItem.birthdate;
        }
        if (updateGender) {
          updateData['gender'] = userItem.gender;
        }
        updateData['name'] = userItem.name;
        updateData['address'] = userItem.address;
        updateData['area'] = userItem.area;
        updateData['city'] = userItem.city;
        updateData['email'] = userItem.email;
        updateData['phone'] = userItem.phone;
        updateData['token'] = userItem.token;
        updateData['password'] = userItem.password;

        await docRef.update(updateData);
      } else {
        // If phone number does not exist, create a new document
        await addUser(userItem);
      }
    } catch (e) {
      printLog('Error updating user: $e');
    }
  }

  Future<void> deleteUser(String userId) {
    return userCollection.doc(userId).delete();
  }

  Stream<List<UserItem>> getUsers() {
    return userCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserItem.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
