import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Added
import 'package:travelmate/HomeScreen.dart';
import 'package:travelmate/LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double logoScale = 0.7;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Start Animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          logoScale = 1.0;
          opacity = 1.0;
        });
      }
    });

    // ✅ Authentication check before navigation
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() {
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      // Check if a user is already logged in locally
      User? user = FirebaseAuth.instance.currentUser;

      Widget nextScreen = (user != null) ? const HomeScreen() : const LoginScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextScreen,
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
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/bgimg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.7)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: logoScale,
                  duration: const Duration(milliseconds: 800),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}