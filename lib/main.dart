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
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.notoSansTextTheme(
          // Sử dụng font Noto Sans
          Theme.of(context).textTheme,
        ),
        // Đảm bảo font được áp dụng cho tất cả các text
        fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      home: const LoginScreen(),
    );
  }
}
