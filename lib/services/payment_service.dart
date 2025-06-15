import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static const String baseUrl = 'https://6e8e-36-85-111-43.ngrok-free.app/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> createPayment(String orderId, String paymentMethod) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/pay'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'payment_method': paymentMethod,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseData['data'];
      } else {
        throw Exception(responseData['message'] ?? 'Payment creation failed');
      }
    } catch (e) {
      throw Exception('Payment creation failed: $e');
    }
  }
}