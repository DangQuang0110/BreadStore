import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/food_model.dart';
import '../models/user_model.dart';
import '../constants.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiService _apiService;
  List<Food> _foods = [];
  List<Food> _filteredFoods = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _cart = [];
  final NumberFormat _numberFormat = NumberFormat("#,###", "vi_VN");

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(client: http.Client());
    _loadFoods();
    _loadCart();
  }

  void _loadFoods() async {
    try {
      final foods = await _apiService.getFoods();
      setState(() {
        _foods = foods;
        _filteredFoods = foods;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách món ăn: $e')),
      );
    }
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

  void _filterFoods(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredFoods = _foods;
      } else {
        _filteredFoods =
            _foods.where((food) => food.category == category).toList();
      }
      _searchFoods(_searchController.text);
    });
  }

  void _searchFoods(String query) {
    setState(() {
      if (query.isEmpty) {
        if (_selectedCategory == 'All') {
          _filteredFoods = _foods;
        } else {
          _filteredFoods = _foods
              .where((food) => food.category == _selectedCategory)
              .toList();
        }
      } else {
        _filteredFoods = _foods
            .where((food) =>
                food.name.toLowerCase().contains(query.toLowerCase()) &&
                (_selectedCategory == 'All' ||
                    food.category == _selectedCategory))
            .toList();
      }
    });
  }

  void _addToCart(Food food) {
    setState(() {
      final existingItemIndex =
          _cart.indexWhere((item) => item['id'] == food.id);
      if (existingItemIndex >= 0) {
        _cart[existingItemIndex]['quantity'] += 1;
      } else {
        _cart.add({
          'id': food.id,
          'name': food.name,
          'price': food.price,
          'imageUrl': food.imageUrl,
          'quantity': 1,
        });
      }
      _saveCart();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${food.name} đã được thêm vào giỏ hàng!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foodapp'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              child: Text(widget.user.name[0].toUpperCase()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: _searchFoods,
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildCategoryTab('All'),
                _buildCategoryTab('Food'),
                _buildCategoryTab('Drink'),
                _buildCategoryTab('Snacks'),
                _buildCategoryTab('More'),
              ],
            ),
          ),
          Expanded(
            child: _filteredFoods.isEmpty
                ? const Center(child: Text('Không tìm thấy món ăn'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredFoods.length,
                    itemBuilder: (context, index) {
                      final food = _filteredFoods[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: food.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          title: Text(
                            food.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                              '${_numberFormat.format(food.price.toInt())} đ'), // Làm tròn xuống và định dạng
                          trailing: IconButton(
                            icon: const Icon(Icons.add, color: Colors.teal),
                            onPressed: () => _addToCart(food),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ChoiceChip(
        label: Text(category),
        selected: _selectedCategory == category,
        onSelected: (selected) {
          if (selected) {
            _filterFoods(category);
          }
        },
      ),
    );
  }
}
