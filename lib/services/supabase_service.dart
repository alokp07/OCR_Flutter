import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String supabaseUrl = 'https://oulyxsftgpqmsllolpqm.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91bHl4c2Z0Z3BxbXNsbG9scHFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNjMxOTYsImV4cCI6MjA3MjYzOTE5Nn0.4SHSC0XNP-uKKo3oqYWbZQ3Fw4o25RVE-mv_5MgQvAA';

  late final SupabaseClient _client;

  SupabaseClient get client => _client;
  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    _client = Supabase.instance.client;
  }

  // Register user with role
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'student' or 'teacher'
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      if (response.user != null) {
        // Store user role in profiles table
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
        });

        await _saveUserData(response.user!, role);
        return {'success': true, 'user': response.user};
      } else {
        return {'success': false, 'error': 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Login user
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Get user profile with role
        final profileData = await getUserProfile(response.user!.id);
        if (profileData['success']) {
          await _saveUserData(response.user!, profileData['role']);
          return {'success': true, 'user': response.user, 'role': profileData['role']};
        }
        return {'success': true, 'user': response.user, 'role': 'unknown'};
      } else {
        return {'success': false, 'error': 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .single();

      return {
        'success': true,
        'profile': response,
        'role': response['role'] ?? 'unknown',
        'full_name': response['full_name'] ?? '',
        'email': response['email'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    if (currentUser == null) {
      return {'success': false, 'error': 'No user logged in'};
    }
    return await getUserProfile(currentUser!.id);
  }

  // Save user data locally
  Future<void> _saveUserData(User user, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email ?? '');
    await prefs.setString('user_role', role);
    await prefs.setBool('is_logged_in', true);
  }

  // Get saved user role
  Future<String> getSavedUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? 'unknown';
  }

  // Check if user is logged in (from local storage)
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return {'success': true, 'message': 'Password reset email sent'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}