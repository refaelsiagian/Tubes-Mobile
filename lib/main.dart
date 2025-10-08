import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/logo_page.dart';
import 'screens/login_page.dart';
void main() {
  runApp(const MyApp());
}
// Enum untuk mengelola state halaman mana yang sedang aktif
enum AuthPage { 
  logo, 
  login
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF673AB7)),
        useMaterial3: true,
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
    Future.delayed(const Duration(seconds: 5), () {
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
          // onRegisterTap: () => _navigateTo(AuthPage.register),
          onForgotTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Halaman Lupa Sandi Belum Dibuat!')),
            );
          },
        );
        break;
    }
    return activePage;
  }
}
