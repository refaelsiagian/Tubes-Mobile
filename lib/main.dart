import 'package:flutter/material.dart';
import 'screens/auth/logo_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';

void main() {
  runApp(const MyApp());
}

// Enum untuk mengelola state halaman mana yang sedang aktif
enum AuthPage { logo, login, register }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lembar.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8D07C6)),
        useMaterial3: true,
        fontFamily: 'Nunito',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      home: const PageControllerWidget(),
    );
  }
}

class PageControllerWidget extends StatefulWidget {
  const PageControllerWidget({super.key});
  @override
  State<PageControllerWidget> createState() => _PageControllerWidgetState();
}

class _PageControllerWidgetState extends State<PageControllerWidget> {
  AuthPage _currentPage = AuthPage.logo;
  @override
  void initState() {
    super.initState();
    // Delay: 1.4 detik animasi + 1.5 detik jeda = ~3 detik
    Future.delayed(const Duration(milliseconds: 2900), () {
      if (mounted) {
        setState(() {
          _currentPage = AuthPage.login;
        });
      }
    });
  }

  void _navigateTo(AuthPage page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage;
    switch (_currentPage) {
      case AuthPage.logo:
        activePage = const LogoPage(); // Tampilkan Logo
        break;
      case AuthPage.login:
        activePage = LoginPage(
          onRegisterTap: () => _navigateTo(AuthPage.register),
          onForgotTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Halaman Lupa Sandi Belum Dibuat!')),
            );
          },
        );
        break;
      case AuthPage.register:
        activePage = RegisterPage(
          // Pindah kembali ke Login saat tombol 'Masuk.' di klik
          onLoginTap: () => _navigateTo(AuthPage.login),
        );
        break;
    }
    return activePage;
  }
}
