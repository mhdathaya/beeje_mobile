import 'package:beeje_mobile/splash/home.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingPages = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': 'ORDER YOUR COFFEE IN SECONDS',
      'desc':
          'Ngopi jadi makin asik bareng Beeje Coffee\nPilih, pesan, dan ambil kopi favoritmu\ntanpa antri',
    },
    {
      'image': 'assets/images/onboarding2.png',
      'title': 'SHOP YOUR FAVORITE COFFEE',
      'desc':
          'Dari bubuk kopi premium hingga\nminuman siap saji, semua tersedia di satu tempat',
    },
    {
      'image': 'assets/images/onboarding3.png',
      'title': 'FROM OUR STORE TO YOUR DOOR',
      'desc':
          'Pesananmu dikirim cepat dan aman.\nSiap nikmati kopi terbaik kapan saja',
    },
  ];

  void _nextOrFinish() {
    if (_currentIndex < onboardingPages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
      );
    }
  }

  void _skipToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1E6),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: PageView.builder(
              controller: _controller,
              itemCount: onboardingPages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return buildPageContent(
                  image: onboardingPages[index]['image']!,
                  title: onboardingPages[index]['title']!,
                  desc: onboardingPages[index]['desc']!,
                  isLastPage: index == onboardingPages.length - 1,
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: _currentIndex < onboardingPages.length - 1
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _skipToHome,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.brown,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _nextOrFinish,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.brown,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(), // kosongkan di halaman terakhir
          ),
        ],
      ),
    );
  }

  Widget buildPageContent({
    required String image,
    required String title,
    required String desc,
    required bool isLastPage,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: "PoppinsSemiBold",
                    color: Color(0xFF6F4E37),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xff444444),
                    fontFamily: "PoppinsRegular",
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(onboardingPages.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Colors.brown
                            : Colors.brown.withOpacity(0.3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 150),
                if (isLastPage)
                  ElevatedButton(
                    onPressed: _skipToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                    ),
                    child: const Text(
                      'Start Ordering',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "PoppinsSemiBold",
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
