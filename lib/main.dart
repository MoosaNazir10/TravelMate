import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:travelmate/SplashScreen.dart';
import 'auth_service.dart';
import 'package:travelmate/services/notification_service.dart';
import 'package:travelmate/VerifyEmailScreen.dart'; // ✅ Ensure this is imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();

  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint("Notification Init Error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This logic ensures the splash screen stays for 2 seconds and refreshes the user data
  Future<User?> _checkAuthWithDelay() async {
    final user = FirebaseAuth.instance.currentUser;

    // ✅ CRITICAL: Refresh the user data from Firebase to check the latest verification status
    if (user != null) {
      await user.reload();
    }

    final results = await Future.wait([
      Future.value(FirebaseAuth.instance.currentUser), // Get the reloaded user
      Future.delayed(const Duration(seconds: 2)),      // Mandatory splash delay
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
      home: FutureBuilder<User?>(
        future: _checkAuthWithDelay(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          final User? user = snapshot.data;

          if (user != null) {
            // ✅ CHECK: If logged in but NOT verified, force them to the Verify Screen
            if (user.emailVerified) {
              return const HomeScreen();
            } else {
              return const VerifyEmailScreen();
            }
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
        '/verify-email': (context) => const VerifyEmailScreen(),
      },
    );
  }
}