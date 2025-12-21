import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart'; // Tambahkan package ini: flutter pub add device_info_plus
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  /// Mengecek dan meminta izin galeri dengan logika Android versi baru & lama
  static Future<bool> checkGalleryPermission(BuildContext context) async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      // Android 13 (SDK 33) ke atas menggunakan READ_MEDIA_IMAGES
      if (androidInfo.version.sdkInt >= 33) {
        status = await Permission.photos.request();
      } else {
        // Android 12 ke bawah menggunakan STORAGE
        status = await Permission.storage.request();
      }
    } else {
      // iOS
      status = await Permission.photos.request();
    }

    if (status.isGranted || status.isLimited) {
      return true;
    } 
    
    // Jika ditolak permanen, tampilkan dialog
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showOpenSettingsDialog(context);
      }
      return false;
    }

    return false;
  }

  static void _showOpenSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Izin Diperlukan'),
        content: const Text(
          'Aplikasi membutuhkan akses ke galeri untuk fitur ini. '
          'Silakan aktifkan izin di Pengaturan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings(); // Membuka setting HP
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }
}