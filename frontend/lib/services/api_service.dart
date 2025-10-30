import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';

class ApiService {
  static String get _baseUrl => apiBaseUrl;

  static String get baseUrl => _baseUrl;  
  static String? _authToken;

  static Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken == null) {
      print('ApiService: _getHeaders() - _authToken is null, attempting to load.');
      await _loadAuthToken();
    }
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      print('ApiService: _getHeaders() - Authorization header added.');
    } else {
      print('ApiService: _getHeaders() - No Authorization header added (token is null).');
    }
    return headers;
  }

  static Future<Map<String, String>> getHeaders() async {
    return await _getHeaders();
  }

  static Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('authToken');
    print('ApiService: _loadAuthToken() - Loaded token: $_authToken');
  }

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    _authToken = token;
    print('ApiService: saveAuthToken() - Token saved.');
  }

  static Future<void> removeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    _authToken = null;
    print('ApiService: removeAuthToken() - Token removed.');
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = await _getHeaders();
    return http.get(url, headers: headers);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = await _getHeaders();
    return http.post(url, headers: headers, body: json.encode(data));
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = await _getHeaders();
    return http.put(url, headers: headers, body: json.encode(data));
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = await _getHeaders();
    return http.patch(url, headers: headers, body: json.encode(data));
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final headers = await _getHeaders();
    return http.delete(url, headers: headers);
  }
}
