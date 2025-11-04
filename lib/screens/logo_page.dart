import 'package:flutter/material.dart';

const Color _kPurpleColor = Color(0xFF673AB7); 

class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _kPurpleColor,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo1.png',
              width: 50.0,
              height: 50.0,
            ),
            const SizedBox(width: 8),
            Text(
              'Lembar.',
              style: textTheme.headlineLarge,
            ),
          ],
        ),
      ),
    );
  }
}
