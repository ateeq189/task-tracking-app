import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_app/utils/auth_errors.dart';

void main() {
  group('authErrorMessage', () {
    test('groups invalid credential codes into a useful message', () {
      for (final code in [
        'invalid-credential',
        'wrong-password',
        'user-not-found',
      ]) {
        expect(
          authErrorMessage(FirebaseAuthException(code: code)),
          'Incorrect email or password',
        );
      }
    });

    test('explains common validation and connectivity failures', () {
      expect(
        authErrorMessage(FirebaseAuthException(code: 'invalid-email')),
        'Invalid email format',
      );
      expect(
        authErrorMessage(FirebaseAuthException(code: 'network-request-failed')),
        'Please check your internet connection',
      );
      expect(
        authErrorMessage(FirebaseAuthException(code: 'email-already-in-use')),
        'This email is already registered',
      );
    });

    test('includes an unknown Firebase error code', () {
      expect(
        authErrorMessage(FirebaseAuthException(code: 'unknown-code')),
        'Something went wrong (unknown-code)',
      );
    });

    test('reports non-Firebase errors', () {
      expect(authErrorMessage(StateError('failed')), contains('failed'));
    });
  });
}
