import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class SeriesService {
  static const String baseUrl = AuthService.baseUrl;

  Future<Map<String, dynamic>> createSeries(String title, String description, List<int> postIds) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/series'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'posts': postIds,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal membuat jilid: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getSeries({int? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    String url = '$baseUrl/series';
    if (userId != null) {
      url += '?user_id=$userId';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
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
  Future<Map<String, dynamic>> getSeriesDetail(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/series/$id'),
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
        return {'success': false, 'message': 'Gagal memuat jilid'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateSeries(int id, String title, String description, List<int> postIds) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/series/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'posts': postIds,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      } else {
        return {'success': false, 'message': 'Gagal memperbarui jilid'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<bool> deleteSeries(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/series/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
