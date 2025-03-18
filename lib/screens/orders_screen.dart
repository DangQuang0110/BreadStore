import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order_model.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  final NumberFormat _numberFormat = NumberFormat("#,###", "vi_VN");

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('orders') ?? '[]';
    final orders = List<Map<String, dynamic>>.from(jsonDecode(ordersJson));
    setState(() {
      _orders = orders.map((json) => Order.fromJson(json)).toList();
    });
  }

  // Hàm xóa tất cả đơn hàng
  void _clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orders'); // Xóa key 'orders'
    setState(() {
      _orders.clear(); // Xóa danh sách hiển thị
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa tất cả đơn hàng!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn Hàng'),
        backgroundColor: Colors.teal, // Đặt màu nền cho AppBar để dễ nhận diện
        actions: [
          // Nút xóa tất cả đơn hàng
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 30, // Tăng kích thước biểu tượng để dễ thấy
              ),
              onPressed: _orders.isEmpty
                  ? null // Vô hiệu hóa nếu không có đơn hàng
                  : () {
                      // Hiển thị dialog xác nhận trước khi xóa
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác Nhận Xóa'),
                          content: const Text(
                              'Bạn có chắc muốn xóa tất cả đơn hàng? Hành động này không thể hoàn tác.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                _clearOrders();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
              tooltip: 'Xóa tất cả đơn hàng',
            ),
          ),
        ],
      ),
      body: _orders.isEmpty
          ? const Center(child: Text('Chưa có đơn hàng nào'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    title: Text('Đơn hàng #${order.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Tổng: ${_numberFormat.format(order.total.toInt())} đ'),
                        Text(
                            'Ngày đặt: ${order.orderDate.toLocal().toString().split('.')[0]}'),
                        Text('Trạng thái: ${order.status}'),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Xem chi tiết đơn hàng #${order.id}')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
