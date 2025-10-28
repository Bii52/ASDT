import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../features/chat/models/conversation.dart';

class ChatService {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else {
      return 'http://192.168.100.191:5000/api';
    }
  }
  
  static String? _authToken;

  static Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken == null) {
      await _loadAuthToken();
    }
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  static Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('authToken');
  }

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    _authToken = token;
  }

  static Future<void> removeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    _authToken = null;
  }

  /// Lấy danh sách cuộc trò chuyện của user
  static Future<List<Conversation>> getConversations() async {
    try {
      final url = Uri.parse('$_baseUrl/chat/conversations');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Conversation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting conversations: $e');
    }
  }

  /// Lấy tin nhắn trong một cuộc trò chuyện
  static Future<List<Message>> getMessages(String conversationId) async {
    try {
      final url = Uri.parse('$_baseUrl/chat/conversations/$conversationId/messages');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting messages: $e');
    }
  }

  /// Gửi tin nhắn
  static Future<Message> sendMessage(String recipientId, String content) async {
    try {
      final url = Uri.parse('$_baseUrl/chat/messages');
      final headers = await _getHeaders();
      
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'recipientId': recipientId,
          'content': content,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Message.fromJson(data);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}
