import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'auth_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _supabaseService = SupabaseService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (!_supabaseService.isLoggedIn) {
        // Check if user was logged in before (persistent login)
        final wasLoggedIn = await _supabaseService.isUserLoggedIn();
        if (!wasLoggedIn) {
          setState(() {
            _isGuest = true;
            _isLoading = false;
          });
          return;
        }
      }

      final result = await _supabaseService.getCurrentUserProfile();

      if (result['success']) {
        setState(() {
          _userProfile = result['profile'];
          _isLoading = false;
          _isGuest = false;
        });
      } else {
        // If failed to get profile but user claims to be logged in, they might be a guest
        setState(() {
          _isGuest = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isGuest = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context, // This is the ProfileTab's context, valid for showing the dialog
      builder: (BuildContext dialogContext) { // Use a different name for the dialog's context
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Correctly uses dialog context
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // 1. Pop the dialog using its context immediately.
                Navigator.pop(dialogContext);

                // 2. Perform the asynchronous logout operation.
                await _supabaseService.logout();

                // 3. Now, safely check if the original ProfileTab is still mounted.
                if (mounted) {
                  // 4. Use the correct context (from ProfileTab) for navigation.
                  Navigator.pushAndRemoveUntil(
                    context, // Use the outer `context` from the _ProfileTabState
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                        (route) => false,
                  );
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Guest User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You are currently using the app as a guest. Create an account or login to access all features.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Login / Sign Up',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    if (_userProfile == null) {
      return const Center(child: Text('Failed to load profile'));
    }

    final role = _userProfile!['role'] ?? 'Unknown';
    final fullName = _userProfile!['full_name'] ?? 'No Name';
    final email = _userProfile!['email'] ?? 'No Email';
    final createdAt = _userProfile!['created_at'];

    DateTime? joinDate;
    if (createdAt != null) {
      try {
        joinDate = DateTime.parse(createdAt);
      } catch (e) {
        joinDate = null;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Profile Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: role.toLowerCase() == 'teacher'
                        ? Colors.blue[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: role.toLowerCase() == 'teacher'
                          ? Colors.blue[800]
                          : Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Profile Information Cards
          _buildInfoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: email,
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 16),

          _buildInfoCard(
            icon: role.toLowerCase() == 'teacher'
                ? Icons.school_outlined
                : Icons.person_outline,
            title: 'Role',
            value: role,
            iconColor: role.toLowerCase() == 'teacher'
                ? Colors.purple
                : Colors.orange,
          ),
          const SizedBox(height: 16),

          if (joinDate != null)
            _buildInfoCard(
              icon: Icons.calendar_today_outlined,
              title: 'Member Since',
              value: '${joinDate.day}/${joinDate.month}/${joinDate.year}',
              iconColor: Colors.green,
            ),

          const SizedBox(height: 32),

          // Statistics Section (placeholder for future features)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Subjects', role.toLowerCase() == 'teacher' ? '5' : '6'),
                    _buildStatItem('Grades', role.toLowerCase() == 'teacher' ? '120' : '45'),
                    _buildStatItem('Average', role.toLowerCase() == 'teacher' ? 'B+' : 'A-'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Column(
            children: [
              // Edit Profile Button (placeholder)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit profile feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Settings Button (placeholder)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Settings'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_isGuest) {
      return _buildGuestView();
    }

    return _buildProfileView();
  }
}