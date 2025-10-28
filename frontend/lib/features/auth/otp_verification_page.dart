import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _email;
  String? _type;

  @override
  void initState() {
    super.initState();
    // Lấy email và type từ extra parameters
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    _email = extra?['email'];
    _type = extra?['type'] ?? 'registration';
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  String? _validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mã OTP';
    }
    if (value.length != 6) {
      return 'Mã OTP phải có 6 chữ số';
    }
    return null;
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;
    if (_email == null) {
      setState(() => _error = 'Email không hợp lệ');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> response;
      
      if (_type == 'registration') {
        response = await UserService.verifyRegistration(_email!, _otpController.text);
      } else if (_type == 'password-reset') {
        // Chuyển đến trang reset password với OTP
        context.go('/reset-password', extra: {
          'email': _email,
          'otp': _otpController.text,
        });
        return;
      } else {
        setState(() => _error = 'Loại xác thực không hợp lệ');
        return;
      }

      if (!mounted) return;

      setState(() => _loading = false);

      if (response['success']) {
        if (_type == 'registration') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xác thực thành công! Bạn có thể đăng nhập.')),
          );
          context.go('/login');
        }
      } else {
        setState(() => _error = response['message'] ?? 'Xác thực thất bại');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận OTP'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nhập mã OTP',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Chúng tôi đã gửi mã xác thực đến email: ${_email ?? ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: theme.colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),

                TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'Mã OTP',
                    hintText: 'Nhập 6 chữ số',
                    prefixIcon: Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: _validateOTP,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                
                FilledButton(
                  onPressed: _loading ? null : _verifyOTP,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Xác nhận'),
                ),
                
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Quay lại đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
