import 'dart:convert';
import 'api_service.dart';

class AdminService {
  // Dashboard & Statistics
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await ApiService.get('admin/dashboard');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy dashboard: $e'};
    }
  }

  static Future<Map<String, dynamic>> getStatistics({String period = 'month'}) async {
    try {
      final response = await ApiService.get('admin/statistics?period=$period');
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
    bool? isLocked,
    String? q,
  }) async {
    try {
      String url = 'admin/users?page=$page&limit=$limit';
      
      if (role != null) url += '&role=$role';
      if (emailVerified != null) url += '&emailVerified=$emailVerified';
      if (phoneVerified != null) url += '&phoneVerified=$phoneVerified';
      if (isLocked != null) url += '&isLocked=$isLocked';
      if (q != null && q.isNotEmpty) url += '&q=${Uri.encodeQueryComponent(q)}';
      
      final response = await ApiService.get(url);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách người dùng: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await ApiService.get('admin/users/$userId');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy thông tin người dùng: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> updateData) async {
    try {
      final response = await ApiService.put('admin/users/$userId', updateData);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật người dùng: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await ApiService.delete('admin/users/$userId');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi xóa người dùng: $e'};
    }
  }

  static Future<Map<String, dynamic>> lockUser(String userId, String reason) async {
    try {
      final response = await ApiService.put('admin/users/$userId/lock', {'reason': reason});
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi khóa người dùng: $e'};
    }
  }

  static Future<Map<String, dynamic>> unlockUser(String userId) async {
    try {
      final response = await ApiService.put('admin/users/$userId/unlock', {});
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi mở khóa người dùng: $e'};
    }
  }

  // Doctor Approval
  static Future<Map<String, dynamic>> getPendingDoctors() async {
    try {
      final response = await ApiService.get('admin/doctors/pending');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách bác sĩ chờ duyệt: $e'};
    }
  }

  static Future<Map<String, dynamic>> approveDoctor(String doctorId, Map<String, dynamic> approvalData) async {
    try {
      final response = await ApiService.put('admin/doctors/$doctorId/approve', approvalData);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi duyệt bác sĩ: $e'};
    }
  }

  static Future<Map<String, dynamic>> rejectDoctor(String doctorId, String reason) async {
    try {
      final response = await ApiService.put('admin/doctors/$doctorId/reject', {'reason': reason});
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi từ chối bác sĩ: $e'};
    }
  }

  // Create Doctor directly (auto-approved on backend)
  static Future<Map<String, dynamic>> createDoctor(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('admin/doctors', data);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi thêm bác sĩ: $e'};
    }
  }

  // Product Monitoring
  static Future<Map<String, dynamic>> getProductsForReview({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.get('admin/products/review?page=$page&limit=$limit');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy sản phẩm chờ duyệt: $e'};
    }
  }

  static Future<Map<String, dynamic>> approveProduct(String productId) async {
    try {
      final response = await ApiService.put('admin/products/$productId/approve', {});
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi duyệt sản phẩm: $e'};
    }
  }

  static Future<Map<String, dynamic>> rejectProduct(String productId, String reason) async {
    try {
      final response = await ApiService.put('admin/products/$productId/reject', {'reason': reason});
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi từ chối sản phẩm: $e'};
    }
  }

  // Article Management
  static Future<Map<String, dynamic>> createArticle(Map<String, dynamic> articleData) async {
    try {
      final response = await ApiService.post('admin/articles', articleData);
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
      final response = await ApiService.get('admin/articles?page=$page&limit=$limit');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách bài viết: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateArticle(String articleId, Map<String, dynamic> updateData) async {
    try {
      final response = await ApiService.put('admin/articles/$articleId', updateData);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật bài viết: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteArticle(String articleId) async {
    try {
      final response = await ApiService.delete('admin/articles/$articleId');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi xóa bài viết: $e'};
    }
  }

  static Future<Map<String, dynamic>> toggleArticleVisibility(String articleId) async {
    try {
      final response = await ApiService.put('admin/articles/$articleId/toggle', {});
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
      final response = await ApiService.get('admin/reports?page=$page&limit=$limit');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách báo cáo: $e'};
    }
  }

  static Future<Map<String, dynamic>> handleReport(String reportId, Map<String, dynamic> handleData) async {
    try {
      final response = await ApiService.put('admin/reports/$reportId/handle', handleData);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi xử lý báo cáo: $e'};
    }
  }

  // System Configuration
  static Future<Map<String, dynamic>> getSystemConfig() async {
    try {
      final response = await ApiService.get('admin/config');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy cấu hình hệ thống: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateSystemConfig(Map<String, dynamic> configData) async {
    try {
      final response = await ApiService.put('admin/config', configData);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật cấu hình hệ thống: $e'};
    }
  }

  static Future<Map<String, dynamic>> getRoles() async {
    try {
      final response = await ApiService.get('admin/roles');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách vai trò: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateRolePermissions(String roleId, List<String> permissions) async {
    try {
      final response = await ApiService.put('admin/roles/$roleId/permissions', {'permissions': permissions});
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật quyền vai trò: $e'};
    }
  }
}