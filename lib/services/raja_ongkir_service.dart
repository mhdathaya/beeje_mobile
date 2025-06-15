import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/raja_ongkir_models.dart';

class RajaOngkirService {
  // Base URL untuk API Raja Ongkir
  final String baseUrl = 'http://beejee.biz.id/api';
  
  // Mendapatkan API key dari shared preferences
  Future<String?> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Mencari kota tujuan berdasarkan keyword
  Future<List<City>> searchDestination(String search) async {
    try {
      final token = await _getApiKey();
      
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/rajaongkir/cities').replace(
          queryParameters: {
            'search': search,
            'limit': '100',
            'offset': '0'
          },
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      // Debugging: Cetak status code dan response body
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // Handle unauthorized error specifically
      if (response.statusCode == 401) {
        throw Exception('Token tidak valid atau kedaluwarsa. Silakan login kembali.');
      }
      
      // Handle other non-200 status codes
      if (response.statusCode != 200) {
        throw Exception('Gagal mencari kota: ${response.statusCode}');
      }
      
      // Safely parse the JSON response
      try {
        final dynamic decodedData = jsonDecode(response.body);
        
        // Jika respons adalah array kosong, kembalikan list kosong
        if (decodedData is List && decodedData.isEmpty) {
          return [];
        }
        
        // Jika respons adalah list, langsung konversi ke objek City
        if (decodedData is List) {
          return decodedData.map((city) => City.fromJson(city)).toList();
        }
        
        // Jika respons adalah map, periksa struktur yang diharapkan
        if (decodedData is Map<String, dynamic>) {
          // Format baru seperti yang terlihat di gambar
          if (decodedData.containsKey('id') && decodedData.containsKey('label')) {
            return [City.fromJson(decodedData)];
          }
          
          // Jika ada data langsung di root
          if (decodedData['data'] != null && decodedData['data'] is List) {
            final List<dynamic> citiesData = decodedData['data'];
            return citiesData.map((city) => City.fromJson(city)).toList();
          }
          
          // Jika menggunakan format rajaongkir
          if (decodedData['rajaongkir'] != null && 
              decodedData['rajaongkir']['results'] != null && 
              decodedData['rajaongkir']['results'] is List) {
            final List<dynamic> citiesData = decodedData['rajaongkir']['results'];
            return citiesData.map((city) => City.fromJson(city)).toList();
          }
          
          // Jika menggunakan format dengan meta
          if (decodedData['meta'] != null) {
            if (decodedData['meta']['code'] != 200 || decodedData['meta']['status'] != 'success') {
              throw Exception(decodedData['meta']['message'] ?? 'Gagal mencari kota');
            }
            
            if (decodedData['data'] != null && decodedData['data'] is List) {
              final List<dynamic> citiesData = decodedData['data'];
              return citiesData.map((city) => City.fromJson(city)).toList();
            }
          }
        }
        
        // Jika tidak ada format yang cocok
        throw Exception('Format respons tidak didukung');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Format respons tidak valid: ${e.toString()}');
        }
        rethrow;
      }
    } catch (e) {
      print('Error searching destination: $e');
      if (e is FormatException) {
        throw Exception('Format respons tidak valid');
      }
      rethrow;
    }
  }
  
  // Mengecek ongkos kirim
  Future<List<ShippingCost>> checkOngkir({
    required String origin,
    required dynamic destination,  // Ubah dari int ke dynamic untuk menangani string atau int
    required int weight,
    required String courier,
  }) async {
    try {
      final token = await _getApiKey();
      
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan');
      }
      
      // Pastikan destination adalah string
      final String destinationStr = destination is int ? destination.toString() : destination;
      
      final response = await http.post(
        Uri.parse('$baseUrl/rajaongkir/costs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'origin': origin,
          'destination': destinationStr,  // Gunakan string yang sudah dipastikan
          'weight': weight.toString(),
          'courier': courier,
        },
      );
      
      // Debugging: Cetak status code dan response body
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // Handle response berdasarkan format
      final dynamic responseData = jsonDecode(response.body);
      
      // Jika response adalah array langsung (seperti pada contoh error)
      if (responseData is List) {
        // Buat ShippingCost tunggal dengan semua layanan
        return [ShippingCost(
          code: courier,
          name: responseData.isNotEmpty ? responseData.first['name'] ?? '' : '',
          services: responseData.map((service) => ShippingService.fromJson(service)).toList(),
        )];
      }
      
      // Format dengan meta dan data
      if (response.statusCode != 200) {
        // Perbaikan: Periksa apakah responseData dan meta ada sebelum mengakses message
        final errorMessage = responseData != null && responseData['meta'] != null 
            ? responseData['meta']['message'] 
            : 'Gagal mengecek ongkos kirim: ${response.statusCode}';
        throw Exception(errorMessage);
      }
      
      // Perbaikan: Periksa apakah meta ada sebelum mengakses propertinya
      if (responseData is Map && responseData['meta'] == null) {
        throw Exception('Format respons tidak valid: meta tidak ditemukan');
      }
      
      // Perbaikan: Periksa code dan status setelah memastikan meta ada
      if (responseData is Map && responseData['meta'] != null && 
          (responseData['meta']['code'] != 200 || responseData['meta']['status'] != 'success')) {
        throw Exception(responseData['meta']['message'] ?? 'Gagal mengecek ongkos kirim');
      }
      
      if (responseData is Map && responseData['data'] == null) {
        return [];
      }
      
      final List<dynamic> costsData = responseData['data'];
      return costsData.map((cost) => ShippingCost.fromJson(cost)).toList();
    } catch (e) {
      print('Error checking shipping cost: $e');
      if (e is FormatException) {
        throw Exception('Format respons tidak valid');
      }
      rethrow;
    }
  }
}