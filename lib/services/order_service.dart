import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static const String baseUrl = 'http://beejee.biz.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> createOrder({
    required String orderMethod,
    required List<Map<String, dynamic>> products,
    String? shippingAddress,
    required String paymentMethod,
    DateTime? reservationDate,
    String? reservationTime,
    int? peopleCount,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final requestBody = {
        'products': products.map((product) => {
          'product_id': product['id'],
          'quantity': product['quantity'],
          'price': product['price'].toString(), // Convert to string to match API
        }).toList(),
        'shipping_address': shippingAddress ?? '',
        'payment_method': paymentMethod,
        'order_method': orderMethod,
        'reservation_date': reservationDate?.toIso8601String().split('T')[0],
        'reservation_time': reservationTime,
        'people_count': peopleCount,
        'notes': notes,
      };

      print('Request Body: $requestBody'); // Debug print

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      print('Response Data: $responseData'); // Debug print

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'];
        }
      }
      
      throw Exception(responseData['message'] ?? 'Failed to create order');
    } catch (e) {
      print('Order creation error: $e'); // For debugging
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }
}