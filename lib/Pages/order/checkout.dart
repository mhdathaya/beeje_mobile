import 'package:beeje_mobile/Pages/order/delivery_page.dart' ;
import 'package:beeje_mobile/Pages/order/reservation_page.dart';
import 'package:flutter/material.dart';
import 'package:beeje_mobile/services/order_service.dart';

class Checkout extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const Checkout({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  String? selectedOrderMethod;
  final OrderService orderService = OrderService();

  void selectOrderMethod(String method) {
    setState(() {
      selectedOrderMethod = method;
    });
    // Navigate to the next page with the selected method
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(orderMethod: method),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row for Back button and Title
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back_ios, size: 24),
                    ),
                    const SizedBox(width: 20), // Add some space between icon and text
                    const Text(
                      'Metode Pemesanan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
             

              const SizedBox(height: 50
              ),

              // Deskripsi
              const Text(
                'Pilih Metode Pemesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mau menikmati kopi favoritmu dengan nyaman?\nPilih metode pemesanan yang sesuai!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // Tombol-tombol
              Center(
                child: Column(
                  children: [
                  
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReservationPage(
                              cartItems: widget.cartItems.map((item) => {
                                'id': item['id'],
                                'name': item['name'],
                                'price': item['price']?.toString() ?? '0',
                                'quantity': item['quantity'],
                                'image1': item['image1'], // Changed from 'image' to 'image1'
                                'is_promo': item['is_promo'] ?? false,
                                'promo_price': item['promo_price']?.toString(),
                                'discount_percentage': item['discount_percentage'],
                              }).toList(),
                              totalAmount: widget.totalAmount,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F4E37),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reservasi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Calculate total weight (assuming each item weighs 250 grams)
                        final totalWeight = widget.cartItems.fold<int>(
                          0,
                          (sum, item) => sum + ((item['quantity'] as int) * 250),
                        );
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeliveryPage(
                              cartItems: widget.cartItems,
                              totalAmount: widget.totalAmount,
                              totalWeight: totalWeight,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F4E37),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Delivery',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final String orderMethod;

  const OrderDetailsPage({super.key, required this.orderMethod});

  @override
  Widget build(BuildContext context) {
    // This will be your next page to handle order details
    return Scaffold(
      // Implement the order details page
    );
  }
}
