import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'chat_socket_service.dart'; 

class UserService {
  // Sử dụng ApiService để có cấu hình thống nhất

  static Future<Map<String, dynamic>> _handleApiResponse(http.Response response) async {
    // Nếu thành công (2xx) hoặc lỗi client (4xx) thì có body JSON
    if (response.statusCode >= 200 && response.statusCode < 500) {
      final data = jsonDecode(response.body);
      // Giả sử backend luôn trả về 'success': true/false
      if (data is Map<String, dynamic> && data.containsKey('success')) {
        return data;
      }
      // Nếu không có 'success', tự tạo dựa trên status code
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': data['message'] ?? 'Phản hồi không hợp lệ từ máy chủ.'
      };
    }
    // Lỗi server (5xx)
    return {
      'success': false,
      'message': 'Lỗi máy chủ. Vui lòng thử lại sau.',
    };
  }

  static Future<Map<String, dynamic>> uploadAvatar(XFile image) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/upload/avatar'),
      );

      final headers = await ApiService.getHeaders();
      request.headers.addAll(headers);

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'avatar', // This must match the fieldName in backend's uploadImage middleware
          bytes,
          filename: image.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar', // This must match the fieldName in backend's uploadImage middleware
          image.path,
          filename: image.name,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return await _handleApiResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Could not connect to the server.'};
    } catch (e) {
      debugPrint('Upload avatar error: $e');
      return {'success': false, 'message': 'An error occurred during avatar upload. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      final data = await _handleApiResponse(response);

      if (data['success'] == true && data['accessToken'] != null) {
        // Lưu token khi đăng nhập thành công
        await ApiService.saveAuthToken(data['accessToken']);
        // Cũng lưu refresh token nếu có
        if (data['refreshToken'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('refreshToken', data['refreshToken']);
        }
      }

      return data;
    } on SocketException {
      return {'success': false, 'message': 'Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng.'};
    } catch (e) {
      debugPrint('Login error: $e');
      return {'success': false, 'message': 'Đã có lỗi xảy ra. Vui lòng thử lại.'};
    }
  }

  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await ApiService.post('auth/register', {
        'email': email,
        'password': password,
        'fullName': name,
      });

      return await _handleApiResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng.'};
    } catch (e) {
      debugPrint('Register error: $e');
      return {'success': false, 'message': 'Đã có lỗi xảy ra. Vui lòng thử lại.'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    print('UserService: logout() called (local token removal only).');
    try {
      await ApiService.removeAuthToken();
      print('UserService: Auth token removed locally.');
      // Always return success to ensure navigation to login page
      return {'success': true, 'message': 'Đăng xuất thành công (local).',};
    } catch (e) {
      print('UserService: Logout error (local): $e');
      // Even if local removal fails, we might still want to navigate
      return {'success': true, 'message': 'Đăng xuất thất bại cục bộ nhưng vẫn chuyển hướng.',};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await ApiService.get('auth/me');
      return await _handleApiResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Không thể kết nối tới máy chủ.'};
    } catch (e) {
      return {'success': false, 'message': 'Đã có lỗi xảy ra: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyRegistration(String email, String otp) async {
    try {
      final response = await ApiService.post('auth/verify-registration', {
        'email': email,
        'otp': otp,
      });

      return await _handleApiResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Không thể kết nối tới máy chủ.'};
    } catch (e) {
      debugPrint('Verify registration error: $e');
      return {'success': false, 'message': 'Đã có lỗi xảy ra. Vui lòng thử lại.'};
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await ApiService.post('auth/forgot-password', {
        'email': email,
      });

      return await _handleApiResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Không thể kết nối tới máy chủ.'};
    } catch (e) {
      debugPrint('Forgot password error: $e');
      return {'success': false, 'message': 'Đã có lỗi xảy ra. Vui lòng thử lại.'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await ApiService.post('auth/reset-password', {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });

      return await _handleApiResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Không thể kết nối tới máy chủ.'};
    } catch (e) {
      debugPrint('Reset password error: $e');
      return {'success': false, 'message': 'Đã có lỗi xảy ra. Vui lòng thử lại.'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await ApiService.patch('auth/me', profileData);
      return await _handleApiResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Không thể kết nối tới máy chủ.'};
    } catch (e) {
      debugPrint('Update profile error: $e');
      return {'success': false, 'message': 'Đã có lỗi xảy ra. Vui lòng thử lại.'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await ApiService.put('auth/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      return await _handleApiResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Could not connect to the server.'};
    } catch (e) {
      debugPrint('Change password error: $e');
      return {'success': false, 'message': 'An error occurred. Please try again.'};
    }
  }
}
