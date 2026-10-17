import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('uses the document ID and round-trips Firestore fields', () {
      final createdAt = DateTime.utc(2026, 10, 10, 8);
      final user = UserModel(
        uid: 'user-1',
        name: 'Alex Intern',
        email: 'alex@example.com',
        role: 'intern',
        createdAt: createdAt,
      );

      final data = user.toMap();
      final restored = UserModel.fromMap(data, user.uid);

      expect(restored.uid, user.uid);
      expect(restored.name, user.name);
      expect(restored.email, user.email);
      expect(restored.role, user.role);
      expect(restored.createdAt, createdAt);
      expect(data, isNot(contains('uid')));
      expect(data['createdAt'], isA<Timestamp>());
    });

    test('defaults missing optional strings', () {
      final user = UserModel.fromMap({
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 10, 10)),
      }, 'user-2');

      expect(user.uid, 'user-2');
      expect(user.name, isEmpty);
      expect(user.email, isEmpty);
      expect(user.role, 'intern');
    });
  });
}
