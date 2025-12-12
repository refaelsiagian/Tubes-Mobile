import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class PostService {
  static const String baseUrl = AuthService.baseUrl;

  Future<List<Map<String, dynamic>>> getPosts({int? userId, String? search}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      String url = '$baseUrl/posts';
      List<String> queryParams = [];
      
      if (userId != null) {
        queryParams.add('user_id=$userId');
      }
      if (search != null && search.isNotEmpty) {
        queryParams.add('search=$search');
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

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
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat lembar',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getComments(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

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
      } else {
        return {
          'success': false,
          'message': 'Gagal memuat komentar',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> postComment(int postId, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

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
        return {
          'success': true,
          'data': jsonDecode(response.body)['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengirim komentar',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> toggleLike(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('❌ toggleLike: No token found');
        return {'success': false, 'message': 'Silakan login terlebih dahulu'};
      }

      print('🔄 toggleLike: Sending request to /posts/$postId/like');
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 toggleLike: Status ${response.statusCode}');
      print('📡 toggleLike: Body ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal menyukai lembar: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ toggleLike error: $e');
      return {
        'success': false,
        'message': 'Koneksi error: $e',
      };
    }
  }


  Future<Map<String, dynamic>> createPost(String title, String content, String status, {String? snippet, String? visibility, File? thumbnail}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
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
      } else {
        return {
          'success': false,
          'message': 'Gagal membuat postingan: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updatePost(int id, String title, String content, String status, {String? snippet, String? visibility, File? thumbnail}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl/posts/$id');
    
    try {
      var request = http.MultipartRequest('POST', url); // Use POST with _method=PUT for Laravel
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
      } else {
        print('❌ Update Post Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message': 'Gagal memperbarui postingan: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Update Post Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<bool> deletePost(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    try {
      print('🔄 getLikedPosts: Fetching liked posts');
      final response = await http.get(
        Uri.parse('$baseUrl/posts/liked/all'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 getLikedPosts: Status ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('❌ getLikedPosts error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
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
        final List data = jsonDecode(response.body)['data'];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addBookmark(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    try {
      print('🔄 addBookmark: Sending request for post $postId');
      final response = await http.post(
        Uri.parse('$baseUrl/bookmarks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'post_id': postId}),
      );
      print('📡 addBookmark: Status ${response.statusCode}');
      print('📡 addBookmark: Body ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ addBookmark error: $e');
      return false;
    }
  }

  Future<bool> removeBookmark(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    try {
      print('🔄 removeBookmark: Sending request for post $postId');
      final response = await http.delete(
        Uri.parse('$baseUrl/bookmarks/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('📡 removeBookmark: Status ${response.statusCode}');
      print('📡 removeBookmark: Body ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ removeBookmark error: $e');
      return false;
    }
  }
}
