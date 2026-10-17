import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  /// Interns only (real-time), sorted by name.
  Stream<List<UserModel>> interns() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'intern')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => UserModel.fromMap(d.data(), d.id))
              .toList();
          list.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          return list;
        });
  }
}
