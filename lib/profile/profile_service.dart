import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Fetch current user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await _usersCollection.doc(user.uid).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _usersCollection.doc(user.uid).set(data, SetOptions(merge: true));
  }
}
