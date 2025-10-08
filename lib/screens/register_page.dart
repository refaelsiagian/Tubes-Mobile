import 'package:flutter/material.dart';
const Color _kPurpleColor = Color(0xFF673AB7);
const Color _kGradientStart = Color(0xFF5E54D7);
const Color _kGradientEnd = Color(0xFF9069E7);
const Color _kTextColor = Color(0xFF333333);
class RegisterPage extends StatelessWidget {
  final VoidCallback onLoginTap;
  const RegisterPage({super.key, required this.onLoginTap});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 70), 
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.article,
                  size: 32.0,
                  color: _kPurpleColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Lembar.',
                  style: TextStyle(
                    color: _kTextColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            // Judul
            const Text(
              'Daftar', 
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: _kTextColor,
              ),
            ),
            const SizedBox(height: 30),
            // Input Nama pengguna
            _buildTextField(
              label: 'Nama pengguna',
              hint: 'Masukkan nama lengkap',
            ),
            const SizedBox(height: 20),
            // Input Email
            _buildTextField(
              label: 'Email',
              hint: 'Masukkan email valid',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Input Kata Sandi
            _buildTextField(
              label: 'Kata sandi',
              hint: 'Masukkan sandi',
              isPassword: true,
            ),
            const SizedBox(height: 20),
            // Input Konfirmasi Kata Sandi
            _buildTextField(
              label: 'Konfirmasi kata sandi',
              hint: 'Masukkan konfirmasi sandi',
              isPassword: true,
            ),
            const SizedBox(height: 30),
            // Sudah memiliki akun? Masuk.
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Sudah memiliki akun?',
                  style: TextStyle(color: _kTextColor),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onLoginTap, 
                  child: const Text(
                    'Masuk.',
                    style: TextStyle(
                      color: _kPurpleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Tombol "Daftar" 
            _buildGradientButton(
              text: 'Daftar',
              onPressed: () {
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
  Widget _buildTextField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _kTextColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          obscureText: isPassword,
          style: const TextStyle(color: _kTextColor),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(
                color: Color(0xFFDDDDDD), 
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(
                color: _kPurpleColor, 
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
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
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        gradient: const LinearGradient(
          colors: [_kGradientStart, _kGradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30.0),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}