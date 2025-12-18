import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/bgimg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay
          Container(color: Colors.white.withOpacity(0.7)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 40),

                buildItem(Icons.notifications, Colors.amber, "Notifications"),
                buildItem(Icons.palette, Colors.green, "Themes"),
                buildItem(Icons.info, Colors.green, "About App"),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation (same as home)
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildNavItem(Icons.home, "Home", () {
              Navigator.pushReplacementNamed(context, '/home');
            }),
            buildNavItem(Icons.map, "Map", () {}),
            buildNavItem(Icons.settings, "Settings", () {}),
            buildNavItem(Icons.person, "Profile", () {}),
          ],
        ),
      ),
    );
  }

  Widget buildItem(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 20),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNavItem(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green),
          Text(label, style: const TextStyle(color: Colors.green)),
        ],
      ),
    );
  }
}