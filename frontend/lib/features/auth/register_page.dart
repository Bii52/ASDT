import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

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
  String? err;

  Future<void> _register() async {
    setState(() {
      loading = true;
      err = null;
    });

    try {
      if (name.text.isEmpty || email.text.isEmpty || pass.text.isEmpty) {
        setState(() {
          err = 'Vui lòng nhập đầy đủ thông tin';
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/users/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name.text,
          'email': email.text,
          'password': pass.text,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        context.go('/login');
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          err = data['message'] ?? 'Đăng ký thất bại';
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
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Họ tên')),
          const SizedBox(height: 8),
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 8),
          TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu')),
          const SizedBox(height: 16),
          if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: loading ? null : _register,
            child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Tạo tài khoản'),
          ),
        ]),
      ),
    );
  }
}
