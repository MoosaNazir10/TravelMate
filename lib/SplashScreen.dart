import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/bgimg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // White Overlay
          Container(
            color: Colors.white.withOpacity(0.7),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Suitcase Icon
                const Icon(
                  Icons.work,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),

                // Globe Icon
                const Icon(
                  Icons.public,
                  size: 60,
                  color: Colors.green,
                ),
                const SizedBox(height: 30),

                // App Name
                const Text(
                  "TripUp",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 50),

                // Loading Indicator
                const CircularProgressIndicator(
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
