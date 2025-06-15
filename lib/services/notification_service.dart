import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';

class NotificationService {
  final String baseUrl = 'http://beejee.biz.id/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Mendapatkan semua notifikasi dengan pagination
  Future<PaginatedNotifications> getNotifications({
    String? type,
    bool? isRead,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (type != null) queryParams['type'] = type;
      if (isRead != null) queryParams['is_read'] = isRead.toString();

      final uri = Uri.parse('$baseUrl/notifications').replace(queryParameters: queryParams);
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

        if (jsonData['status'] == true && jsonData['data'] != null) {
          return PaginatedNotifications.fromJson(jsonData['data']);
        } else {
          throw Exception('Invalid notification data format');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getNotifications: $e');
      throw Exception('Failed to load notifications');
    }
  }

  // Mendapatkan jumlah notifikasi yang belum dibaca
  Future<int> getUnreadCount() async {
    try {
      final uri = Uri.parse('$baseUrl/notifications/unread-count');
      final token = await _getToken();

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['status'] == true && jsonData['data'] != null) {
          return jsonData['data']['unread_count'];
        } else {
          throw Exception('Invalid unread count data format');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUnreadCount: $e');
      throw Exception('Failed to load unread count');
    }
  }

  // Menandai notifikasi sebagai telah dibaca
  Future<bool> markAsRead(int notificationId) async {
    try {
      final uri = Uri.parse('$baseUrl/notifications/$notificationId/read');
      final token = await _getToken();

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['status'] == true;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in markAsRead: $e');
      throw Exception('Failed to mark notification as read');
    }
  }

  // Menandai semua notifikasi sebagai telah dibaca
  Future<bool> markAllAsRead() async {
    try {
      final uri = Uri.parse('$baseUrl/notifications/mark-all-read');
      final token = await _getToken();

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['status'] == true;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in markAllAsRead: $e');
      throw Exception('Failed to mark all notifications as read');
    }
  }

  // Menghapus notifikasi
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final uri = Uri.parse('$baseUrl/notifications/$notificationId');
      final token = await _getToken();

      final response = await http.delete(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['status'] == true;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteNotification: $e');
      throw Exception('Failed to delete notification');
    }
  }
}