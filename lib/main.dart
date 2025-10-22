import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';

void main() {
  runApp(const HealthUpApp());
}

class HealthUpApp extends StatelessWidget {
  const HealthUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthUp',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFf8f9fc), // very light background
        primaryColor: const Color(0xFF4e5ca6), // main accent
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4e5ca6),
          secondary: Color(0xFF5865b0),
          background: Color(0xFFf8f9fc),
          surface: Color(0xFFdde0ef),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Color(0xFF161a2e),
          onSurface: Color(0xFF161a2e),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFdde0ef),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Color(0xFF485499)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4e5ca6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF161a2e)),
          titleLarge: TextStyle(
              color: Color(0xFF161a2e),
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
