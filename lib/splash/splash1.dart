import 'package:beeje_mobile/splash/splash2.dart';
import 'package:flutter/material.dart';

class Splash1 extends StatefulWidget {
  const Splash1({super.key});

  @override
  State<Splash1> createState() => _Splash1State();
}

class _Splash1State extends State<Splash1> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.push(context, MaterialPageRoute(builder: (context)=> Splash2()));
    });
  }
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xffFFF7ED),
      body: Center(
        child: Image(
          image: AssetImage('assets/images/logo1.png'),
          width: 210,
          height: 250,
        ),
      ),
    );
  }
}