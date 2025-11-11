import 'package:flutter/material.dart';

class LogoPage extends StatefulWidget {
  const LogoPage({super.key});

  @override
  State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _textProgressAnimation;

  final String _text = 'Lembar.';
  final int _textDurationMs = 400; // Durasi cepat untuk animasi teks

  @override
  void initState() {
    super.initState();

    // AnimationController dengan duration total 1.4 detik untuk animasi
    // + 1.5 detik jeda = total ~2.9 detik
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    // Logo fade in: 0.0 - 0.3 (0-420ms)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Logo slide ke kiri: 0.3 - 0.5 (420-700ms)
    _logoSlideAnimation =
        Tween<Offset>(
          begin: Offset.zero, // Di tengah
          end: const Offset(
            -0.18,
            0.0,
          ), // Geser ke kiri sedikit lagi agar tidak menimpa tulisan
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.5, curve: Curves.easeInOut),
          ),
        );

    // Teks progress untuk animasi per karakter: 0.3 - 0.586 (420-820ms)
    // Mulai saat logo mulai slide, durasi 400ms
    _textProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.3,
          0.586,
          curve: Curves.linear,
        ), // 400ms dari 1400ms = 0.286, jadi 0.3 + 0.286 = 0.586
      ),
    );

    // Mulai animasi
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Widget untuk animasi teks per karakter
  Widget _buildAnimatedText(TextTheme textTheme) {
    return AnimatedBuilder(
      animation: _textProgressAnimation,
      builder: (context, child) {
        // Hitung berapa karakter yang sudah muncul
        // Animasi teks berjalan dalam _textDurationMs (400ms)
        final currentTime = _textProgressAnimation.value * _textDurationMs;
        final charsToShow = (currentTime / (_textDurationMs / _text.length))
            .ceil();
        final visibleChars = charsToShow.clamp(0, _text.length);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_text.length, (index) {
            final char = _text[index];
            final charProgress = index < visibleChars
                ? ((currentTime - (index * (_textDurationMs / _text.length))) /
                          (_textDurationMs / _text.length))
                      .clamp(0.0, 1.0)
                : 0.0;

            return Opacity(
              opacity: charProgress,
              child: Text(
                char,
                style: textTheme.headlineLarge?.copyWith(
                  fontSize: 32, // Diperbesar dari 24 menjadi 32
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo di tengah layar (horizontal dan vertikal)
          AnimatedBuilder(
            animation: _logoSlideAnimation,
            builder: (context, child) {
              // Hitung posisi logo
              final slideOffset = _logoSlideAnimation.value;
              final centerX = screenWidth / 2;
              final centerY = screenHeight / 2;

              // Posisi awal: tengah layar
              // Posisi akhir: tengah layar - offset untuk slide ke kiri
              final logoX = centerX + (slideOffset.dx * screenWidth);
              final logoY = centerY;

              return Positioned(
                left: logoX - 25, // 25 = setengah dari width logo (50/2)
                top: logoY - 25, // 25 = setengah dari height logo (50/2)
                child: FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: Image.asset(
                    'assets/images/logo1.png',
                    width: 50.0,
                    height: 50.0,
                  ),
                ),
              );
            },
          ),
          // Teks di tengah layar, muncul saat logo mulai slide
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                left:
                    screenWidth *
                    0.06, // Offset untuk posisi teks setelah logo slide (dikurangi jaraknya)
              ),
              child: _buildAnimatedText(textTheme),
            ),
          ),
        ],
      ),
    );
  }
}
