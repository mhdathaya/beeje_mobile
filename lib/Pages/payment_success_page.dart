import 'package:beeje_mobile/Pages/home_page.dart';
import 'package:beeje_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentSuccessPage extends StatelessWidget {
  final Map<String, dynamic> orderDetails;

  const PaymentSuccessPage({super.key, required this.orderDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Berhasil'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Pembayaran Berhasil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Terima kasih telah melakukan pembayaran.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Transaksi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildDetailRow('Status Transaksi', 'Berhasil'),
                  _buildDetailRow('ID Transaksi', orderDetails['order_id'] ?? 'N/A'),
                  _buildDetailRow(
                    'Total', 
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(double.parse(orderDetails['total_amount']?.toString() ?? '0'))
                  ),
                  _buildDetailRow(
                    'Tanggal', 
                    DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  // Import AuthService di bagian atas file
                  final authService = AuthService();
                  try {
                    // Mendapatkan data profil pengguna
                    final userProfile = await authService.getUserProfile();
                    final userName = userProfile['name'] ?? 'User';
                    
                    // Navigasi langsung ke HomePage
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HomePage(userName: userName),
                      ),
                      (route) => false, // Menghapus semua halaman sebelumnya dari stack
                    );
                  } catch (e) {
                    // Jika gagal mendapatkan profil, tetap navigasi dengan nama default
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HomePage(userName: 'User'),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}