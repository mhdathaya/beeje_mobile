import 'package:beeje_mobile/Pages/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/cart_service.dart';
import '../../services/raja_ongkir_service.dart';
import '../../models/raja_ongkir_models.dart';

class DeliveryPage extends StatefulWidget {
  final List<Map<String, dynamic>>? cartItems;
  final double? totalAmount;
  final int? totalWeight;

  const DeliveryPage({
    super.key,
    this.cartItems,
    this.totalAmount,
    this.totalWeight,
  });

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final CartService _cartService = CartService();
  final RajaOngkirService _rajaOngkirService = RajaOngkirService();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();
  final TextEditingController _searchCityController = TextEditingController();
  
  String selectedPaymentMethod = 'bank_transfer';
  bool isLoading = false;
  bool isSearchingCity = false;
  bool isCheckingShipping = false;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0;
  int totalWeight = 1000; // Default weight in grams (1kg)
  double shippingCost = 0;
  
  // Origin city (tetap)
  String originCity = 'Lhokseumawe'; // ID kota asal
  String originCityId = '9660'; // ID kota asal
  
  // Destination city (dipilih user)
  City? selectedCity;
  List<City> searchResults = [];
  
  // Courier options
  List<String> courierOptions = ['jne', 'pos', 'tiki'];
  String selectedCourier = 'jne';
  
  // Shipping service
  List<ShippingCost> shippingCosts = [];
  ShippingService? selectedService;
  
  @override
  void initState() {
    super.initState();
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      cartItems = widget.cartItems!;
    } else {
      _fetchCartItems();
    }
    
    if (widget.totalAmount != null) {
      totalAmount = widget.totalAmount!;
    }
    
