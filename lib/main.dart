import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auth service
  await AuthService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TravelMate',
      theme:  ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/currency': (context) => const CurrencyConverterScreen(),
        '/new-trip': (context) => const NewTripScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/expense':  (context) => const ExpenseTrackerScreen(),
        '/accommodation': (context) => const AccommodationListScreen(),
        '/weather': (context) => const WeatherScreen(),
        '/calendar': (context) => const CalendarScreen(),
      },
    );
  }
}