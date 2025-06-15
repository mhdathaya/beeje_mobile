class Cart {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final double subtotal;
  final Product product;

  Cart({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.subtotal,
    required this.product,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      subtotal: double.parse((json['subtotal'] ?? 0).toString()),
      product: Product.fromJson(json['product'] ?? {}),
    );
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final Map<String, String>? images;
  final bool isPromo; // Tambahan untuk promo
  final double? promoPrice; // Tambahan untuk harga promo
  final double? discountPercentage; // Tambahan untuk persentase diskon

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    this.images,
    this.isPromo = false,
    this.promoPrice,
    this.discountPercentage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    Map<String, String>? processedImages;
    if (json['images'] != null) {
      processedImages = Map<String, String>.from(json['images']);
    }
  
    // Debug info
    print('Product JSON in Cart: $json');
    
    // Hitung persentase diskon jika ada harga promo
    double? discountPercentage;
    if (json['promo_price'] != null && json['price'] != null) {
      final price = double.parse(json['price'].toString());
      final promoPrice = double.parse(json['promo_price'].toString());
      if (price > 0) {
        discountPercentage = ((price - promoPrice) / price) * 100;
      }
    }
  
    // Pastikan is_promo diproses dengan benar
    bool isPromo = false;
    if (json['is_promo'] != null) {
      isPromo = json['is_promo'] == true || 
               json['is_promo'] == 1 || 
               json['is_promo'] == '1' || 
               json['is_promo'].toString().toLowerCase() == 'true';
    }
    
    // Jika ada promo_price tapi is_promo tidak diset, anggap sebagai promo
    if (!isPromo && json['promo_price'] != null) {
      double normalPrice = json['price'] != null ? double.parse(json['price'].toString()) : 0.0;
      double promoPrice = double.parse(json['promo_price'].toString());
      if (promoPrice > 0 && promoPrice < normalPrice) {
        isPromo = true;
      }
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      images: processedImages,
      isPromo: isPromo,
      promoPrice: json['promo_price'] != null ? double.parse(json['promo_price'].toString()) : null,
      discountPercentage: discountPercentage,
    );
  }

  String? get firstImage => images?.values.isNotEmpty == true ? images!.values.first : null;
}