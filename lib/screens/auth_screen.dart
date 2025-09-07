import 'package:flutter/material.dart';
import 'home_screen.dart'; // Assuming home_screen.dart is in the same 'screens' directory
import 'login_screen.dart';
import 'register_screen.dart';


class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.black;
    const Color accentColor = Color(0xFFEFEFEF); // A soft, light gray for secondary buttons
    const Color titleColor = Color(0xFF333333); // A softer black
    const Color subtitleColor = Color(0xFF888888);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // App Logo/Branding Section
              Image.asset(
                'assets/images/loading_animation.gif',
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 30),
              Text(
                'Welcome to GradeTracker',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your grades with ease.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 60),

              // Primary Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Secondary Create Account Button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide.none, // Removes the default border for a cleaner look
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}