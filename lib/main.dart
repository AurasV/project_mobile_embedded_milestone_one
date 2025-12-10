import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'signup.dart';
import 'dashboard.dart';
import 'add_prescription.dart';
import 'add_pills_form.dart';
import 'settings.dart';
import 'profile.dart';
import 'pills_provider.dart';
import 'medication_detail.dart';
import 'edit_medication.dart';
import 'services/preferences_service.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          surface: Color(0xFFdde0ef),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
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
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/medication_detail') {
          final medication = settings.arguments as PillData;
          return MaterialPageRoute(
            builder: (context) => MedicationDetailScreen(medication: medication),
          );
        }
        if (settings.name == '/edit_medication') {
          final medication = settings.arguments as PillData;
          return MaterialPageRoute(
            builder: (context) => EditMedicationScreen(medication: medication),
          );
        }
        return null;
      },
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefsService = PreferencesService();
    final firebaseService = FirebaseService();
    
    // Check if user wants to stay logged in and has valid session
    final stayLoggedIn = await prefsService.getStayLoggedIn();
    final currentUser = firebaseService.currentUser;

    await Future.delayed(const Duration(seconds: 1)); // Brief splash

    if (mounted) {
      if (stayLoggedIn && currentUser != null) {
        // User is already logged in
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Clear credentials if stay logged in is false
        if (!stayLoggedIn) {
          await prefsService.clearUserCredentials();
        }
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety, size: 100, color: Color(0xFF4e5ca6)),
            SizedBox(height: 24),
            Text(
              'HealthUp',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4e5ca6),
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
