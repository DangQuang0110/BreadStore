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
        _saveCart();
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
      'total': total.toDouble(),
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
      backgroundColor: Colors.orange, // Đặt nền cam
      appBar: AppBar(
        title: const Text('Giỏ Hàng'),
        backgroundColor: Colors.deepOrange, // Đồng bộ màu với nền
      ),
      body: _cart.isEmpty
          ? const Center(
              child: Text(
                'Giỏ hàng trống',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
                      final price = (item['price'] as num?)?.toInt() ?? 0;
                      return Card(
                        color: Colors.white, // Làm nổi bật sản phẩm
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
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
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.9), // Làm nổi bật phần tổng tiền
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tổng cộng: ${_numberFormat.format(total)} đ',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange, // Nút cam đậm
                          foregroundColor: Colors.white, // Chữ trắng
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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
