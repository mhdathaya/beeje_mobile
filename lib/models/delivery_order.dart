class DeliveryOrder {
  final int id;
  final int orderId;
  final String shippingAddress;
  final String recipientName;
  final String recipientPhone;
  final String? deliveryNotes;
  final String? originCity;
  final String? destinationCity;
  final String? courier;
  final String? service;
  final double shippingCost;

  DeliveryOrder({
    required this.id,
    required this.orderId,
    required this.shippingAddress,
    required this.recipientName,
    required this.recipientPhone,
    this.deliveryNotes,
    this.originCity,
    this.destinationCity,
    this.courier,
    this.service,
    required this.shippingCost,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'],
      orderId: json['order_id'],
      shippingAddress: json['shipping_address'],
      recipientName: json['recipient_name'],
      recipientPhone: json['recipient_phone'],
      deliveryNotes: json['delivery_notes'],
      originCity: json['origin_city'],
      destinationCity: json['destination_city'],
      courier: json['courier'],
      service: json['service'],
      shippingCost: double.parse(json['shipping_cost'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'shipping_address': shippingAddress,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'delivery_notes': deliveryNotes,
      'origin_city': originCity,
      'destination_city': destinationCity,
      'courier': courier,
      'service': service,
      'shipping_cost': shippingCost,
    };
  }
}