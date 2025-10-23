import 'dart:convert';
import 'package:frontend/core/api_service.dart';
import 'package:http/http.dart' as http;

class UserService {
  static Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await ApiService.post(
      'users/register',
      {'email': email, 'password': password, 'name': name},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.post(
      'users/login',
      {'email': email, 'password': password},
    );
    final responseBody = _handleResponse(response);
    if (response.statusCode == 200 && responseBody['token'] != null) {
      await ApiService.saveAuthToken(responseBody['token']);
    }
    return responseBody;
  }

  static Future<Map<String, dynamic>> logout() async {
    final response = await ApiService.post('users/logout', {});
    if (response.statusCode == 200) {
      await ApiService.removeAuthToken();
    }
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiService.get('users/profile');
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final responseBody = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'success': true, 'data': responseBody};
    } else {
      return {'success': false, 'message': responseBody['message'] ?? 'An error occurred'};
    }
  }
}
