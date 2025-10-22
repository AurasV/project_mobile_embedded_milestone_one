import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'signup.dart';
import 'dashboard.dart';
import 'add_prescription.dart';
import 'add_pills_form.dart';
import 'settings.dart';
import 'profile.dart';
import 'pills_provider.dart';

void main() {
  runApp(const HealthUpApp());
}

class HealthUpApp extends StatelessWidget {
  const HealthUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PillsProvider(),
      child: MaterialApp(
        title: 'HealthUp',
        theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFf8f9fc),
        primaryColor: const Color(0xFF4e5ca6),
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
        '/dashboard': (context) => const DashboardScreen(),
        '/add_prescription': (context) => const AddPrescriptionScreen(),
        '/add_pills_form': (context) => const AddPillsFormScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      ),
    );
  }
}
