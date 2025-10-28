import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AdminService {
  static const String baseUrl = ApiService.baseUrl;
  
  // Dashboard & Statistics
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy dashboard: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> getStatistics({String period = 'month'}) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/statistics?period=$period'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy thống kê: $e'};
    }
  }
  
  // User Management
  static Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 10,
    String? role,
    bool? emailVerified,
    bool? phoneVerified,
  }) async {
    try {
      final token = await ApiService.getToken();
      String url = '$baseUrl/admin/users?page=$page&limit=$limit';
      
      if (role != null) url += '&role=$role';
      if (emailVerified != null) url += '&emailVerified=$emailVerified';
      if (phoneVerified != null) url += '&phoneVerified=$phoneVerified';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách người dùng: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy thông tin người dùng: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> updateData) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật người dùng: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi xóa người dùng: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> lockUser(String userId, String reason) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId/lock'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'reason': reason}),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi khóa người dùng: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> unlockUser(String userId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId/unlock'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi mở khóa người dùng: $e'};
    }
  }
  
  // Doctor Approval
  static Future<Map<String, dynamic>> getPendingDoctors() async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/doctors/pending'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách bác sĩ chờ duyệt: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> approveDoctor(String doctorId, Map<String, dynamic> approvalData) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/doctors/$doctorId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(approvalData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi duyệt bác sĩ: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> rejectDoctor(String doctorId, String reason) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/doctors/$doctorId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'reason': reason}),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi từ chối bác sĩ: $e'};
    }
  }
  
  // Product Monitoring
  static Future<Map<String, dynamic>> getProductsForReview({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/products/review?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy sản phẩm chờ duyệt: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> approveProduct(String productId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/products/$productId/approve'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi duyệt sản phẩm: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> rejectProduct(String productId, String reason) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/products/$productId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'reason': reason}),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi từ chối sản phẩm: $e'};
    }
  }
  
  // Article Management
  static Future<Map<String, dynamic>> createArticle(Map<String, dynamic> articleData) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/articles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(articleData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi tạo bài viết: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> getArticles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/articles?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách bài viết: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> updateArticle(String articleId, Map<String, dynamic> updateData) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/articles/$articleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật bài viết: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> deleteArticle(String articleId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/articles/$articleId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi xóa bài viết: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> toggleArticleVisibility(String articleId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/articles/$articleId/toggle'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi thay đổi trạng thái bài viết: $e'};
    }
  }
  
  // Report Management
  static Future<Map<String, dynamic>> getReports({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/reports?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách báo cáo: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> handleReport(String reportId, Map<String, dynamic> handleData) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/reports/$reportId/handle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(handleData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi xử lý báo cáo: $e'};
    }
  }
  
  // System Configuration
  static Future<Map<String, dynamic>> getSystemConfig() async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/config'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy cấu hình hệ thống: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> updateSystemConfig(Map<String, dynamic> configData) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/config'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(configData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật cấu hình hệ thống: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> getRoles() async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/roles'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách vai trò: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> updateRolePermissions(String roleId, List<String> permissions) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/roles/$roleId/permissions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'permissions': permissions}),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật quyền vai trò: $e'};
    }
  }
}
