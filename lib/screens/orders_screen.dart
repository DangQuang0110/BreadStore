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

  void _clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orders');
    setState(() {
      _orders.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa tất cả đơn hàng!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange, // Đặt nền cam
      appBar: AppBar(
        title: const Text('Đơn Hàng'),
        backgroundColor: Colors.deepOrange, // Đồng bộ màu với nền
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _orders.isEmpty
                  ? null
                  : () {
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
          ? const Center(
              child: Text(
                'Chưa có đơn hàng nào',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  color: Colors.white,
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      'Đơn hàng #${order.id}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          'Tổng: ${_numberFormat.format(order.total.toInt())} đ',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Ngày đặt: ${order.orderDate.toLocal().toString().split('.')[0]}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Trạng thái: ${order.status}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.green),
                        ),
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
