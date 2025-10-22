import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _err;
  bool _agree = true; // giả lập: đã đồng ý điều khoản

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Vui lòng nhập họ tên';
    if (value.length < 2) return 'Họ tên quá ngắn';
    return null;
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

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Vui lòng nhập lại mật khẩu';
    if (v != _pass.text) return 'Mật khẩu nhập lại không khớp';
    return null;
  }

  Future<void> _onSubmit() async {
    setState(() => _err = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agree) {
      setState(() => _err = 'Bạn cần đồng ý điều khoản sử dụng'); 
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // mock xử lý
    if (!mounted) return;

    // Giả lập lỗi:
    // setState(() { _err = 'Email đã tồn tại'; _loading = false; return; });

    // Đăng ký thành công → quay về màn đăng nhập
    context.go('/login');
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
          Positioned(top: -60, left: -40, child: _Blob(size: size.width * 0.35, color: theme.colorScheme.primary.withOpacity(0.16))),
          Positioned(bottom: -80, right: -50, child: _Blob(size: size.width * 0.40, color: theme.colorScheme.tertiary.withOpacity(0.14))),

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
            decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary.withOpacity(0.12)),
            child: Icon(Icons.person_add_alt_1_rounded, size: 32, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 14),
          Text('Tạo tài khoản', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2)),
          const SizedBox(height: 6),
          Text('Bắt đầu hành trình chăm sóc sức khỏe của bạn', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 18),

          if (_err != null)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: _ErrorBanner(message: _err!)),

          // Họ tên
          TextFormField(
            controller: _name,
            textInputAction: TextInputAction.next,
            validator: _validateName,
            decoration: InputDecoration(
              labelText: 'Họ tên',
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),

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

          // Mật khẩu
          TextFormField(
            controller: _pass,
            obscureText: _obscure1,
            textInputAction: TextInputAction.next,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure1 = !_obscure1),
                icon: Icon(_obscure1 ? Icons.visibility_off_rounded : Icons.visibility_rounded),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),

          // Xác nhận mật khẩu
          TextFormField(
            controller: _pass2,
            obscureText: _obscure2,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => !_loading ? _onSubmit() : null,
            validator: _validateConfirm,
            decoration: InputDecoration(
              labelText: 'Nhập lại mật khẩu',
              prefixIcon: const Icon(Icons.lock_reset_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure2 = !_obscure2),
                icon: Icon(_obscure2 ? Icons.visibility_off_rounded : Icons.visibility_rounded),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: 8),
          // Agree terms (mock)
          Row(
            children: [
              Checkbox(
                value: _agree,
                onChanged: (v) => setState(() => _agree = v ?? false),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Tôi đồng ý với ',
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {}, // mở trang điều khoản khi có
                          child: Text('Điều khoản sử dụng', style: TextStyle(color: theme.colorScheme.primary)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
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
                  : const Text('Tạo tài khoản'),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Đã có tài khoản?', style: theme.textTheme.bodyMedium),
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Đăng nhập'),
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
              Icon(Icons.person_rounded, size: 160, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.92)),
              Positioned(
                bottom: 18,
                child: Text(
                  'Tạo tài khoản mới',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.92),
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
      ),
    );
  }
}
