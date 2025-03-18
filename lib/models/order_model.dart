class Order {
  final String id;
  final List<Map<String, dynamic>> items;
  final double total;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.orderDate,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      orderDate:
          DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'Đã Thanh Toán',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items,
      'total': total,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
    };
  }
}
