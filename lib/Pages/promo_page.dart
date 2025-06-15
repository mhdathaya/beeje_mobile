import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/promo_service.dart';
import 'product_detail_page.dart';

class PromoPage extends StatefulWidget {
  final String userName;

  const PromoPage({required this.userName, Key? key}) : super(key: key);

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  final PromoService _promoService = PromoService();
  List<Product> promos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPromos();
  }

  Future<void> fetchPromos() async {
    if (isLoading == false) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final result = await _promoService.getPromos();

      setState(() {
        promos = result.products;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching promos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildPromoHeader(context),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : promos.isEmpty
                    ? const Center(child: Text('Tidak ada produk promo'))
                    : _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.only(top: 70, left: 16, right: 16, bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tombol Back
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
            ),
          ],
        ),
        const SizedBox(height: 8), // Spasi antara tombol back dan konten
        // Header Promo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Promo Spesial',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: promos.length,
      itemBuilder: (context, index) {
        final product = promos[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: product,
              userName: widget.userName,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF5D4037),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      product.firstImage != null
                          ? 'http://beejee.biz.id/${product.firstImage}'
                          : 'https://via.placeholder.com/150',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Informasi produk
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menampilkan harga promo jika tersedia
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.promoPrice != null) ...[  
                            Text(
                              '${product.price.toInt()}K',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              '${product.promoPrice!.toInt()}K',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ] else
                            Text(
                              '${product.price.toInt()}K',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: 24,
                        height: 24,
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}