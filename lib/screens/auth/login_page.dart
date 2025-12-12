import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../main/home_page.dart';

const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kTextColor = Color(0xFF333333);

class LoginPage extends StatefulWidget {
  final VoidCallback onRegisterTap;
  final VoidCallback onForgotTap;

  const LoginPage({
    super.key,
    required this.onRegisterTap,
    required this.onForgotTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true; // State for password visibility
  final _authService = AuthService();

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    final result = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: <Widget>[
            // Jarak Atas
            SizedBox(height: MediaQuery.of(context).size.height * 0.12),
            // Logo dan Teks 'Lembar.'
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo1.png', width: 32, height: 32),
                const SizedBox(width: 6),
                Text('Lembar.', style: textTheme.headlineLarge),
              ],
            ),
            const SizedBox(height: 32),
            // Judul
            Text('Masuk', style: textTheme.headlineLarge),
            const SizedBox(height: 16),
            // Input Email
            _buildTextField(
              label: 'Email',
              hint: 'Masukkan email valid',
              context: context,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Input Kata Sandi
            _buildTextField(
              label: 'Kata sandi',
              hint: 'Masukkan sandi',
              context: context,
              controller: _passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onForgotTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashFactory: NoSplash.splashFactory,
                ),
                child: Text(
                  'Lupa kata sandi?',
                  style: textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF8D07C6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Tombol Masuk (Gradient)
            _isLoading 
              ? const CircularProgressIndicator()
              : _buildGradientButton(
                  text: 'Masuk',
                  onPressed: _handleLogin,
                ),
            const SizedBox(height: 32),
            // Belum Punya Akun? Daftar.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum memiliki akun? '),
                InkWell(
                  onTap: widget.onRegisterTap,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Text(
                    'Daftar.',
                    style: const TextStyle(
                      color: Color(0xFF8D07C6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required BuildContext context,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? _obscurePassword : false,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: _kTextColor),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 6.0,
              horizontal: 16.0,
            ),
            // Add suffix icon for password toggle
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF999999),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
              borderSide: const BorderSide(
                color: Color(0xFFDDDDDD),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
              borderSide: const BorderSide(color: _kPurpleColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
              borderSide: const BorderSide(
                color: Color(0xFFDDDDDD),
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: const LinearGradient(
          colors: [Color(0xFF8D07C6), Color(0xFFDD01BE)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          foregroundColor: Colors.white,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
