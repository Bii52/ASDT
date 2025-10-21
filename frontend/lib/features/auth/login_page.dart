import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  String? err;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 8),
          TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu')),
          const SizedBox(height: 16),
          if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
          FilledButton(
            onPressed: loading ? null : () async {
              setState(() { loading = true; err = null; });
              await Future.delayed(const Duration(milliseconds: 600)); // giả lập
              if (email.text.isEmpty || pass.text.isEmpty) {
                setState(() { err = 'Vui lòng nhập email & mật khẩu'; loading = false; });
                return;
              }
              if (!mounted) return;
              context.go('/'); // chuyển vào app chính
            },
            child: loading ? const CircularProgressIndicator() : const Text('Vào ứng dụng'),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: () => context.go('/register'), child: const Text('Chưa có tài khoản? Đăng ký')),
        ]),
      ),
    );
  }
}
