import 'dart:convert';
import 'api_service.dart';

class PharmacistService {
  // Category Management
  static Future<Map<String, dynamic>> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await ApiService.post('pharmacist/categories', categoryData);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi tạo danh mục: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCategories({int page = 1, int limit = 10}) async {
    try {
      final response = await ApiService.get('pharmacist/categories?page=$page&limit=$limit');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách danh mục: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateCategory(String categoryId, Map<String, dynamic> updateData) async {
    try {
      final response = await ApiService.put('pharmacist/categories/$categoryId', updateData);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật danh mục: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteCategory(String categoryId) async {
    try {
      final response = await ApiService.delete('pharmacist/categories/$categoryId');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi xóa danh mục: $e'};
    }
  }

  // Product Management
  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await ApiService.post('pharmacist/products', productData);
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
      String url = 'pharmacist/products?page=$page&limit=$limit';
      
      if (category != null) url += '&category=$category';
      if (search != null) url += '&search=$search';
      
      final response = await ApiService.get(url);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy danh sách sản phẩm: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> updateData) async {
    try {
      final response = await ApiService.put('pharmacist/products/$productId', updateData);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi cập nhật sản phẩm: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final response = await ApiService.delete('pharmacist/products/$productId');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi xóa sản phẩm: $e'};
    }
  }

  // QR Code Validation
  static Future<Map<String, dynamic>> validateQRCode(String qrCode) async {
    try {
      final response = await ApiService.post('pharmacist/validate-qr', {'qrCode': qrCode});
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi kiểm tra mã QR: $e'};
    }
  }

  // Data Synchronization
  static Future<Map<String, dynamic>> syncDrugData(String source) async {
    try {
      final response = await ApiService.post('pharmacist/sync-data', {'source': source});
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi đồng bộ dữ liệu: $e'};
    }
  }

  // Inventory Management
  static Future<Map<String, dynamic>> updateInventory(String productId, Map<String, dynamic> inventoryData) async {
    try {
      final response = await ApiService.put('pharmacist/products/$productId/inventory', inventoryData);
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
      String url = 'pharmacist/stats/bestselling?period=$period';
      
      if (category != null) url += '&category=$category';
      
      final response = await ApiService.get(url);
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy thống kê: $e'};
    }
  }

  // Dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await ApiService.get('pharmacist/dashboard');
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi khi lấy dashboard: $e'};
    }
  }
}