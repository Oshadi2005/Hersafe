import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure you have this if using Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HerSafeApp());
}

class HerSafeApp extends StatelessWidget {
  const HerSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HerSafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF92487A),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.purple,
        ),
        fontFamily: 'Poppins', // ✅ Apply Poppins globally
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF92487A),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
      home: const LoginScreen(), // Start with login screen
      routes: {
        '/home': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}
