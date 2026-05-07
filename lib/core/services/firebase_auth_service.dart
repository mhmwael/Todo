import 'package:firebase_auth/firebase_auth.dart';

// Singleton service managing Firebase Authentication operations (sign up, sign in, sign out, password reset)
class FirebaseAuthService {
  // Singleton instance initialization
  static final FirebaseAuthService
  _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  // Firebase Auth instance
  final FirebaseAuth
  _auth = FirebaseAuth.instance;

  // Observable stream of authentication state changes
  Stream<
    User?
  >
  get authStateChanges => _auth.authStateChanges();

  // Get currently logged-in user
  User?
  get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool
  get isLoggedIn =>
      _auth.currentUser !=
      null;

  // Register new user with email and password
  Future<
    UserCredential?
  >
  signUp({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (
      e
    ) {
      if (e.code ==
          'weak-password') {
        throw Exception(
          'The password provided is too weak.',
        );
      } else if (e.code ==
          'email-already-in-use') {
        throw Exception(
          'The account already exists for that email.',
        );
      }
      throw Exception(
        'Authentication failed: ${e.message}',
      );
    } catch (
      e
    ) {
      throw Exception(
        'Unexpected error: $e',
      );
    }
  }

  // Log in user with email and password
  Future<
    UserCredential?
  >
  signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (
      e
    ) {
      if (e.code ==
          'user-not-found') {
        throw Exception(
          'No user found for that email.',
        );
      } else if (e.code ==
          'wrong-password') {
        throw Exception(
          'Wrong password provided for that user.',
        );
      }
      throw Exception(
        'Authentication failed: ${e.message}',
      );
    } catch (
      e
    ) {
      throw Exception(
        'Unexpected error: $e',
      );
    }
  }

  // Log out current user
  Future<
    void
  >
  signOut() async {
    try {
      await _auth.signOut();
    } catch (
      e
    ) {
      throw Exception(
        'Error signing out: $e',
      );
    }
  }

  // Send password reset email
  Future<
    void
  >
  resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      );
    } catch (
      e
    ) {
      throw Exception(
        'Error sending reset email: $e',
      );
    }
  }

  // Get current user's email
  String?
  getUserEmail() => _auth.currentUser?.email;

  // Get current user's unique ID
  String?
  getUserId() => _auth.currentUser?.uid;
}
