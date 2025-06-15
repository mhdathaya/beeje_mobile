import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://beejee.biz.id/api';

  // Mendapatkan token dari shared_preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Mengambil token yang disimpan
  }

  // Menyimpan token ke shared_preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token); // Menyimpan token
  }

  // Menghapus token dari shared_preferences
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Menghapus token
  }

  // Fungsi login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}/login'),  // Add forward slash
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'  // Add this header
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      print('Response data: $data'); // For debugging

      if (response.statusCode == 200 && data != null) {
        final userRole = data['data']?['user']?['role'] ?? '';
        
        // Check if user role is 'user'
        if (userRole != 'user') {
          return {
            'success': false,
            'message': 'Access denied. Only customers can login through this app.',
          };
        }

        final token = data['data']?['token'] ?? '';
        await _saveToken(token);

        return {
          'success': true,
          'user': data['data']?['user'] ?? {},
          'token': token,
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': data?['message'] ?? 'Failed to login',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'An error occurred during login',
      };
    }
  }

  // Fungsi register
  Future<Map<String, dynamic>> register(String name, String email, String password, String phone) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}/register'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
        body: jsonEncode({
          'name': name, 
          'email': email, 
          'password': password, 
          'phone': phone,
          'password_confirmation': password // Tambahkan konfirmasi password
        }),
      );

      final responseData = jsonDecode(response.body);
      
      // Debug print untuk melihat respons dari server
      print('Register response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return responseData;
      } else {
        // Handle berbagai jenis error
        if (responseData.containsKey('errors')) {
          // Jika ada error validasi spesifik
          final errors = responseData['errors'];
          final firstError = errors.entries.first.value;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          } else {
            throw Exception('Validasi gagal: ${errors.toString()}');
          }
        } else if (responseData.containsKey('message')) {
          throw Exception(responseData['message']);
        } else {
          throw Exception('Registrasi gagal dengan kode: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Tangkap error dari http request atau parsing JSON
      if (e is Exception) {
        throw e; // Teruskan exception yang sudah dibuat
      }
      throw Exception('Terjadi kesalahan saat registrasi: $e');
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    final token = await _getToken(); // Mendapatkan token yang tersimpan
    if (token != null) {
      final response = await http.post(
        Uri.parse('${baseUrl}/logout'), // Menambahkan garis miring
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await _removeToken(); // Hapus token setelah logout berhasil
      } else {
        throw Exception('Failed to logout');
      }
    }
  }

  // // Fungsi forgotPassword
  // Future<void> forgotPassword(String email) async {
  //   final response = await http.post(
  //     Uri.parse('${baseUrl}forgot-password'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'email': email}),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to send password reset email');
  //   }
  // }

  // Fungsi resetPassword
  // Future<void> resetPassword(String token, String password) async {
  //   final response = await http.post(
  //     Uri.parse('${baseUrl}reset-password'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'token': token, 'password': password}),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to reset password');
  //   }
  // }

  // Fetch user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('User not logged in');
      }
  
      final response = await http.get(
        Uri.parse('${baseUrl}/user'), // Menambahkan forward slash
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true' // Menambahkan header untuk ngrok
        },
      );
  
      print('Profile Response: ${response.body}'); // Debug print
  
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Check if the response contains user data directly
        if (responseData.containsKey('user')) {
          return responseData['user'];
        }
        
        // Check if the response follows the success/data format
        if (responseData['success'] == true) {
          if (responseData['data'] != null) {
            return responseData['data'];
          }
          if (responseData['user'] != null) {
            return responseData['user'];
          }
        }
        
        // If we have user data directly in responseData
        if (responseData.containsKey('id') && 
            responseData.containsKey('name') && 
            responseData.containsKey('email')) {
          return responseData;
        }
  
        throw Exception('User data not found in response');
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('GetUserProfile error: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updatedProfile) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await http.put(
      Uri.parse('${baseUrl}user'), // Ensure this endpoint is correct
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Ensure token is included
      },
      body: jsonEncode(updatedProfile),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception('Failed to update user profile: ${errorData['message']}');
    }
  }
}
