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
              image:  DecorationImage(
                image: AssetImage("assets/image/bgimg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // White Transparent Overlay
          Container(
            color: Colors.white. withOpacity(0.7),
          ),

          // MAIN CONTENT
          SafeArea(
            child: SingleChildScrollView(
              child:  Column(
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
                        // Row 1: New Trip & Notes
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

                        // Row 2: Currency Converter & Track Expenses
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/currency');
                              },
                              child: buildFeature("Currency Converter"),
                            ),
                            const SizedBox(width:  20),
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

                        // Row 3: Weather & Accommodation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WeatherScreen(),
                                  ),
                                );
                              },
                              child: buildFeature("Weather"),
                            ),
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

                        // Row 4: Calendar (single item)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator. push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CalendarScreen(),
                                  ),
                                );
                              },
                              child: buildFeature("Calendar"),
                            ),
                            const SizedBox(width: 20),
                            const SizedBox(width: 135), // Empty space to match layout
                          ],
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
          mainAxisAlignment: MainAxisAlignment. spaceEvenly,
          children: [
            buildBottomNavItem(Icons.home, "Home"),
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
              child: buildBottomNavItem(Icons.map, "Map"),
            ),            GestureDetector(
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

  // WIDGET:  Feature Button Grid Tile
  Widget buildFeature(String text) {
    return Container(
      width: 135,
      height:  110,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize:  15,
            fontWeight:  FontWeight.w600,
            color: Colors.yellow,
          ),
        ),
      ),
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
          style: const TextStyle(color:  Colors.green, fontSize: 14),
        ),
      ],
    );
  }
}