import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import '../screens/search_page.dart';
import '../screens/markah_page.dart';
import '../screens/profile_page.dart';

class NavigationHelper {
  static void navigateToPage(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const SearchPage();
        break;
      case 2:
        page = const MarkahPage();
        break;
      case 3:
        page = const ProfilePage();
        break;
      default:
        return;
    }

    // Menggunakan PageRouteBuilder dengan fade transition untuk menghilangkan animasi zoom
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero, // Tidak ada animasi
        reverseTransitionDuration: Duration.zero, // Tidak ada animasi saat kembali
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Return child langsung tanpa animasi
          return child;
        },
      ),
      (route) => false,
    );
  }
}

