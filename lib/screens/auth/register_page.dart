import 'package:flutter/material.dart';

const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kTextColor = Color(0xFF333333);

class RegisterPage extends StatelessWidget {
  final VoidCallback onLoginTap;
  const RegisterPage({super.key, required this.onLoginTap});
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
            Text('Daftar', style: textTheme.headlineLarge),
            const SizedBox(height: 16),
            // Input Nama pengguna
            _buildTextField(
              label: 'Nama pengguna',
              hint: 'Masukkan nama lengkap',
              context: context,
            ),
            const SizedBox(height: 16),
            // Input Email
            _buildTextField(
              label: 'Email',
              hint: 'Masukkan email valid',
              context: context,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Input Kata Sandi
            _buildTextField(
              label: 'Kata sandi',
              hint: 'Masukkan sandi',
              context: context,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            // Input Konfirmasi Kata Sandi
            _buildTextField(
              label: 'Konfirmasi kata sandi',
              hint: 'Masukkan konfirmasi sandi',
              context: context,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            // Tombol Daftar (Gradient)
            _buildGradientButton(text: 'Daftar', onPressed: () {}),
            const SizedBox(height: 32),
            // Sudah Punya Akun? Masuk.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sudah memiliki akun? '),
                InkWell(
                  onTap: onLoginTap,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: const Text(
                    'Masuk.',
                    style: TextStyle(
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
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        TextField(
          keyboardType: keyboardType,
          obscureText: isPassword,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: _kTextColor),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 6.0,
              horizontal: 16.0,
            ),
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
