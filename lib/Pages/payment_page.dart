import 'package:beeje_mobile/Pages/payment_success_page.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart'; // Tambahkan import ini

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late WebViewController _controller;
  bool isLoading = true;
  String? _error;
  Map<String, dynamic>? orderDetails;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initWebView();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pembayaran Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Terima kasih telah melakukan pembayaran.'),
              const SizedBox(height: 12),
              const Text('Status Transaksi: Berhasil', style: TextStyle(fontWeight: FontWeight.bold)),
              if (orderDetails != null) ...[  
                const SizedBox(height: 8),
                Text('ID Transaksi: ${orderDetails!['order_id'] ?? 'N/A'}'),
                const SizedBox(height: 4),
                Text('Total: ${NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(double.parse(orderDetails!['total_amount']?.toString() ?? '0'))}'),
                const SizedBox(height: 4),
                Text('Tanggal: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}'),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop({'status': 'success'}); // Close payment page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _initWebView() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final paymentUrl = args?['payment_url'] as String? ?? '';
    orderDetails = args?['order_details'] as Map<String, dynamic>?;

    if (paymentUrl.isEmpty || !Uri.parse(paymentUrl).hasScheme) {
      setState(() {
        _error = 'Invalid payment URL';
      });
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            
            // Check if the URL contains success indicator
            if (url.contains('payment/success') || url.contains('status_code=200')) {
              // Navigasi ke halaman sukses setelah pembayaran berhasil
              if (orderDetails != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PaymentSuccessPage(orderDetails: orderDetails!),
                  ),
                );
              }
            } else if (url.contains('payment/failed')) {
              Navigator.of(context).pop({'status': 'failed'});
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle deep links or specific URLs
            if (request.url.startsWith('gojek://') || 
                request.url.startsWith('shopeeid://') ||
                request.url.startsWith('gopay://')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));
  }

  Widget _buildOrderDetails() {
    if (orderDetails == null) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Detail Pesanan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (orderDetails!['products'] != null) ...
            (orderDetails!['products'] as List).map((product) {
              final price = double.parse(product['price'].toString());
              final quantity = int.parse(product['quantity'].toString());
              final totalPrice = price * quantity;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(product['name'] ?? ''),
                    ),
                    Text('${product['quantity']}x ${currencyFormat.format(price)}'),
                  ],
                ),
              );
            }).toList(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran'),
              Text(
                currencyFormat.format(double.parse(orderDetails!['total_amount'].toString())),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildOrderDetails(),
                Expanded(
                  child: Stack(
                    children: [
                      WebViewWidget(controller: _controller),
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}