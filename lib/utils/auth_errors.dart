import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password';
      case 'invalid-email':
        return 'Invalid email format';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters)';
      case 'network-request-failed':
        return 'Please check your internet connection';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Something went wrong (${e.code})';
    }
  }
  return 'Something went wrong: $e';
}
