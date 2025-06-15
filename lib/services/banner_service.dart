import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/banner.dart';

class BannerService {
  final String baseUrl = 'http://beejee.biz.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Banner>> getBanners() async {
    try {
      final uri = Uri.parse('$baseUrl/promos/banners');
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
        print('Banner API Response: ${response.body}');

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final BannerResponse bannerResponse = BannerResponse.fromJson(jsonData);
          return bannerResponse.data;
        } else {
          throw Exception('Invalid banner data format');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getBanners: $e');
      return [];
    }
  }
}