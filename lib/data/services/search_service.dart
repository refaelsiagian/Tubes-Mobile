import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Pastikan path ini benar sesuai struktur foldermu

class SearchService {
  // Ganti dengan URL IP kamu
  final String _baseUrl = 'http://10.0.2.2:8000/api'; 

  Future<List<Map<String, dynamic>>> searchPosts(String query) async {
    final token = await AuthService().getToken();
    
    // Panggil endpoint /search/posts?q=...
    final response = await http.get(
      Uri.parse('$_baseUrl/search/posts?q=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Backend mengembalikan { "data": [...] }, jadi kita ambil 'data'-nya saja
      return List<Map<String, dynamic>>.from(jsonResponse['data']);
    } else {
      throw Exception('Gagal mencari postingan');
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final token = await AuthService().getToken();
    
    // Panggil endpoint /search/users?q=...
    final response = await http.get(
      Uri.parse('$_baseUrl/search/users?q=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Ambil 'data' dari response pagination
      return List<Map<String, dynamic>>.from(jsonResponse['data']);
    } else {
      throw Exception('Gagal mencari pengguna');
    }
  }
}