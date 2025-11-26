// lib/auth/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user and save basic profile to Firestore
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'name': name,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password is too weak. It must be at least 6 characters.';
        case 'email-already-in-use':
          return 'This email is already registered. Try logging in.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'operation-not-allowed':
          return 'Email/Password accounts are not enabled in Firebase.';
        default:
          return 'Auth error: ${e.message}';
      }
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Incorrect password.';
        default:
          return 'Login error: ${e.message}';
      }
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Password reset
  Future<String?> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return 'Could not send reset email: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
