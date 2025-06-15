import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class PromoService {
  final String baseUrl = 'http://beejee.biz.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<PaginatedProducts> getPromos({
    String? category,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      final Map<String, String> queryParams = {
        if (category != null && category != 'Semua') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      final uri = Uri.parse('$baseUrl/promos').replace(queryParameters: queryParams);
      final token = await _getToken();

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('Promo API Response: ${response.body}');

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final paginatedData = jsonData['data'];
          return PaginatedProducts.fromJson(paginatedData);
        } else {
          throw Exception('Invalid promo data format');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPromos: $e');
      throw Exception('Failed to load promos');
    }
  }

  Future<Product> getPromo(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/promos/$id');
      final token = await _getToken();

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Product.fromJson(jsonData['data']);
        } else {
          throw Exception('Invalid promo data received');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPromo: $e');
      throw Exception('Failed to load promo');
    }
  }

  // Future<List<String>> getCategories() async {
  //   try {
  //     final token = await _getToken();

  //     final response = await http.get(
  //       Uri.parse('$baseUrl/promos/categories'),
  //       headers: {
  //         'Accept': 'application/json',
  //         'Content-Type': 'application/json',
  //         if (token != null) 'Authorization': 'Bearer $token',
  //       },
  //     ).timeout(const Duration(seconds: 10));

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonData = json.decode(response.body);

  //       if (jsonData['success'] == true && jsonData['data'] != null) {
  //         final List<dynamic> categoriesData = jsonData['data'];
  //         return categoriesData.map((category) => category.toString()).toList();
  //       }
  //     }

  //     print('Categories response: ${response.body}');
  //     return [];
  //   } catch (e) {
  //     print('Error in getCategories: $e');
  //     return [];
  //   }
  // }
}