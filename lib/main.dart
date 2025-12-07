import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan package ini sudah ada di pubspec.yaml
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
        // Skema Warna Utama (Tetap Ungu sesuai request)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8D07C6),
          primary: const Color(0xFF8D07C6),
        ),
        useMaterial3: true,

        // === IMPLEMENTASI FONT MODERN: MANROPE ===
        // Menggantikan Poppins dengan Manrope.
        // Google Fonts akan otomatis mengatur ukuran dan ketebalan yang proporsional.
        textTheme: GoogleFonts.manropeTextTheme(
          Theme.of(context).textTheme,
        ),

        // Customisasi AppBar agar lebih bersih dan modern (Flat Style)
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white, // Menghilangkan tint warna saat di-scroll (Material 3)
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700, // Bold
            color: const Color(0xFF1A1A1A), // Hitam soft
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        ),

        // Customisasi Tombol Utama (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0, // Flat button lebih modern
            textStyle: GoogleFonts.manrope(
              fontWeight: FontWeight.w700, // Teks tombol bold
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Sudut membulat
            ),
          ),
        ),
        
        // Customisasi Tombol Garis (OutlinedButton)
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: GoogleFonts.manrope(
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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