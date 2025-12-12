import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

const Color _kPurpleColor = Color(0xFF8D07C6);
const Color _kTextColor = Color(0xFF333333);

class RegisterPage extends StatefulWidget {
  final VoidCallback onLoginTap;
  const RegisterPage({super.key, required this.onLoginTap});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}



class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController(); // New Controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();
  
  Timer? _debounce;
  bool? _usernameAvailable;
  String? _usernameMessage;

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (value.isEmpty) {
      setState(() {
        _usernameAvailable = null;
        _usernameMessage = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final available = await _authService.checkUsername(value);
      setState(() {
        _usernameAvailable = available;
        _usernameMessage = available ? 'Username tersedia' : 'Username sudah dipakai';
      });
    });
  }

  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi tidak sama')),
      );
      return;
    }

    if (_usernameAvailable == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username sudah dipakai, silakan ganti')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await _authService.register(
      _nameController.text,
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil! Silakan masuk.')),
      );
      widget.onLoginTap();
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
            Text('Daftar', style: textTheme.headlineLarge),
            const SizedBox(height: 16),
            // Input Nama
            _buildTextField(
              label: 'Nama',
              hint: 'Masukkan nama lengkap',
              context: context,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            // Input Username (Custom Logic)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                TextField(
                  controller: _usernameController,
                  onChanged: _onUsernameChanged,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _kTextColor),
                  decoration: InputDecoration(
                    hintText: 'Masukkan username unik',
                    contentPadding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide(
                        color: _usernameAvailable == null 
                            ? const Color(0xFFDDDDDD) 
                            : (_usernameAvailable! ? Colors.green : Colors.red),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide(
                        color: _usernameAvailable == null 
                            ? _kPurpleColor 
                            : (_usernameAvailable! ? Colors.green : Colors.red),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide(
                        color: _usernameAvailable == null 
                            ? const Color(0xFFDDDDDD) 
                            : (_usernameAvailable! ? Colors.green : Colors.red),
                        width: 1.0,
                      ),
                    ),
                    helperText: _usernameMessage,
                    helperStyle: TextStyle(
                      color: _usernameAvailable == true ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Input Email
            _buildTextField(
              label: 'Email',
              hint: 'Masukkan email valid',
              context: context,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Input Kata Sandi
            _buildTextField(
              label: 'Kata sandi',
              hint: 'Masukkan sandi',
              context: context,
              controller: _passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            // Input Konfirmasi Kata Sandi
            _buildTextField(
              label: 'Konfirmasi kata sandi',
              hint: 'Masukkan konfirmasi sandi',
              context: context,
              controller: _confirmPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            // Tombol Daftar (Gradient)
            _isLoading
              ? const CircularProgressIndicator()
              : _buildGradientButton(
                  text: 'Daftar',
                  onPressed: _handleRegister,
                ),
            const SizedBox(height: 32),
            // Sudah Punya Akun? Masuk.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Sudah memiliki akun? '),
                InkWell(
                  onTap: widget.onLoginTap,
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
