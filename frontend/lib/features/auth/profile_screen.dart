import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final response = await UserService.getProfile();
    if (response['success']) {
      setState(() {
        _userProfile = response['user']; // Fix: access user data directly
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response['message'];
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final response = await UserService.logout();
    if (response['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully!')),
        );
        context.go('/login'); // Navigate to login after logout
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout Failed: ${response['message']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _userProfile == null
                  ? const Center(child: Text('No profile data available.'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${_userProfile!['fullName'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 10),
                          Text('Email: ${_userProfile!['email'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 10),
                          Text('Role: ${_userProfile!['role'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _logout,
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
