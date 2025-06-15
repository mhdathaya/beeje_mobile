import 'package:beeje_mobile/Pages/home_page.dart';
import 'package:beeje_mobile/Pages/order/checkout.dart';
import 'package:flutter/material.dart';
import '../../models/cart.dart';
import '../../services/cart_service.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  final String userName;

  const CartPage({Key? key, required this.userName}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService cartService = CartService();
  List<Cart> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final items = await cartService.fetchCartItems();
      
      // Debug: Periksa status promo dan harga untuk setiap item
      List<Cart> updatedItems = [];
      for (var item in items) {
        print('Product: ${item.product.name}');
        print('isPromo: ${item.product.isPromo}');
        print('promoPrice: ${item.product.promoPrice}');
        print('normalPrice: ${item.product.price}');
        
        // Pastikan produk dengan harga promo dikenali sebagai produk promo
        if (item.product.promoPrice != null && item.product.promoPrice! > 0) {
          bool shouldBePromo = true;
          double? newDiscountPercentage = item.product.discountPercentage;
          
          // Hitung persentase diskon jika belum dihitung
          if (item.product.discountPercentage == 0) {
            double discount = ((item.product.price - item.product.promoPrice!) / item.product.price) * 100;
            newDiscountPercentage = discount.round().toDouble();
          }
          
          // Buat objek Product baru dengan nilai yang diperbarui
          Product updatedProduct = Product(
            id: item.product.id,
            name: item.product.name,
            price: item.product.price,
            stock: item.product.stock,
            category: item.product.category,
            images: item.product.images,
            isPromo: shouldBePromo,
            promoPrice: item.product.promoPrice,
            discountPercentage: newDiscountPercentage,
          );
          
          // Buat objek Cart baru dengan produk yang diperbarui
          Cart updatedCart = Cart(
            id: item.id,
            userId: item.userId,
            productId: item.productId,
            quantity: item.quantity,
            subtotal: item.subtotal,
            product: updatedProduct,
          );
          
          updatedItems.add(updatedCart);
        } else {
          updatedItems.add(item);
        }
      }

      setState(() {
        cartItems = updatedItems;
        isLoading = false;
      });

      // Hitung subtotal
      double subtotal = 0;
      for (var item in cartItems) {
        // Gunakan harga promo jika tersedia, jika tidak gunakan harga normal
        double itemPrice = (item.product.isPromo && item.product.promoPrice != null)
            ? item.product.promoPrice!
            : item.product.price;
        subtotal += itemPrice * item.quantity;
      }

      print('Subtotal: $subtotal');
    } catch (e) {
      print('Error fetching cart items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateQuantity(int index, bool increment) async {
    final item = cartItems[index];
    final newQuantity = increment ? item.quantity + 1 : item.quantity - 1;
    if (newQuantity > 0) {
      try {
        await cartService.updateCartItem(item.id, newQuantity);
        setState(() {
          // Hitung subtotal berdasarkan harga promo jika tersedia
          final price = (item.product.isPromo && item.product.promoPrice != null)
              ? item.product.promoPrice!
              : item.product.price;
          
          cartItems[index] = Cart(
            id: item.id,
            userId: item.userId,
            productId: item.productId,
            quantity: newQuantity,
            subtotal: price * newQuantity,
            product: item.product,
          );
        });
      } catch (e) {
        print('Error updating cart item: $e');
      }
    }
  }

  Future<void> removeItem(int index) async {
    final item = cartItems[index];
    try {
      await cartService.deleteCartItem(item.id);
      setState(() {
        cartItems.removeAt(index);
      });
    } catch (e) {
      print('Error deleting cart item: $e');
    }
  }

  double get totalAmount {
    return cartItems.fold(
      0.0,
      (sum, item) => sum +
          ((item.product.isPromo && item.product.promoPrice != null)
              ? item.product.promoPrice! * item.quantity
              : item.product.price * item.quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userName: widget.userName),
            ),
          ),
        ),
        title: const Text(
          'Keranjang Saya',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildProductImage(item.product.firstImage),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Tampilkan harga produk (sudah harga promo jika produk promo)
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp ',
                                      decimalDigits: 0,
                                    ).format(item.product.price * item.quantity),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6F4E37),
                                    ),
                                  ),
                                  // Tampilkan label diskon jika produk promo
                                  if (item.product.isPromo && item.product.discountPercentage != null) ...[  
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            "${item.product.discountPercentage}%",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] 
                                  // Hapus bagian kode duplikat yang tidak diperlukan lagi
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () =>
                                      updateQuantity(index, false),
                                  color: const Color(0xFF6F4E37),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => updateQuantity(index, true),
                                  color: const Color(0xFF6F4E37),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => removeItem(index),
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              NumberFormat.currency(
                                locale: 'id',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(totalAmount),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6F4E37),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Checkout(
                                cartItems: cartItems.map((item) {
                                  return {
                                    'id': item.product.id,
                                    'name': item.product.name,
                                    'price': (item.product.isPromo &&
                                            item.product.promoPrice != null)
                                        ? item.product.promoPrice
                                        : item.product.price,
                                    'quantity': item.quantity,
                                    'image1': item.product.firstImage,
                                    'is_promo': item.product.isPromo,
                                    'promo_price': item.product.promoPrice,
                                    'discount_percentage':
                                        item.product.discountPercentage,
                                  };
                                }).toList(),
                                totalAmount: totalAmount,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6F4E37),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Check Out'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildErrorImage();
    }

    return Image.network(
      imageUrl,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $error');
        return _buildErrorImage();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildErrorImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
