import 'package:flutter/material.dart';

const Color _kPurpleColor = Color(0xFF673AB7); 

class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _kPurpleColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.article, 
              size: 50.0,
              color: Colors.white,
            ),
            SizedBox(width: 8), 
            Text(
              'Lembar.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
