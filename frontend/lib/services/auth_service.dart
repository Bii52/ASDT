import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/models/user.dart';

// 1. Định nghĩa State cho Auth
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final String? token;

  AuthState({required this.isAuthenticated, this.user, this.token});

  AuthState copyWith({bool? isAuthenticated, User? user, String? token}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }
}

// 2. Tạo Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isAuthenticated: false)) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userJson = prefs.getString('user');

    if (token != null && userJson != null) {
      final user = User.fromJson(json.decode(userJson));
      state = AuthState(isAuthenticated: true, user: user, token: token);
    } else {
      state = AuthState(isAuthenticated: false);
    }
  }

  Future<void> login(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    await prefs.setString('user', json.encode(user.toJson()));
    state = AuthState(isAuthenticated: true, user: user, token: token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('user');
    await prefs.remove('refreshToken'); // Also clear refresh token
    state = AuthState(isAuthenticated: false);
  }
}

// 3. Tạo Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Provider để dễ dàng truy cập vai trò người dùng
final userRoleProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.role;
});
