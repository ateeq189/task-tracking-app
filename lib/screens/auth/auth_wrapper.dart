import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_home.dart';
import '../intern/intern_home.dart';
import 'login_screen.dart';

/// Decides what to show: login screen, or the intern/admin app by role.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _auth = AuthService();
  late final Stream<User?> _authStream = _auth.authChanges;

  // Keep the user-document stream per uid so it is not recreated on rebuilds.
  String? _uid;
  Stream<UserModel?>? _userStream;

  Stream<UserModel?> _streamFor(String uid) {
    if (_uid != uid || _userStream == null) {
      _uid = uid;
      _userStream = _auth.userStream(uid);
    }
    return _userStream!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }
        if (!authSnap.hasData) return const LoginScreen();

        return StreamBuilder<UserModel?>(
          stream: _streamFor(authSnap.data!.uid),
          builder: (context, userSnap) {
            final user = userSnap.data;
            if (user == null) return const _Splash();
            return user.role == 'admin'
                ? AdminHome(user: user)
                : InternHome(user: user);
          },
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.blue700],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
