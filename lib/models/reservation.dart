
class Reservation {
  final int id;
  final int userId;
  final DateTime reservationDate;
  final String reservationTime;
  final int peopleCount;
  final String? notes;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ReservationProduct> products;
  final String? snapToken;  // Untuk menyimpan token Midtrans
  final String? paymentStatus;
  final String? midtransTransactionId;

  Reservation({
    required this.id,
    required this.userId,
    required this.reservationDate,
    required this.reservationTime,
    required this.peopleCount,
    this.notes,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.products,
    this.snapToken,
    this.paymentStatus,
    this.midtransTransactionId,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      reservationDate: DateTime.parse(json['reservation_date']),
      reservationTime: json['reservation_time'],
      peopleCount: json['people_count'],
      notes: json['notes'],
      totalAmount: double.parse(json['total_amount'].toString()),
      paymentMethod: json['payment_method'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      products: (json['products'] as List)
          .map((product) => ReservationProduct.fromJson(product))
          .toList(),
      snapToken: json['snap_token'],
      paymentStatus: json['payment_status'],
      midtransTransactionId: json['midtrans_transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reservation_date': reservationDate.toIso8601String(),
      'reservation_time': reservationTime,
      'people_count': peopleCount,
      'notes': notes,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'products': products.map((product) => product.toJson()).toList(),
      'snap_token': snapToken,
      'payment_status': paymentStatus,
      'midtrans_transaction_id': midtransTransactionId,
    };
  }
}

class ReservationProduct {
  final int id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String image1;
  final String? image2;
  final String? image3;
  final int stock;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReservationProductPivot pivot;

  ReservationProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.image1,
    this.image2,
    this.image3,
    required this.stock,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.pivot,
  });

  factory ReservationProduct.fromJson(Map<String, dynamic> json) {
    return ReservationProduct(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: double.parse(json['price'].toString()),
      description: json['description'],
      image1: json['image1'],
      image2: json['image2'],
      image3: json['image3'],
      stock: json['stock'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      pivot: ReservationProductPivot.fromJson(json['pivot']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'image1': image1,
      'image2': image2,
      'image3': image3,
      'stock': stock,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pivot': pivot.toJson(),
    };
  }
}

class ReservationProductPivot {
  final int reservationId;
  final int productId;
  final int quantity;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReservationProductPivot({
    required this.reservationId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReservationProductPivot.fromJson(Map<String, dynamic> json) {
    return ReservationProductPivot(
      reservationId: json['reservation_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservation_id': reservationId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}