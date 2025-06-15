import 'package:beeje_mobile/Pages/order/checkout.dart';
import 'package:beeje_mobile/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import 'package:beeje_mobile/Pages/navbar/cart_page.dart'; // Import the cart page

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final String userName;
  

  const ProductDetailPage({required this.product, required this.userName, Key? key}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  final CartService cartService = CartService();

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = widget.product.images?.values.toList() ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_rounded, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(userName: widget.userName),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 300,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: imageUrls.isNotEmpty
                                    ? Image.network(
                                        'http://beejee.biz.id/${imageUrls[index]}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildErrorImage(),
                                      )
                                    : _buildErrorImage(),
                              ),
                            );
                          },
                        ),
                        if (imageUrls.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                imageUrls.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? const Color(0xFF6F4E37)
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.star, size: 16, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    '4.8',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (widget.product.isPromo && widget.product.promoPrice != null) ...[  
                          Row(
                            children: [
                              Text(
                                NumberFormat.currency(
                                  locale: 'id',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(widget.product.price),
                                style: const TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "${widget.product.discountPercentage}%",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(widget.product.promoPrice),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6F4E37),
                            ),
                          ),
                        ] else ...[
                          Text(
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(widget.product.price),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6F4E37),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description ?? 'No description available',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6F4E37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xFF6F4E37),
                    ),
                    onPressed: () async {
                      try {
                        await cartService.addToCart(widget.product.id, 1);
                        print('Product added to cart');
                      } catch (e) {
                        print('Error adding to cart: $e');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await cartService.addToCart(widget.product.id, 1);
                        print('Product added to cart');
                        
                        // Navigasi ke halaman checkout setelah menambahkan produk ke keranjang
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Checkout(
                              cartItems: [
                                {
                                  'id': widget.product.id,
                                  'name': widget.product.name,
                                  'price': (widget.product.isPromo && widget.product.promoPrice != null)
                                      ? widget.product.promoPrice
                                      : widget.product.price,
                                  'quantity': 1,
                                  'image1': widget.product.images?.values.isNotEmpty == true
                                      ? 'http://beejee.biz.id/${widget.product.images!.values.first}'
                                      : null,
                                  'is_promo': widget.product.isPromo,
                                  'promo_price': widget.product.promoPrice,
                                  'discount_percentage': widget.product.discountPercentage,
                                }
                              ],
                              totalAmount: (widget.product.isPromo && widget.product.promoPrice != null)
                                  ? widget.product.promoPrice!
                                  : widget.product.price,
                            ),
                          ),
                        );
                      } catch (e) {
                        print('Error adding to cart: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F4E37),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Beli Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6F4E37) : Colors.transparent,
        border: Border.all(
          color: const Color(0xFF6F4E37),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF6F4E37),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
