import 'package:flutter/material.dart';
import 'package:travelmate/AccommodationListScreen.dart';
import 'package:travelmate/CalendarScreen.dart';
import 'package:travelmate/ExpenseTrackerScreen.dart';
import 'package:travelmate/MapScreen.dart';
import 'package:travelmate/WeatherScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

          // White Transparent Overlay
          Container(
            color: Colors.white.withOpacity(0.7),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 35),

                  // FEATURE BUTTONS GRID
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Wrap(
                      spacing: 20, // Horizontal gap
                      runSpacing: 20, // Vertical gap
                      children: [
                        _buildFeatureButton(
                          context,
                          "New Trip",
                          Icons.add_location_alt,
                          '/new-trip',
                        ),
                        _buildFeatureButton(
                          context,
                          "Currency",
                          Icons.currency_exchange,
                          '/currency',
                        ),
                        _buildFeatureButton(
                          context,
                          "Expenses",
                          Icons.account_balance_wallet,
                          null,
                          destination: const ExpenseTrackerScreen(),
                        ),
                        _buildFeatureButton(
                          context,
                          "Weather",
                          Icons.cloud_sync,
                          null,
                          destination: const WeatherScreen(),
                        ),
                        _buildFeatureButton(
                          context,
                          "Hotels",
                          Icons.hotel,
                          null,
                          destination: const AccommodationListScreen(),
                        ),
                        _buildFeatureButton(
                          context,
                          "Calendar",
                          Icons.calendar_month,
                          null,
                          destination: const CalendarScreen(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(Icons.home, "Home"),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(
                      accommodations: [],
                      showWeather: false,
                    ),
                  ),
                );
              },
              child: _buildBottomNavItem(Icons.map, "Map"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: _buildBottomNavItem(Icons.settings, "Settings"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: _buildBottomNavItem(Icons.person, "Profile"),
            ),
          ],
        ),
      ),
    );
  }

  // RE-DESIGNED FEATURE BUTTON
  Widget _buildFeatureButton(
      BuildContext context,
      String text,
      IconData icon,
      String? route, {
        Widget? destination,
      }) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        } else if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4, // Responsive width
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white, // Changed from green to white for contrast
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.green, size: 30),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.green, fontSize: 14),
        ),
      ],
    );
  }
}