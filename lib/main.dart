import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/welcome_screen.dart'; // Correct path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Make sure your Firebase config is correct
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HerSafe',
      theme: ThemeData(
        primaryColor: const Color(0xFF92487A),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFE49BA6),
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}
