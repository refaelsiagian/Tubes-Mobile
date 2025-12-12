import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Ganti IP ini sesuai dengan IP laptop kamu
  static const String baseUrl = 'http://192.168.18.213:8000/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔄 Login: Starting login request...');
      final startTime = DateTime.now();
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Server tidak merespon dalam 10 detik');
        },
      );

      final requestDuration = DateTime.now().difference(startTime);
      print('📡 Login: Request completed in ${requestDuration.inMilliseconds}ms');
      print('📡 Login: Status ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan Token
        print('💾 Login: Saving token...');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        
        final totalDuration = DateTime.now().difference(startTime);
        print('✅ Login: Total time ${totalDuration.inMilliseconds}ms');
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('❌ Login: Failed with status ${response.statusCode}');
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simpan Token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Register gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'], // UserResource bungkus data di key 'data'
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Change email
  Future<Map<String, dynamic>> changeEmail(String newEmail, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse('$baseUrl/user/email'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': newEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Email berhasil diubah'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Gagal mengubah email'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse('$baseUrl/user/password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password berhasil diubah'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Gagal mengubah password'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
