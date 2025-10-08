import 'package:flutter/material.dart';
class LoginPage extends StatelessWidget {
  final VoidCallback onRegisterTap;
  final VoidCallback onForgotTap;
  const LoginPage({
    super.key,
    required this.onRegisterTap,
    required this.onForgotTap,
  });
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: <Widget>[
            // Jarak Atas
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            // Logo dan Teks 'Lembar.'
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/logo1.png', 
                  width: 42, 
                  height: 42, 
                ),
                const SizedBox(width: 8),
                Text(
                  'Lembar.',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            // Judul
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Masuk',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            // Input Email
            const TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Masukkan email valid',
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  borderSide: BorderSide(color: Color(0xFF673AB7), width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Input Kata Sandi
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Masukkan kata sandi',
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  borderSide: BorderSide(color: Color(0xFF673AB7), width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Lupa Kata Sandi
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onForgotTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lupa kata sandi?',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Tombol Masuk (Gradient)
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF673AB7), // Ungu
                    Color(0xFF9C27B0), // Magenta
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Proses Masuk...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Masuk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 50),
            // Belum Punya Akun? Daftar.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum memiliki akun? '),
                InkWell(
                  onTap: onRegisterTap,
                  child: Text(
                    'Daftar.',
                    style: TextStyle(
                      color: primaryColor,
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
}
