import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import package
import 'screens/login_screen.dart';

void main() {
  runApp(const FoodApp());
}

class FoodApp extends StatelessWidget {
  const FoodApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodapp',
      theme: ThemeData(
        primaryColor: const Color(
            0xff3235ff), // Sử dụng primaryColor thay vì primarySwatch
        textTheme: GoogleFonts.notoSansTextTheme(
          Theme.of(context).textTheme,
        ),
        fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      home: const LoginScreen(),
    );
  }
}
