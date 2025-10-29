import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_service.dart';

class AppointmentService {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://192.168.100.191:5000/api';
    } else {
      return 'http://192.168.100.191:5000/api';
    }
  }

  static Future<Map<String, dynamic>> _handleApiResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 500) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('success')) {
        return data;
      }
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': data['message'] ?? 'Phản hồi không hợp lệ từ máy chủ.'
      };
    }
    return {
      'success': false,
      'message': 'Lỗi máy chủ. Vui lòng thử lại sau.',
    };
  }

  static Future<Map<String, dynamic>> createAppointment({
    required String doctorId,
    required String date,
    required String startTime,
    required String reason,
  }) async {
    try {
      final response = await ApiService.post('appointments', {
        'doctorId': doctorId,
        'date': date,
        'startTime': startTime,
        'reason': reason,
      });

      return await _handleApiResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã có lỗi xảy ra: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> getAppointments({
    String? status,
    String? date,
  }) async {
    try {
      String endpoint = 'appointments';
      List<String> queryParams = [];
      
      if (status != null) queryParams.add('status=$status');
      if (date != null) queryParams.add('date=$date');
      
      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await ApiService.get(endpoint);
      return await _handleApiResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã có lỗi xảy ra: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> getDoctorAppointments() async {
    try {
      // The backend should filter appointments based on the logged-in doctor's token
      final response = await ApiService.get('appointments');
      return await _handleApiResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã có lỗi xảy ra: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    try {
      final response = await ApiService.put('appointments/$appointmentId/status', {
        'status': status,
      });

      return await _handleApiResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã có lỗi xảy ra: $e'
      };
    }
  }
}
