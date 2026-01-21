// lib/auth/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =============================
  // REGISTER USER + SAVE PROFILE
  // =============================
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final UserCredential userCred =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = userCred.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Invalid email address.';
        default:
          return e.message ?? 'Registration failed.';
      }
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // =============================
  // LOGIN USER
  // =============================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        default:
          return e.message ?? 'Login failed.';
      }
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // =============================
  // LOGOUT
  // =============================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // =============================
  // PASSWORD RESET
  // =============================
  Future<String?> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to send reset email.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // =============================
  // CURRENT USER
  // =============================
  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // =============================
  // GET CURRENT USER NAME (HOME)
  // =============================
  Future<String> getCurrentUserName() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'User';

      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) return 'User';

      final data = doc.data();
      if (data == null || !data.containsKey('name')) return 'User';

      return data['name'] as String;
    } catch (_) {
      return 'User';
    }
  }
}
