import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/features/auth/models/user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final response = await UserService.login(
          _emailController.text,
          _passwordController.text,
        );

        // Debug: Print response để kiểm tra
        print('Login response: $response');

        if (response['success'] == true && mounted) {
          // 1. Create User object from response
          final user = User.fromJson(response['user']);
          
          // 2. Get token from response
          final token = response['accessToken'];

          // Debug: Print user và token
          print('User: $user');
          print('Token: $token');

          // 3. Update the auth state using the notifier
          ref.read(authProvider.notifier).login(user, token);

          // 4. Manual redirect based on user role
          if (mounted) {
            if (user.role == 'doctor') {
              context.go('/doctor/dashboard');
            } else if (user.role == 'pharmacist') {
              context.go('/pharmacist/dashboard');
            } else if (user.role == 'admin') {
              context.go('/admin/dashboard');
            } else {
              context.go('/dashboard');
            }
          }

          // The router's redirect logic will now handle navigation automatically.
          // We can show a success message for better UX, but navigation is handled by the router.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập thành công!')),
          );

        } else {
          // If login fails, set loading to false and show error
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đăng nhập thất bại: ${response['message']}')),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi đăng nhập: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
              TextButton(
                onPressed: () {
                  context.go('/register');
                },
                child: const Text('Dont have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}