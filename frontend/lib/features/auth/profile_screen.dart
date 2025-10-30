import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/features/auth/models/user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      // This should not happen if routing is correct, but as a fallback
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('Not logged in. Please log in again.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('/profile/edit');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar Section
            CircleAvatar(
              radius: 50,
              backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null 
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Personal Information Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildInfoTile(Icons.person_outline, 'Role', user.role),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoTile(Icons.phone_outlined, 'Phone Number', user.phoneNumber ?? 'Not set'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: Colors.grey),
                    title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Health Metrics Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Health Metrics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildInfoTile(Icons.height, 'Height', user.height != null ? '${user.height} cm' : 'Not set'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoTile(Icons.monitor_weight_outlined, 'Weight', user.weight != null ? '${user.weight} kg' : 'Not set'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoTile(Icons.bloodtype_outlined, 'Blood Type', user.bloodType ?? 'Not set'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoTile(Icons.favorite_border, 'Heart Rate', user.heartRate != null ? '${user.heartRate} bpm' : 'Not set'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoTile(Icons.speed_outlined, 'Blood Pressure', user.bloodPressure ?? 'Not set'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }
}
