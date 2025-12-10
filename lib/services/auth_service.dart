import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> signUp({
    required String email,
    required String password,
    String role = 'member',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(cred.user!.uid).set({
        "uid": cred.user!.uid,
        "email": email,
        "role": role,
        "groupIds": [],
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Signup failed";
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-email') {
        return 'Password or account mismatch';
      }
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('role')) {
        return doc.get('role');
      }
    }
    return 'member';
  }

  User? get currentUser => _auth.currentUser;
}
