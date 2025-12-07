import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LembarStorage {
  static const String _fileName = 'lembar_data.json';
  static const String _storiesFileName = 'stories_data.json';
  static const String _jilidFileName = 'jilid_data.json';

  // Get file path for lembar data
  static Future<File> _getLembarFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  // Get file path for stories data
  static Future<File> _getStoriesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_storiesFileName');
  }

  // Get file path for jilid data
  static Future<File> _getJilidFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_jilidFileName');
  }

  // Save published lembar to home feed
  static Future<void> savePublishedLembar(Map<String, dynamic> lembar) async {
    try {
      final file = await _getLembarFile();
      List<Map<String, dynamic>> lembarList = [];

      // Read existing data
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content);
          if (decoded is List) {
            lembarList = List<Map<String, dynamic>>.from(decoded);
          }
        }
      }

      // Add new lembar with unique ID and timestamp
      // PERBAIKAN: Gunakan ID dari map jika ada, agar sinkron dengan story
      final newLembar = {
        ...lembar,
        'id': lembar['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'publishedAt': DateTime.now().toIso8601String(),
        'authorName': 'Pengguna',
        'authorInitials': 'PG',
        'likes': '0',
        'comments': '0',
      };

      // Insert at the beginning (newest first)
      lembarList.insert(0, newLembar);

      // Save to file
      await file.writeAsString(json.encode(lembarList));
    } catch (e) {
      print('Error saving lembar: $e');
    }
  }

  // Get all published lembar for home feed
  static Future<List<Map<String, dynamic>>> getPublishedLembar() async {
    try {
      final file = await _getLembarFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content);
          if (decoded is List) {
            return List<Map<String, dynamic>>.from(decoded);
          }
        }
      }
    } catch (e) {
      print('Error reading lembar: $e');
    }
    return [];
  }

  // Save story to user's stories
  static Future<void> saveStory(Map<String, dynamic> story) async {
    try {
      final file = await _getStoriesFile();
      List<Map<String, dynamic>> storiesList = [];

      // Read existing data
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content);
          if (decoded is List) {
            storiesList = List<Map<String, dynamic>>.from(decoded);
          }
        }
      }

      // Add new story with unique ID and timestamp
      // PERBAIKAN: Gunakan ID dari map jika ada
      final newStory = {
        ...story,
        'id': story['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'publishedAt': DateTime.now().toIso8601String(),
        'date': _formatDate(DateTime.now()),
      };

      // Insert at the beginning (newest first)
      storiesList.insert(0, newStory);

      // Save to file
      await file.writeAsString(json.encode(storiesList));
    } catch (e) {
      print('Error saving story: $e');
    }
  }

  // Get all user stories
  static Future<List<Map<String, dynamic>>> getStories() async {
    try {
      final file = await _getStoriesFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content);
          if (decoded is List) {
            return List<Map<String, dynamic>>.from(decoded);
          }
        }
      }
    } catch (e) {
      print('Error reading stories: $e');
    }
    return [];
  }

  // Format date to relative time
  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return '1d ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Get all lembar for select_lembar_page
  static Future<List<Map<String, dynamic>>> getAllLembar() async {
    return await getStories();
  }

  // Save jilid (collection)
  static Future<void> saveJilid(Map<String, dynamic> jilid) async {
    try {
      final file = await _getJilidFile();
      List<Map<String, dynamic>> jilidList = [];

      // Read existing data
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content);
          if (decoded is List) {
            jilidList = List<Map<String, dynamic>>.from(decoded);
          }
        }
      }

      // Add new jilid with unique ID and timestamp
      final newJilid = {
        ...jilid,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Insert at the beginning (newest first)
      jilidList.insert(0, newJilid);

      // Save to file
      await file.writeAsString(json.encode(jilidList));
    } catch (e) {
      print('Error saving jilid: $e');
    }
  }

  // Get all jilid (collections)
  static Future<List<Map<String, dynamic>>> getJilid() async {
    try {
      final file = await _getJilidFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content);
          if (decoded is List) {
            return List<Map<String, dynamic>>.from(decoded);
          }
        }
      }
    } catch (e) {
      print('Error reading jilid: $e');
    }
    return [];
  }

  // Update jilid
  static Future<void> updateJilid(
    String id,
    Map<String, dynamic> updatedJilid,
  ) async {
    try {
      final file = await _getJilidFile();
      List<Map<String, dynamic>> jilidList = [];

      // Read existing data
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content);
          if (decoded is List) {
            jilidList = List<Map<String, dynamic>>.from(decoded);
          }
        }
      }

      // Find and update the jilid
      final index = jilidList.indexWhere((j) => j['id']?.toString() == id);
      if (index != -1) {
        jilidList[index] = {
          ...updatedJilid,
          'id': id,
          'updatedAt': DateTime.now().toIso8601String(),
        };
        await file.writeAsString(json.encode(jilidList));
      }
    } catch (e) {
      print('Error updating jilid: $e');
    }
  }

  // Delete jilid
  static Future<void> deleteJilid(String id) async {
    try {
      final file = await _getJilidFile();
      List<Map<String, dynamic>> jilidList = [];

      // Read existing data
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content);
          if (decoded is List) {
            jilidList = List<Map<String, dynamic>>.from(decoded);
          }
        }
      }

      // Remove the jilid
      jilidList.removeWhere((j) => j['id']?.toString() == id);

      // Save to file
      await file.writeAsString(json.encode(jilidList));
    } catch (e) {
      print('Error deleting jilid: $e');
    }
  }

  // Update story
  static Future<void> updateStory(String id, Map<String, dynamic> updatedStory) async {
    try {
      final file = await _getStoriesFile();
      List<Map<String, dynamic>> storiesList = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content);
          if (decoded is List) storiesList = List<Map<String, dynamic>>.from(decoded);
        }
      }
      final index = storiesList.indexWhere((s) => s['id']?.toString() == id);
      if (index != -1) {
        // Keep ID, update content
        storiesList[index] = {...updatedStory, 'id': id};
        await file.writeAsString(json.encode(storiesList));
      }
    } catch (e) {
      print('Error updating story: $e');
    }
  }

  // Delete story
  static Future<void> deleteStory(String id) async {
    try {
      // 1. HAPUS DARI USER STORIES (Pribadi)
      final storiesFile = await _getStoriesFile();
      List<Map<String, dynamic>> storiesList = [];
      if (await storiesFile.exists()) {
        final content = await storiesFile.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content);
          if (decoded is List) storiesList = List<Map<String, dynamic>>.from(decoded);
        }
      }
      storiesList.removeWhere((s) => s['id']?.toString() == id);
      await storiesFile.writeAsString(json.encode(storiesList));

      // 2. HAPUS DARI HOME FEED (Publik)
      // Ini memastikan kalau di-delete dari profile, di beranda juga hilang
      final publishedFile = await _getLembarFile();
      List<Map<String, dynamic>> publishedList = [];
      if (await publishedFile.exists()) {
        final content = await publishedFile.readAsString();
        if (content.isNotEmpty) {
          final decoded = json.decode(content);
          if (decoded is List) publishedList = List<Map<String, dynamic>>.from(decoded);
        }
      }
      
      // Hapus yang ID-nya sama
      final int initialLength = publishedList.length;
      publishedList.removeWhere((s) => s['id']?.toString() == id);
      
      // Hanya tulis ulang file jika ada yang dihapus
      if (publishedList.length != initialLength) {
        await publishedFile.writeAsString(json.encode(publishedList));
      }

    } catch (e) {
      print('Error deleting story: $e');
    }
  }
}