class Product {
  final int id;
  final String name;
  final String description;
  final String category;
  final String status;
  final int stock;
  final Map<String, String>? images;
  final double price;
  final DateTime createdAt;
  final bool isPromo; // Tambahan untuk promo
  final double? promoPrice; // Tambahan untuk harga promo
  final String? formattedPrice; // Tambahan untuk format harga
  final String? formattedPromoPrice; // Tambahan untuk format harga promo
  final double? discountPercentage; // Tambahan untuk persentase diskon

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.stock,
    this.images,
    required this.price,
    required this.createdAt,
    this.isPromo = false,
    this.promoPrice,
    this.formattedPrice,
    this.formattedPromoPrice,
    this.discountPercentage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    print('Product JSON: $json');
    Map<String, String>? processedImages;
    if (json['images'] != null) {
      processedImages = {};
      (json['images'] as Map<String, dynamic>).forEach((key, value) {
        // Keep the storage prefix and ensure proper path format
        String path = value.toString().replaceAll('\\/', '/');
        processedImages![key] = path;
      });
    }
    
    // Hitung persentase diskon jika ada harga promo
    double? discountPercentage;
    if (json['promo_price'] != null && json['price'] != null) {
      final price = double.parse(json['price'].toString());
      final promoPrice = double.parse(json['promo_price'].toString());
      if (price > 0) {
        discountPercentage = ((price - promoPrice) / price) * 100;
      }
    }
    
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      stock: json['stock'],
      status: json['status'],
      images: processedImages,
      price: double.parse(json['price'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      isPromo: json['is_promo'] == true || json['is_promo'] == 1,
      promoPrice: json['promo_price'] != null ? double.parse(json['promo_price'].toString()) : null,
      formattedPrice: json['formatted_price'],
      formattedPromoPrice: json['formatted_promo_price'],
      discountPercentage: discountPercentage,
    );
  }

  // Helper method to get the first image
  String? get firstImage {
    print('Product images: $images');
    if (images?.values.isNotEmpty == true) {
      final imagePath = images!.values.first;
      return imagePath;
    }
    return null;
  }
}

class PaginatedProducts {
  final List<Product> products;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;

  PaginatedProducts({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    var productList = (json['data'] as List)
        .map((productJson) => Product.fromJson(productJson))
        .toList();

    return PaginatedProducts(
      products: productList,
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      nextPageUrl: json['next_page_url'],
    );
  }
}
