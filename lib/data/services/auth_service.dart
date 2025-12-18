import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';

class AuthService {
  // Ganti IP ini sesuai dengan IP laptop kamu
  static const String baseUrl = 'http://10.0.2.2:8000/api';

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

  Future<Map<String, dynamic>> register(String name, String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'username': username,
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

  Future<bool> checkUsername(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-username'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['available'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
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
        Uri.parse('$baseUrl/user'),
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

  Future<Map<String, dynamic>> getUserProfile(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/users/$username'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat profil pengguna',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getUserProfileById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/users/id/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat profil pengguna',
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

  Future<Map<String, dynamic>> sendVerificationEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/email/verification-notification'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Email verifikasi dikirim'};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal mengirim email verifikasi'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
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


  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/users?search=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return List<Map<String, dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // --- TAMBAHKAN FUNGSI INI ---
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Pastikan key-nya 'auth_token' (sesuai dengan yang kamu pakai di fungsi login)
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? username,
    String? bio,
    File? avatar,
    File? banner,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      // Gunakan MultipartRequest karena kita kirim FILE
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/me'));
      
      // Header Auth
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Masukkan Data Teks (Hanya kalau diedit)
      if (name != null) request.fields['name'] = name;
      if (username != null) request.fields['username'] = username;
      if (bio != null) request.fields['bio'] = bio;

      // Masukkan File Avatar (Jika ada user pilih foto baru)
      if (avatar != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar', // Harus sesuai nama di Controller Laravel ($request->file('avatar'))
          avatar.path,
        ));
      }

      // Masukkan File Banner (Jika ada user pilih foto baru)
      if (banner != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'banner', // Harus sesuai nama di Controller Laravel
          banner.path,
        ));
      }

      // Kirim Request
      print("📤 Mengirim data update profil...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📥 Response status: ${response.statusCode}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal update profil'};
      }
    } catch (e) {
      print("❌ Error update profile: $e");
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<Map<String, dynamic>> toggleFollow(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'success': false, 'message': 'Silakan login terlebih dahulu'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/follow/$username'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengikuti pengguna',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }
} // <--- Ini kurung tutup class AuthService

