import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/role');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00A885), Color(0xFF00695C)])),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.storefront, size: 96, color: Colors.white),
            SizedBox(height: 12),
            Text('ShopRadius', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Buy Local. Buy Smart.', style: TextStyle(color: Colors.white70)),
          ]),
        ),
      ),
    );
  }
}
