import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Căn giữa theo chiều dọc
          crossAxisAlignment:
              CrossAxisAlignment.center, // Căn giữa theo chiều ngang
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tên: ${user.name}',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center, // Đảm bảo text căn giữa
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${user.email}',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center, // Đảm bảo text căn giữa
            ),
            const SizedBox(height: 20),
            ElevatedButton(
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
