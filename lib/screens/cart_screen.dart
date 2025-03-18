import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _cart = [];
  final NumberFormat _numberFormat = NumberFormat("#,###", "vi_VN");

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart') ?? '[]';
    setState(() {
      _cart = List<Map<String, dynamic>>.from(jsonDecode(cartJson));
    });
  }

  void _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', jsonEncode(_cart));
  }

  void _updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cart.length) {
      setState(() {
        if (newQuantity <= 0) {
          _cart.removeAt(index);
        } else {
          _cart[index]['quantity'] = newQuantity;
        }
        _saveCart(); // Lưu ngay sau khi cập nhật
      });
    }
  }

  void _saveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('orders') ?? '[]';
    final orders = List<Map<String, dynamic>>.from(jsonDecode(ordersJson));
    final total = _cart.fold<int>(0, (sum, item) {
      final price = (item['price'] as num?)?.toInt() ?? 0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      return sum + (price * quantity);
    });
    final newOrder = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'items': List<Map<String, dynamic>>.from(_cart),
      'total': total
          .toDouble(), // Chuyển thành double để tương thích với model Order
      'orderDate': DateTime.now().toIso8601String(),
      'status': 'Đã Thanh Toán',
    };
    orders.add(newOrder);
    await prefs.setString('orders', jsonEncode(orders));
    setState(() {
      _cart.clear();
      _saveCart();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanh toán thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = _cart.fold<int>(0, (sum, item) {
      final price = (item['price'] as num?)?.toInt() ?? 0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      return sum + (price * quantity);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ Hàng'),
      ),
      body: _cart.isEmpty
          ? const Center(child: Text('Giỏ hàng trống'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
                      final price = (item['price'] as num?)?.toInt() ?? 0;
                      return ListTile(
                        title: Text(item['name'] ?? 'Tên không xác định'),
                        subtitle: Text(
                          'Số lượng: $quantity - ${_numberFormat.format(price)} đ mỗi món',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () =>
                                  _updateQuantity(index, quantity - 1),
                              color: Colors.red,
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  _updateQuantity(index, quantity + 1),
                              color: Colors.green,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Tổng cộng: ${_numberFormat.format(total)} đ',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _saveOrder,
                        child: const Text('Thanh Toán'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
