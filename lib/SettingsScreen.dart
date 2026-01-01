import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Ensure this is imported
import 'package:travelmate/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  // Load saved preference
  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNotificationEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  // Toggle and save preference
  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _isNotificationEnabled = value;
    });

    if (value) {
      await NotificationService.showNotification(
        title: "Notifications Enabled",
        body: "You will now receive alerts for your travel updates.",
      );
    }
  }

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
          Container(color: Colors.white.withOpacity(0.7)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Settings",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 40),

                // ✅ Notification Toggle
                buildToggleItem(
                    Icons.notifications,
                    Colors.amber,
                    "Notifications",
                    _isNotificationEnabled,
                        (val) => _toggleNotifications(val)
                ),

                buildItem(Icons.palette, Colors.green, "Themes"),
                buildItem(Icons.info, Colors.green, "About App"),
              ],
            ),
          ),
        ],
      ),
      // ✅ Now correctly calls the defined method
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ✅ The missing _buildBottomNav method
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, "Home", () {
            Navigator.pushReplacementNamed(context, '/home');
          }),
          _buildNavItem(Icons.map, "Map", () {
            // Add map navigation if needed
          }),
          _buildNavItem(Icons.settings, "Settings", () {
            // Already here
          }),
          _buildNavItem(Icons.person, "Profile", () {
            Navigator.pushReplacementNamed(context, '/profile');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green),
          Text(label, style: const TextStyle(color: Colors.green, fontSize: 12)),
        ],
      ),
    );
  }

  Widget buildToggleItem(IconData icon, Color color, String text, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 20),
            Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const Spacer(),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.green,
            ),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 20),
            Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}