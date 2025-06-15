import 'package:flutter/material.dart';
import 'package:beeje_mobile/Auth/loginpage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          width: screenWidth,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Image.asset(
                'assets/images/splash.png',
                height: screenHeight * 0.45,
                width: screenWidth * 0.85,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenHeight * 0.03),
              const Text(
                'BeeJee Coffe \n Pure Love Of Coffee',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: 'SoraSemibold',
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              const Text(
                "'Satu Gelas Penuh Makna'",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "SoraRegular",
                  color: Color(0xffA2A2A2),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              const Text(
                "Di Beeje Coffee, kami percaya\nbahwa setiap cangkir kopi memiliki\ncerita",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "SoraRegular",
                  color: Color(0xffA2A2A2),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              SizedBox(
                width: screenWidth * 0.6,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffC67C4E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: const Text(
                    "Mulai",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: "SoraRegular",
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
