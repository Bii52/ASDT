import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PharmacistService {
  static const String baseUrl = ApiService.baseUrl;
  
  // Category Management
  static Future<Map<String, dynamic>> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/pharmacist/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(categoryData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi tạo danh mục: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> getCategories({int page = 1, int limit = 10}) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/pharmacist/categories?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách danh mục: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> updateCategory(String categoryId, Map<String, dynamic> updateData) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/pharmacist/categories/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật danh mục: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> deleteCategory(String categoryId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/pharmacist/categories/$categoryId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi xóa danh mục: $e'};
    }
  }
  
  // Product Management
  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/pharmacist/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(productData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi tạo sản phẩm: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    try {
      final token = await ApiService.getToken();
      String url = '$baseUrl/pharmacist/products?page=$page&limit=$limit';
      
      if (category != null) url += '&category=$category';
      if (search != null) url += '&search=$search';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách sản phẩm: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> updateData) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/pharmacist/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật sản phẩm: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/pharmacist/products/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi xóa sản phẩm: $e'};
    }
  }
  
  // QR Code Validation
  static Future<Map<String, dynamic>> validateQRCode(String qrCode) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/pharmacist/validate-qr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'qrCode': qrCode}),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi kiểm tra mã QR: $e'};
    }
  }
  
  // Data Synchronization
  static Future<Map<String, dynamic>> syncDrugData(String source) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/pharmacist/sync-data'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'source': source}),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi đồng bộ dữ liệu: $e'};
    }
  }
  
  // Inventory Management
  static Future<Map<String, dynamic>> updateInventory(String productId, Map<String, dynamic> inventoryData) async {
    try {
      final token = await ApiService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/pharmacist/products/$productId/inventory'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(inventoryData),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật tồn kho: $e'};
    }
  }
  
  // Statistics
  static Future<Map<String, dynamic>> getBestsellingStats({
    String period = 'month',
    String? category,
  }) async {
    try {
      final token = await ApiService.getToken();
      String url = '$baseUrl/pharmacist/stats/bestselling?period=$period';
      
      if (category != null) url += '&category=$category';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy thống kê: $e'};
    }
  }
  
  // Dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/pharmacist/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy dashboard: $e'};
    }
  }
}
