import 'package:flutter/material.dart';
import 'AccommodationListScreen.dart';
import 'ExpenseTrackerScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BODY
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

          // MAIN CONTENT
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

                  // FEATURE BUTTONS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/new-trip');
                              },
                              child: buildFeature("New Trip"),
                            ),
                            const SizedBox(width: 20),
                            buildFeature("Notes"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/currency');
                              },
                              child: buildFeature("Currency Converter"),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ExpenseTrackerScreen(),
                                  ),
                                );
                              },
                              child: buildFeature("Track Expenses"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildFeature("Weather"),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AccommodationListScreen(),
                                  ),
                                );
                              },
                              child: buildFeature("Accommodation"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        buildFeatureRow("Calendar", ""),
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
            buildBottomNavItem(Icons.home, "Home"),
            buildBottomNavItem(Icons.map, "Map"),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: buildBottomNavItem(Icons.settings, "Settings"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: buildBottomNavItem(Icons.person, "Profile"),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: Feature Button Grid Tile
  Widget buildFeature(String text) {
    return Container(
      width: 135,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.yellow,
          ),
        ),
      ),
    );
  }

  // WIDGET: Two-Column Row
  Widget buildFeatureRow(String left, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildFeature(left),
        const SizedBox(width: 20),
        right.isNotEmpty ? buildFeature(right) : const SizedBox(width: 135),
      ],
    );
  }

  // WIDGET: Bottom Navigation Item
  Widget buildBottomNavItem(IconData icon, String label) {
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
