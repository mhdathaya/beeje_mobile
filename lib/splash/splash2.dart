import 'package:beeje_mobile/splash/onboarding.dart';
import 'package:flutter/material.dart';

class Splash2 extends StatefulWidget {
  const Splash2({super.key});

  @override
  State<Splash2> createState() => _Splash2State();
}

class _Splash2State extends State<Splash2> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Onboarding()));
    });
  }
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xffFFF7ED),
      body: Center(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(70)),
            Image(
              image: AssetImage('assets/images/logo1.png'),
              width: 210,
              height: 250,
            ),
            SizedBox(height: 20),
            Text(
              "Welcome to Beeje Coffee",
              style: TextStyle(
                color: Color(0xff6F4E37),
                fontSize: 29,
                fontFamily: 'PlayfairDisplayBold',
              ),
            ),
            SizedBox(height: 20),
            Text(
              '"Your daily dose of happiness ☕ "',
              style: TextStyle(
                color: Color(0xff6F4E37),
                fontSize: 16,
                fontFamily: 'PoppinsRegular',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
