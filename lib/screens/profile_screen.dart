import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange, // Đặt nền cam
      appBar: AppBar(
        title: const Text('Hồ Sơ'),
        backgroundColor: Colors.deepOrange, // Đồng bộ màu với nền
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white, // Làm nổi bật avatar
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 40, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tên: ${user.name}',
              style: const TextStyle(
                  fontSize: 20, color: Colors.white), // Màu trắng cho dễ đọc
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${user.email}',
              style: const TextStyle(
                  fontSize: 20, color: Colors.white), // Màu trắng
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Nút trắng nổi bật trên nền cam
                foregroundColor: Colors.orange, // Màu chữ cam
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Đăng Xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
