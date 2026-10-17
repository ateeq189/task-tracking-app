import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_wrapper.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internee.pk Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AuthWrapper(),
      builder: (context, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: darkMode,
          builder: (_, dark, _) => ColorFiltered(
            colorFilter: dark ? darkModeFilter : lightModeFilter,
            child: child,
          ),
        );
      },
    );
  }
}
