import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to auth state changes (logged in or out)
  Stream<User?> get userStream => _auth.authStateChanges();

  // SIGN UP
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Returns the error message (e.g., "Email already in use")
    }
  }

  // LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}