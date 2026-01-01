import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Required for StreamBuilder
import 'package:travelmate/AccommodationListScreen.dart';
import 'package:travelmate/ExpenseTrackerScreen.dart';
import 'package:travelmate/SignUpScreen.dart';
import 'package:travelmate/WeatherScreen.dart';
import 'package:travelmate/CalendarScreen.dart';
import 'package:travelmate/LoginScreen.dart';
import 'package:travelmate/HomeScreen.dart';
import 'package:travelmate/CurrencyConverterScreen.dart';
import 'package:travelmate/NewTripScreen.dart';
import 'package:travelmate/SettingsScreen.dart';
import 'package:travelmate/ProfileScreen.dart';
import 'package:travelmate/SplashScreen.dart'; // ✅ Ensure this file exists
import 'auth_service.dart';
import 'package:travelmate/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize(); // ✅ Initialize Firebase

  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint("Notification Init Error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<User?> _checkAuthWithDelay() async {
    // Wait for BOTH the auth state AND a 2-second timer
    final results = await Future.wait([
      FirebaseAuth.instance.authStateChanges().first,
      Future.delayed(const Duration(seconds: 2)),
    ]);
    return results[0] as User?;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TravelMate',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // ✅ Use StreamBuilder to handle auto-login
      home: FutureBuilder<User?>(
        future: _checkAuthWithDelay(),
        builder: (context, snapshot) {
          // Show splash screen while the 2-second timer is running
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          // After 2 seconds, check if we have user data
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }

          // Otherwise, go to Login
          return const LoginScreen();
        },
      ),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/currency': (context) => const CurrencyConverterScreen(),
        '/new-trip': (context) => const NewTripScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/expense': (context) => const ExpenseTrackerScreen(),
        '/accommodation': (context) => const AccommodationListScreen(),
        '/weather': (context) => const WeatherScreen(),
        '/calendar': (context) => const CalendarScreen(),
      },
    );
  }
}