import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart'; // Pastikan file ini ada

class PostService {
  // Mengambil URL dari AuthService sesuai permintaan
  static const String baseUrl = AuthService.baseUrl;

  // Helper untuk ambil token biar kodingan lebih bersih
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<Map<String, dynamic>>> getPosts({int? userId, String? search}) async {
    try {
      final token = await _getToken();
      String url = '$baseUrl/posts';
      List<String> queryParams = [];
      
      if (userId != null) queryParams.add('user_id=$userId');
      if (search != null && search.isNotEmpty) queryParams.add('search=$search');
      
      if (queryParams.isNotEmpty) url += '?${queryParams.join('&')}';

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
      }
      return [];
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
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      }
      return {'success': false, 'message': 'Gagal memuat lembar'};
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
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      }
      return {'success': false, 'message': 'Gagal memuat komentar'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  Future<Map<String, dynamic>> postComment(int postId, String content) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Silakan login terlebih dahulu'};

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
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      }
      return {'success': false, 'message': 'Gagal mengirim komentar'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  // === FITUR LIKE ===
  Future<Map<String, dynamic>> toggleLike(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'message': 'Silakan login'};

      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
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
      }
      return {'success': false, 'message': 'Gagal menyukai post'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // === CREATE POST ===
  Future<Map<String, dynamic>> createPost(String title, String content, String status, {String? snippet, String? visibility, File? thumbnail}) async {
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
      request.fields['visibility'] = visibility ?? 'public';

      if (thumbnail != null) {
        request.files.add(await http.MultipartFile.fromPath('thumbnail', thumbnail.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      }
      return {'success': false, 'message': 'Gagal membuat postingan'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // === UPDATE POST ===
  Future<Map<String, dynamic>> updatePost(int id, String title, String content, String status, {String? snippet, String? visibility, File? thumbnail}) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/posts/$id');
    
    try {
      var request = http.MultipartRequest('POST', url); 
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields['_method'] = 'PUT'; // Laravel spoofing
      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['status'] = status;
      if (snippet != null) request.fields['snippet'] = snippet;
      if (visibility != null) request.fields['visibility'] = visibility;

      if (thumbnail != null) {
        request.files.add(await http.MultipartFile.fromPath('thumbnail', thumbnail.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      }
      return {'success': false, 'message': 'Gagal update postingan'};
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

  // === BAGIAN UTAMA YANG DIUBAH (BOOKMARK) ===

  // 1. Get Bookmarks (Tetap sama)
// GANTI FUNGSI getBookmarks DENGAN INI BUAT CEK ERROR
// Update fungsi getBookmarks di PostService
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
        
        // Jaga-jaga kalau backend kirim null atau format beda
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

  // 2. LOGIC BARU: TOGGLE BOOKMARK (SATU PINTU)
  // Ini fungsi inti yang akan dipanggil oleh add/remove
  Future<Map<String, dynamic>> toggleBookmark(int postId) async {
    final token = await _getToken();
    try {
      print('🔄 toggleBookmark: Sending request for post $postId');
      
      // Endpoint ini mengarah ke BookmarkController@toggle di Backend
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/bookmark'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Penting
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

  // 3. WRAPPERS (Biar UI lama kamu tidak error)
  // Kedua fungsi ini sekarang cuma "numpang" panggil toggleBookmark
  Future<bool> addBookmark(int postId) async {
    final result = await toggleBookmark(postId);
    return result['success'] == true;
  }

  Future<bool> removeBookmark(int postId) async {
    final result = await toggleBookmark(postId);
    return result['success'] == true;
  }
}