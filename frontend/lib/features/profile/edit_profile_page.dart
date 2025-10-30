import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/features/auth/models/user.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bloodPressureController;
  late TextEditingController _heartRateController;
  late TextEditingController _bloodTypeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;

    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _heightController = TextEditingController(text: user?.height?.toString() ?? '');
    _weightController = TextEditingController(text: user?.weight?.toString() ?? '');
    _bloodPressureController = TextEditingController(text: user?.bloodPressure ?? '');
    _heartRateController = TextEditingController(text: user?.heartRate?.toString() ?? '');
    _bloodTypeController = TextEditingController(text: user?.bloodType ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final profileData = {
        'fullName': _fullNameController.text,
        'height': double.tryParse(_heightController.text),
        'weight': double.tryParse(_weightController.text),
        'bloodPressure': _bloodPressureController.text,
        'heartRate': int.tryParse(_heartRateController.text),
        'bloodType': _bloodTypeController.text,
      };

      final result = await UserService.updateProfile(profileData);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        final updatedUser = User.fromJson(result['user']);
        ref.read(authProvider.notifier).updateUser(updatedUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          context.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: ${result['message']}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _bloodPressureController,
                    decoration: const InputDecoration(labelText: 'Blood Pressure'),
                  ),
                  TextFormField(
                    controller: _heartRateController,
                    decoration: const InputDecoration(labelText: 'Heart Rate (bpm)'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _bloodTypeController,
                    decoration: const InputDecoration(labelText: 'Blood Type'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }
}
