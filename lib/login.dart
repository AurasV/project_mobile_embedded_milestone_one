import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'services/preferences_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firebaseService = FirebaseService();
  final prefsService = PreferencesService();
  bool stayLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.health_and_safety, size: 80, color: Color(0xFF4e5ca6)),
              const SizedBox(height: 16),
              const Text("Welcome to HealthUp", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: stayLoggedIn,
                    onChanged: (value) {
                      setState(() {
                        stayLoggedIn = value ?? false;
                      });
                    },
                  ),
                  const Text('Stay logged in'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final userCredential = await firebaseService.signIn(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                      
                      // Save login preference
                      await prefsService.setStayLoggedIn(stayLoggedIn);
                      if (stayLoggedIn) {
                        await prefsService.saveUserCredentials(
                          userCredential.user!.uid,
                          userCredential.user!.email!,
                        );
                      }
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged in successfully!')),
                        );
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: const Text("Login", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/signup'),
                child: const Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    children: [
                      TextSpan(
                        text: "Sign up",
                        style: TextStyle(
                          color: Color(0xFF4e5ca6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
