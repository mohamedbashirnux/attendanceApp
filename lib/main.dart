import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import 'pages/student_portal/api_config.dart';
import 'pages/student_portal/models/student_session.dart';
import 'pages/teacher_portal/models/teacher_session.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hydrate the teacher and student sessions from SharedPreferences
  // so a returning user can be navigated straight to their shell.
  await Future.wait([
    TeacherSession.load(),
    StudentSession.load(),
  ]);
  // Log the resolved base URL so the user can see in logcat which
  // server the app is talking to. Helpful when "Could not reach the
  // server" pops up on a real device.
  developer.log('API base URL: ${resolveBaseUrl()}', name: 'main');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capital University',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF5F61E6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5F61E6),
          primary: const Color(0xFF5F61E6),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5F61E6),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
