import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'api_service.dart';

class ProductService {
  static const String _baseUrl = kIsWeb ? 'http://192.168.1.19:5000/api' : 'http://192.168.1.19:5000/api';

  static Future<Map<String, dynamic>> _handleApiResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 500) {
      try {
        final data = jsonDecode(response.body);
        return {
          'success': response.statusCode >= 200 && response.statusCode < 300,
          'data': data,
          'message': data['message'] ?? 'Success'
        };
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid JSON response from server'
        };
      }
    }
    return {
      'success': false,
      'message': 'Server error. Please try again later.',
    };
  }

  static Future<Map<String, dynamic>> getProducts({
    String? name,
    String? category,
    String? sortBy,
    int? limit,
    int? page,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (page != null) queryParams['page'] = page.toString();

      final uri = Uri.parse('$_baseUrl/products/test').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: await ApiService.getHeaders(),
      ).timeout(const Duration(seconds: 10));

      return await _handleApiResponse(response);
    } catch (e) {
      debugPrint('Get products error: $e');
      return {'success': false, 'message': 'Failed to load products: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProduct(String productId) async {
    try {
      final response = await ApiService.get('products/$productId');
      return await _handleApiResponse(response);
    } catch (e) {
      debugPrint('Get product error: $e');
      return {'success': false, 'message': 'Failed to load product: $e'};
    }
  }

  static Future<Map<String, dynamic>> createProduct(Map<String, dynamic> payload) async {
    try {
      final response = await ApiService.post('products', payload);
      return await _handleApiResponse(response);
    } catch (e) {
      debugPrint('Create product error: $e');
      return {'success': false, 'message': 'Failed to create product: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> payload) async {
    try {
      final response = await ApiService.patch('products/$productId', payload);
      return await _handleApiResponse(response);
    } catch (e) {
      debugPrint('Update product error: $e');
      return {'success': false, 'message': 'Failed to update product: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final response = await ApiService.delete('products/$productId');
      return await _handleApiResponse(response);
    } catch (e) {
      debugPrint('Delete product error: $e');
      return {'success': false, 'message': 'Failed to delete product: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories/test'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      return await _handleApiResponse(response);
    } catch (e) {
      debugPrint('Get categories error: $e');
      return {'success': false, 'message': 'Failed to load categories: $e'};
    }
  }

  /// Tìm sản phẩm bằng mã QR
  static Future<Map<String, dynamic>> findProductByQRCode(String qrCode) async {
    try {
      // Endpoint backend là /products/qr/:qrCode
      final response = await ApiService.get('products/qr/$qrCode');
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': decoded};
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Không tìm thấy sản phẩm'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
