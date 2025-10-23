import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

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

  Future<void> _login() async {
    setState(() {
      loading = true;
      err = null;
    });

    try {
      if (email.text.isEmpty || pass.text.isEmpty) {
        setState(() {
          err = 'Vui lòng nhập email & mật khẩu';
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/users/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email.text,
          'password': pass.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        // TODO: Save the token
        context.go('/'); // chuyển vào app chính
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          err = data['message'] ?? 'Đăng nhập thất bại';
        });
      }
    } catch (e) {
      setState(() {
        err = 'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 8),
          TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu')),
          const SizedBox(height: 16),
          if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: loading ? null : _login,
            child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Vào ứng dụng'),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: () => context.go('/register'), child: const Text('Chưa có tài khoản? Đăng ký')),
        ]),
      ),
    );
  }
}
