import 'package:flutter/material.dart';
import 'pages/home_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔐 Ensure anonymous auth only once
  final auth = FirebaseAuth.instance;

  if (auth.currentUser == null) {
    try {
      await auth.signInAnonymously();
    } catch (e) {
      debugPrint('Anonymous auth failed: $e');
    }
  }

  runApp(const MyApp());
}

/// ---------------- APP ROOT ----------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
