import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Failsafe: Navigate after 4 seconds regardless of animation state.
    // This prevents getting stuck if the Lottie file fails to load.
    Future.delayed(const Duration(seconds: 4), () {
      // Check if the widget is still in the tree before navigating.
      if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLottieLoaded(LottieComposition composition) {
    _controller
      ..duration = composition.duration
      ..forward().whenComplete(() {
        // Check if mounted to avoid calling Navigator on a disposed widget.
        if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/store.json',
                height: 160,
                controller: _controller,
                onLoaded: _onLottieLoaded,
              ),
              const SizedBox(height: 14),
              const Text("ShopRadius", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text("Buy Local. Buy Smart.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