    if (widget.totalWeight != null) {
      totalWeight = widget.totalWeight!;
    }
  }
  
  Future<void> _fetchCartItems() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final items = await _cartService.fetchCartItems();
      
      setState(() {
        cartItems = items.map((item) => {
          'id': item.productId,
          'name': item.product.name,
          'price': item.product.price.toString(),
          'quantity': item.quantity,
          'image1': item.product.firstImage,
        }).toList();
        
        totalAmount = items.fold(0, (sum, item) => sum + item.subtotal);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  Future<void> _searchCity(String keyword) async {
    if (keyword.length < 3) return;
    
    try {
      setState(() {
        isSearchingCity = true;
      });
      
      final results = await _rajaOngkirService.searchDestination(keyword);
      
      setState(() {
        searchResults = results;
        isSearchingCity = false;
      });
    } catch (e) {
      setState(() => isSearchingCity = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mencari kota: $e')),
      );
    }
  }
  
  Future<void> _checkShippingCost() async {
    if (selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kota tujuan terlebih dahulu')),
      );
      return;
    }
    
    try {
      setState(() {
        isCheckingShipping = true;
      });
      
      final costs = await _rajaOngkirService.checkOngkir(
        origin: originCityId,
        destination: selectedCity!.id,
        weight: totalWeight,
        courier: selectedCourier,
      );
      
      setState(() {
        shippingCosts = costs;
        isCheckingShipping = false;
      });
      
      if (costs.isNotEmpty && costs[0].services.isNotEmpty) {
        _showServiceSelection(costs[0].services);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada layanan pengiriman yang tersedia')),
        );
      }
    } catch (e) {
      setState(() => isCheckingShipping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengecek ongkos kirim: $e')),
      );
    }
  }
  
  void _showServiceSelection(List<ShippingService> services) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Layanan Pengiriman',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ListTile(
                    title: Text('${service.service} - ${service.description}'),
                    subtitle: Text(
                      'Rp ${NumberFormat.currency(
                        locale: 'id',
                        symbol: '',
                        decimalDigits: 0,
                      ).format(service.cost)} (${service.etd} hari)'
                    ),
                    onTap: () {
                      setState(() {
                        selectedService = service;
                        shippingCost = service.cost.toDouble();
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _processDelivery() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat pengiriman harus diisi')),
      );
      return;
    }
    
    if (_recipientNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama penerima harus diisi')),
      );
      return;
    }
    
    if (_recipientPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon penerima harus diisi')),
      );
      return;
    }
    
    if (selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kota tujuan harus dipilih')),
      );
      return;
    }
    
    if (selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan pengiriman harus dipilih')),
      );
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // Add all items to cart first if needed
      if (widget.cartItems != null) {
        for (var item in widget.cartItems!) {
          await _cartService.addToCart(
            int.parse(item['id'].toString()),
            int.parse(item['quantity'].toString()),
          );
        }
      }
      
      // Process checkout with delivery details
      final result = await _cartService.checkout(
        type: 'delivery',
        paymentMethod: selectedPaymentMethod,
        address: _addressController.text,
        recipientName: _recipientNameController.text,
        recipientPhone: _recipientPhoneController.text,
        deliveryNotes: _notesController.text,
        originCity: originCityId,
        destinationCity: selectedCity!.id.toString(),
        courier: selectedCourier,
        service: selectedService!.service,
        shippingCost: shippingCost,
        weight: totalWeight,
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
                  'products': cartItems,
                  'total_amount': totalAmount + shippingCost,
                  'order_id': result['order_id'],
                  'shipping_address': _addressController.text,
                  'recipient_name': _recipientNameController.text,
                  'recipient_phone': _recipientPhoneController.text,
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
  
  Widget _buildProductImage(String? imageUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: imageUrl != null && imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage('http://beejee.biz.id/storage/products/${imageUrl.split('/').last}'),
                fit: BoxFit.cover,
              )
            : null,
        color: Colors.grey[200],
      ),
      child: imageUrl == null || imageUrl.isEmpty
          ? const Icon(Icons.coffee, color: Colors.grey)
          : null,
    );
  }
  
  Widget _buildProductItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(item['image1']),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Dingin',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(double.parse((item['price'] ?? '0').toString())),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'x${item['quantity']}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalWithShipping = totalAmount + shippingCost;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Out'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi Pengiriman
                    const Text(
                      'Informasi Pengiriman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Nama Penerima
                    TextField(
                      controller: _recipientNameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Penerima',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Nomor Telepon Penerima
                    TextField(
                      controller: _recipientPhoneController,
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    
                    // Alamat Lengkap
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Alamat Lengkap',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    
                    // Pencarian Kota
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _searchCityController,
                          decoration: InputDecoration(
                            labelText: 'Cari Kota Tujuan',
                            hintText: 'Ketik minimal 3 huruf',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                            suffixIcon: isSearchingCity 
                                ? const CircularProgressIndicator(strokeWidth: 2)
                                : IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: () => _searchCity(_searchCityController.text),
                                  ),
                          ),
                          onChanged: (value) {
                            if (value.length >= 3) {
                              _searchCity(value);
                            }
                          },
                        ),
                        if (selectedCity != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_city, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedCity!.label.isNotEmpty 
                                          ? selectedCity!.label 
                                          : '${selectedCity!.name}, ${selectedCity!.province}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () {
                                      setState(() {
                                        selectedCity = null;
                                        selectedService = null;
                                        shippingCost = 0;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (searchResults.isNotEmpty && selectedCity == null)
                          Container(
                            height: 200,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                final city = searchResults[index];
                                return ListTile(
                                  title: Text(city.label.isNotEmpty ? city.label : '${city.name} (${city.type})'),
                                  subtitle: Text(city.provinceName.isNotEmpty ? city.provinceName : city.province),
                                  onTap: () {
                                    setState(() {
                                      selectedCity = city;
                                      searchResults = [];
                                      _searchCityController.text = city.cityName.isNotEmpty ? city.cityName : city.name;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Pilih Kurir
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Pilih Kurir',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            value: selectedCourier,
                            items: courierOptions.map((courier) {
                              return DropdownMenuItem(
                                value: courier,
                                child: Text(courier.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedCourier = value;
                                  selectedService = null;
                                  shippingCost = 0;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: selectedCity != null ? _checkShippingCost : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6F4E37),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: isCheckingShipping
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Cek Ongkir'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Informasi Layanan Terpilih
                    if (selectedService != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6F4E37).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.delivery_dining, color: Color(0xFF6F4E37)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Layanan Pengiriman',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${selectedCourier.toUpperCase()} ${selectedService!.service} - ${selectedService!.description}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                  Text(
                                    'Estimasi: ${selectedService!.etd} hari',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'id',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(shippingCost),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Product list
                    const Text(
                      'Pesanan Anda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ...cartItems.map((item) => _buildProductItem(item)).toList(),
                    
                    const SizedBox(height: 20),
                    
                    // Metode Pembayaran
                    InkWell(
                      onTap: () {
                        // Show payment method selection dialog
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Pilih Metode Pembayaran',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: const Icon(Icons.account_balance),
                                  title: const Text('Transfer Bank'),
                                  trailing: selectedPaymentMethod == 'bank_transfer'
                                      ? const Icon(Icons.check_circle, color: Colors.green)
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      selectedPaymentMethod = 'bank_transfer';
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.payment),
                                  title: const Text('Gopay'),
                                  trailing: selectedPaymentMethod == 'gopay'
                                      ? const Icon(Icons.check_circle, color: Colors.green)
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      selectedPaymentMethod = 'gopay';
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.payment),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Metode Pembayaran',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    selectedPaymentMethod == 'bank_transfer'
                                        ? 'Transfer Bank'
                                        : 'Gopay',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Catatan
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Catatan: Banyak es batu yaa',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Ringkasan Pembayaran
                    const Text(
                      'Ringkasan Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Produk'),
                        Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(totalAmount),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pengiriman'),
                        Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(shippingCost),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jumlah Pembayaran',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(totalWithShipping),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6F4E37),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jumlah Pembayaran:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalWithShipping),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6F4E37),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : _processDelivery,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F4E37),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Pesan',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
// Ganti kode yang ada dengan ini

