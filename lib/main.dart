import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/logo_page.dart';
void main() {
  runApp(const MyApp());
}
// Enum untuk mengelola state halaman mana yang sedang aktif
enum AuthPage { 
  logo
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lembar',
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
    }
    return activePage;
  }
}
