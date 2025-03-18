import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/food_model.dart';
import '../constants.dart';

class ApiService {
  final http.Client client;

  ApiService({required this.client});

  // Lấy danh sách người dùng
  Future<List<User>> getUsers() async {
    try {
      final response =
          await client.get(Uri.parse('${AppConstants.apiBaseUrl}/users'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => User.fromJson(item)).toList();
      } else {
        throw Exception(
            'Không thể lấy danh sách người dùng: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Đăng nhập
  Future<Map<String, dynamic>> login(String name, String password) async {
    try {
      final users = await getUsers();
      final user = users.firstWhere(
        (user) => user.name == name && user.password == password,
        orElse: () => User(id: '', name: '', email: '', password: ''),
      );
      if (user.name.isNotEmpty) {
        return {
          'success': true,
          'message': 'Đăng nhập thành công',
          'user': user
        };
      } else {
        return {
          'success': false,
          'message': 'Tên đăng nhập hoặc mật khẩu không đúng'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Đăng ký
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final users = await getUsers();
      if (users.any((user) => user.email == email)) {
        return {'success': false, 'message': 'Email đã tồn tại'};
      }
      if (users.any((user) => user.name == name)) {
        return {'success': false, 'message': 'Tên đăng nhập đã tồn tại'};
      }

      final response = await client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/users'),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Đăng ký thành công'};
      } else {
        return {
          'success': false,
          'message': 'Lỗi server: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Lấy danh sách món ăn
  Future<List<Food>> getFoods() async {
    try {
      final response =
          await client.get(Uri.parse('${AppConstants.apiBaseUrl}/foods'));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Food.fromJson(item)).toList();
      } else {
        throw Exception(
            'Không thể lấy danh sách món ăn: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}
