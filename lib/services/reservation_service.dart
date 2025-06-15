import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservationService {
  static const String baseUrl = 'http://beejee.biz.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<String>> getAvailableTimeSlots(DateTime date) async {
    try {
      // Modify date validation to allow current date
      final today = DateTime.now();
      final selectedDate = DateTime(date.year, date.month, date.day);
      final compareDate = DateTime(today.year, today.month, today.day);
      
      if (selectedDate.isBefore(compareDate)) {
        throw Exception('Please select today or a future date');
      }

      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/reservations/time-slots?date=${date.toIso8601String().split('T')[0]}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Time slots response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Match the exact backend response structure
        if (data['success'] == true && 
            data['data'] != null && 
            data['data']['time_slots'] != null) {
          return List<String>.from(data['data']['time_slots']);
        } else {
          print('Invalid response structure: ${data}');
          return [];
        }
      } else {
        // Handle non-200 status codes
        final data = jsonDecode(response.body);
        final errorMessage = data['message'] ?? 'Failed to load time slots';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error getting time slots: $e');
      return []; // Return empty list on error
    }
  }

  Future<Map<String, dynamic>> createReservation({
    required DateTime reservationDate,
    required String reservationTime,
    required int peopleCount,
    required String notes,
    required String paymentMethod,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Single date validation that allows current date
      final today = DateTime.now();
      final selectedDate = DateTime(reservationDate.year, reservationDate.month, reservationDate.day);
      final compareDate = DateTime(today.year, today.month, today.day);
      
      if (selectedDate.isBefore(compareDate)) {
        throw Exception('Please select today or a future date');
      }

      final requestBody = {
        'reservation_date': reservationDate.toIso8601String().split('T')[0],
        'reservation_time': reservationTime,
        'people_count': peopleCount,
        'notes': notes,
        'payment_method': paymentMethod,
      };

      print('Reservation request body: ${jsonEncode(requestBody)}'); // Debug print

      final response = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('Reservation response: ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'];
        }
      }

      // Better error handling
      if (responseData['message'] != null) {
        throw Exception(responseData['message']);
      } else if (responseData['errors'] != null) {
        final firstError = (responseData['errors'] as Map).values.first;
        throw Exception(firstError is List ? firstError.first : firstError.toString());
      }
      
      throw Exception('Failed to create reservation');
    } catch (e) {
      print('Reservation creation error: $e');
      rethrow;
    }
  }
}
