import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/auth_screen.dart';
import '../services/supabase_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final supabaseService = SupabaseService();

      // Check if user is logged in from local storage first (faster)
      final savedLoginStatus = await supabaseService.isUserLoggedIn();

      if (savedLoginStatus) {
        // Double-check with Supabase current user
        final currentUser = supabaseService.currentUser;
        if (currentUser != null) {
          setState(() {
            isLoggedIn = true;
            isLoading = false;
          });
          return;
        }
      }

      // If not logged in or session expired
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });

    } catch (e) {
      // On error, assume not logged in
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/images/loading_animation.gif'),
                height: 120,
                width: 120,
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                color: Colors.black,
              ),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Navigate based on login status
    return isLoggedIn ? const HomeScreen() : const AuthScreen();
  }
}