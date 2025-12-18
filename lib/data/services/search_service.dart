import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SearchService {
  static const String _baseUrl = AuthService.baseUrl; 

  Future<List<Map<String, dynamic>>> searchPosts(String query) async {
    final token = await AuthService().getToken();
    
    final response = await http.get(
      Uri.parse('$_baseUrl/search/posts?q=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse['data']);
    } else {
      throw Exception('Gagal mencari postingan');
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final token = await AuthService().getToken();
    
    final response = await http.get(
      Uri.parse('$_baseUrl/search/users?q=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse['data']);
    } else {
      throw Exception('Gagal mencari pengguna');
    }
  }
}