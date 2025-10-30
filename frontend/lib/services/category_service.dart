
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class CategoryService {

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/categories/test'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['docs'] ?? [];
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
