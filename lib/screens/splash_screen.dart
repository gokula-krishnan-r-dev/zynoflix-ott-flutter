import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../config/app_config.dart';
import 'webview_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.title, this.logoImage});

  final String title;
  final ui.Image? logoImage;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // Navigate to the main screen after the splash animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(title: widget.title),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/images/newlogo.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
