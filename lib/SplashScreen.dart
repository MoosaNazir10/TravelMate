import 'package:flutter/material.dart';
import 'dart:async';

import 'package:travelmate/LoginScreen.dart';
import 'package:travelmate/SignUpScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super. key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double logoScale = 0.7;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Start animation
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        logoScale = 1.0;
        opacity = 1.0;
      });
    });

    // Navigate after 3 seconds with smooth transition
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SignUpScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration:  const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/bgimg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // White Transparent Overlay
          Container(
            color: Colors.white.withOpacity(0.7),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Suitcase Icon
                AnimatedScale(
                  scale: logoScale,
                  duration: const Duration(milliseconds:800),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/image/splashimage.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

    const SizedBox(height: 40),

                // App Name
                AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 1000),
                  child: const Text(
                    "TravelMate",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      letterSpacing: 2,
                    ),
                  ),
                ),


                const SizedBox(height: 20),

                // Loading indicator (optional)

              ],
            ),
          ),
        ],
      ),
    );
  }
}