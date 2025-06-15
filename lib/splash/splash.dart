import 'package:beeje_mobile/splash/splash1.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.push(context, MaterialPageRoute(builder: (context)=> Splash1()));
    });
  }
  Widget build(BuildContext context) {
    return const Scaffold(
    
      backgroundColor: Color(0xFFFFF7ED),
      body: Center(
        child: Image(
          image: AssetImage("assets/images/logo1.png"),
          width: 210,
          height: 250,
          fit: BoxFit.contain,
          
        ),
      ),
    );
  }
}
