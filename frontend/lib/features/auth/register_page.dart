import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Họ tên')),
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu')),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: loading ? null : () async {
              setState(() => loading = true);
              await Future.delayed(const Duration(milliseconds: 600)); // mock
              if (!mounted) return;
              context.go('/login');
            },
            child: loading ? const CircularProgressIndicator() : const Text('Tạo tài khoản'),
          ),
        ]),
      ),
    );
  }
}
