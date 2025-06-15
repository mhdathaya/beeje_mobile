import 'package:beeje_mobile/Pages/navbar/profile.dart';
import 'package:beeje_mobile/Pages/product_detail_page.dart';
import 'package:beeje_mobile/Pages/promo_page.dart';
import 'package:beeje_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Tambahkan import ini
import '../models/product.dart';
import '../services/product_service.dart';
import 'navbar/notification_page.dart';
import '../services/cart_service.dart'; // Import the cart service
import 'navbar/cart_page.dart'; // Import the CartPage
import '../models/banner.dart' as app_banner; // Tambahkan alias 'app_banner'
import '../services/banner_service.dart';


class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({required this.userName, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   final AuthService _authService = AuthService();
  String _userName = 'User';
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 0;
  List<Product> products = [];
  List<String> categories = ['Semua'];
  bool isLoading = true;
  int _currentBannerIndex = 0;
  PageController _bannerController = PageController();
  String selectedCategory = 'Semua';
  final ProductService productService = ProductService();
  final CartService cartService = CartService(); // Initialize CartService
  bool _hasShownPromoPopup = false; // Tambahkan variabel ini
  
  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
    _fetchBanners();
    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        fetchProducts(search: searchController.text);
      }
    });
    
    // Tampilkan popup iklan hanya jika belum ditampilkan
    if (!_hasShownPromoPopup) {
      Timer(const Duration(seconds: 2), () {
        _showPromoPopup();
        _hasShownPromoPopup = true; // Set flag menjadi true setelah menampilkan popup
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    
    super.dispose();
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await productService.getCategories();
      setState(() {
        categories = ['Semua', ...(fetchedCategories ?? [])];
      });
    } catch (e) {
      setState(() {
        categories = ['Semua'];
      });
    }
  }

  Future<void> fetchProducts({String? search, String? category}) async {
    setState(() => isLoading = true);
    try {
      final paginatedProducts = await productService.getProducts(
        category: category,
        search: search,
      );
      setState(() {
        products = paginatedProducts.products;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching products: $e');
    }
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
    // Pass the category to fetchProducts, but only if it's not "Semua"
    fetchProducts(category: category == 'Semua' ? null : category);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;
    final crossAxisCount = screenSize.width > 600 ? 3 : 2;
    final aspectRatio = screenSize.width > 600 ? 0.8 : 0.65;

    final List<Widget> pages = [
      Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 200),
                const SizedBox(height: 100),
                _buildCategoryFilter(),
                const SizedBox(height: 8),
                _buildProductGrid(padding, crossAxisCount, aspectRatio),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF1F1F1F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: _buildHeader(),
          ),
          Positioned(
            top: 170,
            left: 16,
            right: 16,
            child: _buildPromoBanner(),
          ),
        ],
      ),
      CartPage(userName: widget.userName,), // Pass products list
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF6F4E37),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // Refresh products when returning to home page
            if (index == 0) {
              fetchProducts();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }


  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.userName,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Cari',
                            hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6F4E37),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () {},
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Pada bagian _buildPromoBanner, tambahkan onTap untuk navigasi ke PromoPage
 Widget _buildPromoBanner() {
    // Jika tidak ada banner dan masih loading, tampilkan loading indicator
    if (banners.isEmpty && isLoadingBanners) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF6F4E37),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    
    // Buat list untuk slide
    List<Widget> slides = [];
    
    // Slide pertama: Selamat datang
    slides.add(
      Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF6F4E37),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'WELCOME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        'Selamat Datang, ${widget.userName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.asset(
                'assets/images/Banner..png',
                fit: BoxFit.cover,
                width: 120,
                height: 120,
              ),
            ),
          ],
        ),
      ),
    );
    
    // Tambahkan banner dari backend
    for (var banner in banners) {
      slides.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PromoPage(userName: widget.userName),
              ),
            );
          },
          child: Container(
  height: 120,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
  ),
  clipBehavior: Clip.antiAlias,
  child: Image.network(
    'http://beejee.biz.id/${banner.bannerUrl}',
    width: double.infinity,
    height: 120,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      print('Error loading banner image: $error');
      return Image.asset(
        'assets/images/Banner..png',
        width: double.infinity,
        height: 120,
        fit: BoxFit.cover,
      );
    },
  ),
)


        ),
      );
    }
    
    // Jika tidak ada banner, tambahkan slide default
    if (banners.isEmpty && !isLoadingBanners) {
      slides.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PromoPage(userName: widget.userName),
              ),
            );
          },
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF6F4E37),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PROMO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Flexible(
                          child: Text(
                            'Lihat Semua Promo Menarik',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/Banner..png',
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Tambahkan indikator halaman
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            children: slides,
          ),
        ),
        const SizedBox(height: 8),
        // Indikator halaman
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBannerIndex == index
                    ? const Color(0xFF6F4E37)
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }
    

  Widget _buildCategoryFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: isSelected ? const Color(0xFF6F4E37) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 2,
              child: InkWell(
                onTap: () => onCategorySelected(category),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Ubah deklarasi variabel
  List<app_banner.Banner> banners = [];
  bool isLoadingBanners = false;
  

  
  // Tambahkan fungsi untuk mengambil banner
  Future<void> _fetchBanners() async {
    if (mounted) {
      setState(() {
        isLoadingBanners = true;
      });
    }
    
    try {
      final BannerService bannerService = BannerService();
      // Ubah juga di fungsi _fetchBanners() (sekitar baris 88)
      final List<app_banner.Banner> result = await bannerService.getBanners();
      
      if (mounted) {
        setState(() {
          banners = result;
          isLoadingBanners = false;
        });
      }
    } catch (e) {
      print('Error fetching banners: $e');
      if (mounted) {
        setState(() {
          isLoadingBanners = false;
        });
      }
    }
  }
  
  void _showPromoPopup() {
    // Jika tidak ada banner, jangan tampilkan popup
    if (banners.isEmpty) return;
    
    // Pilih banner pertama atau acak
    final banner = banners.first;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PromoPage(userName: widget.userName),
                          ),
                        );
                      },
                      child: Image.network(
                        'http://beejee.biz.id/${banner.bannerUrl}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading banner image: $error');
                          return Image.asset(
                            'assets/images/Banner..png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.black, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (_) => onCategorySelected(category),
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF6F4E37),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildProductGrid(double padding, int crossAxisCount, double aspectRatio) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: padding,
              crossAxisSpacing: padding,
              childAspectRatio: aspectRatio,
            ),
            padding: EdgeInsets.all(padding),
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductCard(products[index]),
          );
  }

  Widget _buildProductCard(Product product) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product,userName: widget.userName,),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           // In the _buildProductCard method, update the image part:
           AspectRatio(
             aspectRatio: 1,
             child: ClipRRect(
               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
               child: product.firstImage != null 
                   ? Image.network(
                      'http://beejee.biz.id/${product.firstImage}',
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
                     )
                   : _buildErrorImage(),
             ),
           ),

Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(
        child: Text(
          product.name,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      SizedBox(height: isTablet ? 15 : 4),
      Text(
        product.category,
        style: TextStyle(
          fontSize: isTablet ? 10 : 12,
          color: Colors.grey[600],
        ),
      ),
      SizedBox(height: isTablet ? 10 : 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.isPromo && product.promoPrice != null) ...[  
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(product.price),
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(product.promoPrice),
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      color: Color(0xFF6F4E37),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else...[
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(product.price),
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      color: Color(0xFF6F4E37),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 10 : 8,
              vertical: isTablet ? 6 : 4,
            ),
            decoration: BoxDecoration(
              color: Color(0xFF6F4E37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Stock: ${product.stock}',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Color(0xFF6F4E37),
              ),
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

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  // Example function to add a product to the cart
  Future<void> addToCart(Product product) async {
    try {
      await cartService.addToCart(product.id, 1); // Add product to cart with quantity 1
      print('Product added to cart');
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }
}
