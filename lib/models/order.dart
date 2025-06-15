class Order {
  final String id;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final double totalAmount;
  final List<OrderItem> items;
  final ShippingInfo? shippingInfo; // Tambahkan informasi pengiriman

  Order({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.totalAmount,
    required this.items,
    this.shippingInfo,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      totalAmount: double.parse((json['total_amount'] ?? '0').toString()),
      items: (json['items'] as List?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      shippingInfo: json['shipping_info'] != null 
          ? ShippingInfo.fromJson(json['shipping_info']) 
          : null,
    );
  }
}

// Tambahkan class ShippingInfo
class ShippingInfo {
  final String courier;
  final String service;
  final int cost;
  final String etd;
  final String originCity;
  final String destinationCity;

  ShippingInfo({
    required this.courier,
    required this.service,
    required this.cost,
    required this.etd,
    required this.originCity,
    required this.destinationCity,
  });

  factory ShippingInfo.fromJson(Map<String, dynamic> json) {
    return ShippingInfo(
      courier: json['courier'] ?? '',
      service: json['service'] ?? '',
      cost: json['cost'] ?? 0,
      etd: json['etd'] ?? '',
      originCity: json['origin_city'] ?? '',
      destinationCity: json['destination_city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courier': courier,
      'service': service,
      'cost': cost,
      'etd': etd,
      'origin_city': originCity,
      'destination_city': destinationCity,
    };
  }
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'].toString(),
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: double.parse((json['price'] ?? '0').toString()),
    );
  }
}