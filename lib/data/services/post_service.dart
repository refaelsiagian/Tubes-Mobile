import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class PostService {
  static const String baseUrl = AuthService.baseUrl;

  // --- HELPER: Ambil Token (Biar kode lebih bersih & tidak berulang) ---
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // --- GET POSTS (Dengan Filter Status) ---
  Future<List<Map<String, dynamic>>> getPosts({
    int? userId,
    String? search,
    String? status, // Fitur Penting untuk Draft/Published
  }) async {
    try {
      final token = await _getToken();
      String url = '$baseUrl/posts';
      List<String> queryParams = [];

      if (userId != null) {
        queryParams.add('user_id=$userId');
      }
      if (search != null && search.isNotEmpty) {
        queryParams.add('search=$search');
      }
      // Parameter status (Penting!)
      if (status != null && status.isNotEmpty) {
        queryParams.add('status=$status');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

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

  Future<Map<String, dynamic>> getPost(int id) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['data']};
      } else {
        return {'success': false, 'message': 'Gagal memuat lembar'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  Future<Map<String, dynamic>> getComments(int postId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['data']};
      } else {
        return {'success': false, 'message': 'Gagal memuat komentar'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  Future<Map<String, dynamic>> postComment(int postId, String content) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Silakan login terlebih dahulu'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)['data']};
      } else {
        return {'success': false, 'message': 'Gagal mengirim komentar'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  Future<Map<String, dynamic>> toggleLike(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'Silakan login'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Gagal menyukai lembar: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ toggleLike error: $e');
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  // --- CREATE POST (Tanpa Visibility, Ada Status) ---
  Future<Map<String, dynamic>> createPost(
    String title,
    String content,
    String status, {
    String? snippet,
    File? thumbnail,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/posts');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['status'] = status;
      if (snippet != null) request.fields['snippet'] = snippet;

      if (thumbnail != null) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', thumbnail.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['data']};
      } else {
        return {
          'success': false,
          'message': 'Gagal membuat postingan: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // --- UPDATE POST (Tanpa Visibility, Ada Status) ---
  Future<Map<String, dynamic>> updatePost(
    int id,
    String? title,
    String? content,
    String? status, {
    String? snippet,
    File? thumbnail,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/posts/$id');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['_method'] = 'PUT'; // Laravel spoofing

      if (title != null) request.fields['title'] = title;
      if (content != null) request.fields['content'] = content;
      if (status != null) request.fields['status'] = status;
      if (snippet != null) request.fields['snippet'] = snippet;

      if (thumbnail != null) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', thumbnail.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['data']};
      } else {
        print('❌ Update Post Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message': 'Gagal memperbarui postingan: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updatePostStatus(int id, String status) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)['data']};
      }
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memperbarui status'
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<bool> deletePost(int id) async {
    final token = await _getToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$id'),
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

  Future<List<Map<String, dynamic>>> getLikedPosts() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me/likes'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // === FITUR BOOKMARK YANG DIPERBAIKI ===

  // 1. Ambil List Bookmark
  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookmarks'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null) {
           final List data = jsonResponse['data'];
           return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } catch (e) {
      print('Error getBookmarks: $e');
      return [];
    }
  }

  // 2. Toggle Bookmark (Fungsi Inti)
  Future<Map<String, dynamic>> toggleBookmark(int postId) async {
    final token = await _getToken();
    try {
      print('🔄 toggleBookmark: Sending request for post $postId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/bookmark'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 toggleBookmark: Status ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {
          'success': true,
          'message': body['message'],
          'is_bookmarked': body['is_bookmarked']
        };
      }
      return {'success': false, 'message': 'Gagal mengubah markah'};
    } catch (e) {
      print('❌ toggleBookmark error: $e');
      return {'success': false, 'message': 'Error koneksi'};
    }
  }

  // 3. Wrapper (Agar tidak merusak kode UI yang lama)
  Future<bool> addBookmark(int postId) async {
    final result = await toggleBookmark(postId);
    return result['success'] == true;
  }

  Future<bool> removeBookmark(int postId) async {
    final result = await toggleBookmark(postId);
    return result['success'] == true;
  }
}