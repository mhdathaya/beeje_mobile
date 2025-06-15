import 'package:beeje_mobile/Pages/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/cart_service.dart';

class ReservationPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const ReservationPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final CartService _cartService = CartService();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int numberOfPeople = 2;
  String selectedPaymentMethod = 'bank_transfer';
  String notes = '';
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _showNumberOfPeopleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempNumberOfPeople = numberOfPeople;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Jumlah Orang'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: tempNumberOfPeople > 1
                            ? () {
                                setStateDialog(() {
                                  tempNumberOfPeople--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 32,
                      ),
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tempNumberOfPeople.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: tempNumberOfPeople < 20
                            ? () {
                                setStateDialog(() {
                                  tempNumberOfPeople++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maximum 20 orang',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      numberOfPeople = tempNumberOfPeople;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _processReservation() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Add all items to cart first
      for (var item in widget.cartItems) {
        await _cartService.addToCart(
          int.parse(item['id'].toString()),
          int.parse(item['quantity'].toString()),
        );
      }

      // Process checkout with reservation details
      final result = await _cartService.checkout(
        type: 'reservation',
        paymentMethod: selectedPaymentMethod,
        reservationDate: DateFormat('yyyy-MM-dd').format(selectedDate),
        reservationTime: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
        numberOfPeople: numberOfPeople,
      );

      if (result['payment_url'] != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentPage(),
            settings: RouteSettings(
              arguments: {
                'payment_url': result['payment_url'],
                'order_details': {
                  'products': widget.cartItems,
                  'total_amount': widget.totalAmount,
                  'order_id': result['order_id'],
                  'reservation_date': DateFormat('yyyy-MM-dd').format(selectedDate),
                  'reservation_time': '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  'number_of_people': numberOfPeople,
                  'payment_method': selectedPaymentMethod,
                  'status': result['status'],
                },
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Out'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product info section - Show all cart items
              ...widget.cartItems.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(item['image1'] ?? ''),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? item['product']?['name'] ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Dringin',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          // Cek apakah ada informasi promo dalam item
                          if (item['is_promo'] == true && item['promo_price'] != null) ...[  
                            Row(
                              children: [
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp ',
                                    decimalDigits: 0,
                                  ).format(double.parse((item['price'] ?? item['product']?['price'] ?? 0).toString())),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    "${item['discount_percentage'] ?? ''}%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'id',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(double.parse((item['promo_price'] ?? 0).toString())),
                              style: const TextStyle(
                                fontSize: 14,
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
                              ).format(double.parse((item['price'] ?? item['product']?['price'] ?? 0).toString())),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ]
                        ],
                      ),
                    ),
                    Text(
                      'x${item['quantity']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )).toList(),
              
              const SizedBox(height: 16),
              // Order total
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jumlah Pesanan'),
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(widget.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Reservation date
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Reservasi'),
                          Text(
                            DateFormat('dd MMMM yyyy').format(selectedDate),
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              // Calendar grid
              Container(
                height: 80,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final date = DateTime.now().add(Duration(days: index));
                    final isSelected = date.day == selectedDate.day && 
                                     date.month == selectedDate.month && 
                                     date.year == selectedDate.year;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      child: Container(
                        width: 45,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6F4E37) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(date).substring(0, 3),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Time selection
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 8),
                      const Text('Waktu Reservasi'),
                      const Spacer(),
                      Text(
                        selectedTime.format(context),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              // Number of people
              InkWell(
                onTap: _showNumberOfPeopleDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people, size: 20),
                      const SizedBox(width: 8),
                      const Text('Jumlah Orang'),
                      const Spacer(),
                      Text(
                        '$numberOfPeople orang',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              // Payment method
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => PaymentMethodSheet(
                      selectedMethod: selectedPaymentMethod,
                      onSelect: (method) {
                        setState(() {
                          selectedPaymentMethod = method;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payment, size: 20),
                      const SizedBox(width: 8),
                      const Text('Metode Pembayaran'),
                      const Spacer(),
                      Text(
                        _getPaymentMethodName(selectedPaymentMethod),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Notes
              TextField(
                decoration: InputDecoration(
                  hintText: 'Catatan: jangan lupa yaa',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: const UnderlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    notes = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Order button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading ? null : _processReservation,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Pesan',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'gopay':
        return 'GoPay';
      case 'shopeepay':
        return 'ShopeePay';
      case 'credit_card':
        return 'Credit Card';
      case 'qris':
        return 'QRIS';
      default:
        return 'Transfer Bank';
    }
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildErrorImage();
    }

    // Use the image URL directly if it's already a full URL
    final String fullImageUrl = imageUrl.startsWith('http') 
        ? imageUrl
        : 'http://beejee.biz.id/storage/$imageUrl';

    return Image.network(
      fullImageUrl,
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

  // Replace the existing image widget in the ListView.builder with:
 
}
class PaymentMethodSheet extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onSelect;

  const PaymentMethodSheet({
    super.key,
    required this.selectedMethod,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pilih Metode Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Transfer Bank'),
            leading: const Icon(Icons.account_balance),
            trailing: selectedMethod == 'bank_transfer' 
              ? const Icon(Icons.check, color: Color(0xFF6B4B3E))
              : null,
            selected: selectedMethod == 'bank_transfer',
            onTap: () => onSelect('bank_transfer'),
          ),
          ListTile(
            title: const Text('GoPay'),
            leading: const Icon(Icons.payment),
            trailing: selectedMethod == 'gopay' 
              ? const Icon(Icons.check, color: Color(0xFF6B4B3E))
              : null,
            selected: selectedMethod == 'gopay',
            onTap: () => onSelect('gopay'),
          ),
          ListTile(
            title: const Text('ShopeePay'),
            leading: const Icon(Icons.shopping_bag),
            trailing: selectedMethod == 'shopeepay' 
              ? const Icon(Icons.check, color: Color(0xFF6B4B3E))
              : null,
            selected: selectedMethod == 'shopeepay',
            onTap: () => onSelect('shopeepay'),
          ),
          ListTile(
            title: const Text('Credit Card'),
            leading: const Icon(Icons.credit_card),
            trailing: selectedMethod == 'credit_card' 
              ? const Icon(Icons.check, color: Color(0xFF6B4B3E))
              : null,
            selected: selectedMethod == 'credit_card',
            onTap: () => onSelect('credit_card'),
          ),
          ListTile(
            title: const Text('QRIS'),
            leading: const Icon(Icons.qr_code),
            trailing: selectedMethod == 'qris' 
              ? const Icon(Icons.check, color: Color(0xFF6B4B3E))
              : null,
            selected: selectedMethod == 'qris',
            onTap: () => onSelect('qris'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}