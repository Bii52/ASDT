import 'dart:ui';
import 'dart:convert'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _err;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Vui lòng nhập email';
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(value)) return 'Email không hợp lệ';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = (v ?? '');
    if (value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  Future<void> _onSubmit() async {
    setState(() => _err = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700)); // giả lập xử lý
    if (!mounted) return;

    // Giả lập lỗi đăng nhập:
    // setState(() { _err = 'Sai thông tin đăng nhập'; _loading = false; return; });

    // Thành công → vào Dashboard
    context.go('/dashboard'); // nếu bạn để Dashboard ở '/', đổi lại context.go('/')
  }

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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 880;

    return Scaffold(
      body: Stack(
        children: [
          // Nền gradient nhẹ
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.10),
                    theme.colorScheme.secondaryContainer.withOpacity(0.25),
                    theme.colorScheme.surfaceTint.withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),

          // Vệt trang trí
          Positioned(
            top: -60, left: -40,
            child: _Blob(size: size.width * 0.35, color: theme.colorScheme.primary.withOpacity(0.16)),
          ),
          Positioned(
            bottom: -80, right: -50,
            child: _Blob(size: size.width * 0.40, color: theme.colorScheme.tertiary.withOpacity(0.14)),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: isWide
                      ? Row(
                          children: [
                            Expanded(child: _SideHero()),
                            const SizedBox(width: 28),
                            Expanded(child: _CardForm(theme: theme, form: _buildForm(theme))),
                          ],
                        )
                      : _CardForm(theme: theme, form: _buildForm(theme)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo + tiêu đề
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.12),
            ),
            child: Icon(Icons.lock_outline, size: 32, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 14),
          Text(
            'Đăng nhập',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2),
          ),
          const SizedBox(height: 6),
          Text(
            'Chào mừng quay lại 👋',
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 18),

          if (_err != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ErrorBanner(message: _err!),
            ),

          // Email
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),

          // Password
          TextFormField(
            controller: _pass,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => !_loading ? _onSubmit() : null,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          // Links
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: const Text('Quên mật khẩu?'),
            ),
          ),

          const SizedBox(height: 6),
          // Submit
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _onSubmit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Vào ứng dụng'),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Chưa có tài khoản?', style: theme.textTheme.bodyMedium),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Đăng ký'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardForm extends StatelessWidget {
  const _CardForm({required this.theme, required this.form});
  final ThemeData theme;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: theme.colorScheme.surface.withOpacity(0.68),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: form,
            ),
          ),
        ),
      ),
    );
  }
}

class _SideHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.70),
                theme.colorScheme.secondaryContainer.withOpacity(0.70),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.health_and_safety_rounded, size: 160, color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.92)),
              Positioned(
                bottom: 18,
                child: Text(
                  'An tâm mỗi ngày',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 50, spreadRadius: 10)],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: c.error),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: c.onErrorContainer))),
        ],

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
