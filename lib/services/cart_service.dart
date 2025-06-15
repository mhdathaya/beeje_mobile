import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';

class CartService {
  static const String baseUrl = 'http://beejee.biz.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> addToCart(int productId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getToken()}',
      },
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add product to cart');
    }
  }

  Future<List<Cart>> fetchCartItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Authorization': 'Bearer ${await _getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('Cart API Response: ${response.body}'); // Tambahkan log ini
      
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final cartData = jsonResponse['data'];
        if (cartData['items'] != null) {
          final List<dynamic> cartItems = cartData['items'];
          return cartItems.map((json) => Cart.fromJson(json)).toList();
        }
      }
      return [];
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> updateCartItem(int cartId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart/$cartId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getToken()}',
      },
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart item');
    }
  }

  Future<void> deleteCartItem(int cartId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$cartId'),
      headers: {
        'Authorization': 'Bearer ${await _getToken()}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete cart item');
    }
  }

  Future<void> clearCart() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
  
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/clear'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
  
      final responseData = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(responseData['message'] ?? 'Failed to clear cart: ${response.statusCode}');
      }
    } catch (e) {
      print('Clear cart error: $e');
      if (e is FormatException) {
        throw Exception('Failed to clear cart: Invalid response format');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkout({
    required String type,
    required String paymentMethod,
    String? address,
    String? recipientName,
    String? recipientPhone,
    String? deliveryNotes,
    String? reservationDate,
    String? reservationTime,
    int? numberOfPeople,
    // Raja Ongkir specific fields
    String? originCity,
    String? destinationCity,
    String? courier,
    String? service,
    double? shippingCost,
    int? weight,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
  
      // Validate required fields based on type
      if (type == 'delivery') {
        if (address == null || address.isEmpty) {
          throw Exception('Address is required for delivery orders');
        }
        if (recipientName == null || recipientName.isEmpty) {
          throw Exception('Recipient name is required for delivery orders');
        }
        if (recipientPhone == null || recipientPhone.isEmpty) {
          throw Exception('Recipient phone is required for delivery orders');
        }
        // Validate Raja Ongkir fields
        if (originCity == null || originCity.isEmpty) {
          throw Exception('Origin city is required for delivery orders');
        }
        if (destinationCity == null || destinationCity.isEmpty) {
          throw Exception('Destination city is required for delivery orders');
        }
        if (courier == null || courier.isEmpty) {
          throw Exception('Courier is required for delivery orders');
        }
        if (service == null || service.isEmpty) {
          throw Exception('Service is required for delivery orders');
        }
        if (shippingCost == null || shippingCost <= 0) {
          throw Exception('Valid shipping cost is required for delivery orders');
        }
        if (weight == null || weight <= 0) {
          throw Exception('Valid weight is required for delivery orders');
        }
        
        // Verify shipping cost with Raja Ongkir
        final shippingVerification = await _verifyShippingCost(
          originCity,
          destinationCity,
          weight,
          courier,
          service,
          shippingCost
        );
        
        if (!shippingVerification['verified']) {
          throw Exception(shippingVerification['message']);
        }
      } else if (type == 'reservation') {
        if (reservationDate == null || reservationDate.isEmpty) {
          throw Exception('Reservation date is required');
        }
        if (reservationTime == null || reservationTime.isEmpty) {
          throw Exception('Reservation time is required');
        }
        if (numberOfPeople == null || numberOfPeople < 1) {
          throw Exception('Valid number of people is required');
        }
      } else {
        throw Exception('Invalid order type');
      }
  
      // Update valid payment methods to match backend's PAYMENT_METHODS constant
      final validPaymentMethods = [
        'credit_card',
        'bank_transfer',
        'gopay',
        'shopeepay',
        'qris'
      ];
      if (!validPaymentMethods.contains(paymentMethod)) {
        throw Exception('The selected payment method is invalid');
      }
  
      final requestBody = {
        'type': type,
        'payment_method': paymentMethod,
        if (type == 'reservation') ...{
          'reservation_date': reservationDate,
          'reservation_time': reservationTime,
          'number_of_people': numberOfPeople,
        }
        else if (type == 'delivery') ...{
          'address': address,
          'recipient_name': recipientName,
          'recipient_phone': recipientPhone,
          'delivery_notes': deliveryNotes,
          'origin_city': originCity,
          'destination_city': destinationCity,
          'courier': courier,
          'service': service,
          'shipping_cost': shippingCost,
          'weight': weight,
        },
      };
  
      final response = await http.post(
        Uri.parse('$baseUrl/cart/checkout'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (responseData['status'] == true && responseData['data'] != null) {
          final orderData = responseData['data'];
          if (orderData['order'] != null && orderData['order']['payment_url'] != null) {
            return {
              'payment_url': orderData['order']['payment_url'],
              'order_id': orderData['order']['order_number'],
              'status': orderData['order']['status'],
            };
          }
        }
      }

      // If we reach here, something went wrong
      throw Exception(responseData['message'] ?? responseData['data']?['message'] ?? 'Checkout failed: Invalid response format');
    } catch (e) {
      print('Checkout error: $e');
      rethrow;
    }
  }
  
  // Method to verify shipping cost with Raja Ongkir
  Future<Map<String, dynamic>> _verifyShippingCost(
    String origin,
    String destination,
    int weight,
    String courier,
    String service,
    double userShippingCost
  ) async {
    try {
      // Log the request parameters for debugging
      print('RajaOngkir API Request: $origin, $destination, $weight, $courier, $service, $userShippingCost');
      
      // Check if API key is configured
      final apiKey = await _getRajaOngkirApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        print('RajaOngkir API key is not configured');
        return {
          'verified': true, // Temporarily allow to proceed if API key is missing
          'message': 'Shipping cost verification skipped (API key not configured)'
        };
      }
      
      // Make API request to Raja Ongkir to verify shipping cost
      final response = await http.post(
        Uri.parse('https://api.rajaongkir.com/starter/cost'),
        headers: {
          'key': apiKey,
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'origin': origin,
          'destination': destination,
          'weight': weight,
          'courier': courier,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['rajaongkir']['results'];
        
        if (results != null && results.isNotEmpty) {
          final courierData = results[0];
          final costs = courierData['costs'];
          
          // Find the matching service
          for (var cost in costs) {
            if (cost['service'] == service) {
              final costValue = cost['cost'][0]['value'];
              final difference = (costValue - userShippingCost).abs();
              
              // Allow a small tolerance (e.g., 1000 IDR)
              if (difference <= 1000) {
                return {
                  'verified': true,
                  'message': 'Shipping cost verified'
                };
              } else {
                return {
                  'verified': false,
                  'message': 'Shipping cost mismatch: expected $costValue, got $userShippingCost'
                };
              }
            }
          }
          
          return {
            'verified': false,
            'message': 'Service $service not found for courier $courier'
          };
        }
      }
      
      // If API call fails, temporarily allow to proceed
      return {
        'verified': true,
        'message': 'Shipping cost verification skipped (API error)'
      };
    } catch (e) {
      print('Shipping cost verification error: $e');
      // In case of error, temporarily allow to proceed
      return {
        'verified': true,
        'message': 'Shipping cost verification skipped (Error: $e)'
      };
    }
  }
  
  // Helper method to get Raja Ongkir API key from shared preferences or environment
  Future<String?> _getRajaOngkirApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('rajaongkir_api_key');
  }
}