import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelmate/services/firebase_service.dart';
import 'google_calendar_service.dart';
import 'device_calendar_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  // Local connection state (Permissions are still device-specific)
  bool _isGoogleConnected = false;
  bool _isDeviceConnected = false;

  @override
  void initState() {
    super.initState();
    _checkDevicePermissions();
  }

  void _checkDevicePermissions() {
    setState(() {
      _isGoogleConnected = GoogleCalendarService.isSignedIn;
      _isDeviceConnected = DeviceCalendarService.hasPermission;
    });
  }

  // Update settings in Firebase
  Future<void> _updateSetting(
    String key,
    bool value,
    Map<String, dynamic> currentSettings,
  ) async {
    currentSettings[key] = value;
    await _firebaseService.updateCalendarSettings(currentSettings);
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
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firebaseService.getCalendarSettings(),
              builder: (context, snapshot) {
                // Default settings if none exist in Firebase yet
                Map<String, dynamic> settings = {
                  'autoSyncTravel': true,
                  'syncAccommodations': true,
                  'enableNotifications': false,
                };

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  if (data.containsKey('calendarSettings')) {
                    settings = data['calendarSettings'];
                  }
                }

                return Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildCalendarSection(),
                          const SizedBox(height: 24),
                          _buildSettingsSection(settings),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.green),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Calendar Sync",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Connect Accounts",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _ConnectionCard(
          title: 'Google Calendar',
          subtitle: 'Sync with your Google account',
          icon: Icons.calendar_month,
          isConnected: _isGoogleConnected,
          onConnect: () async {
            setState(() => _isLoading = true);
            final success = await GoogleCalendarService.signIn();
            setState(() {
              _isGoogleConnected = success;
              _isLoading = false;
            });
          },
          onDisconnect: () async {
            await GoogleCalendarService.signOut();
            setState(() => _isGoogleConnected = false);
          },
        ),
        const SizedBox(height: 12),
        _ConnectionCard(
          title: 'Device Calendar',
          subtitle: 'Sync with your phone\'s calendar',
          icon: Icons.phone_android,
          isConnected: _isDeviceConnected,
          onConnect: () async {
            final granted = await DeviceCalendarService.requestPermissions();
            setState(() => _isDeviceConnected = granted);
          },
          onDisconnect: () => setState(() => _isDeviceConnected = false),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(Map<String, dynamic> settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sync Preferences",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildSyncTile(
          "Auto-sync Travel Plans",
          "Automatically add new trips to calendar",
          settings['autoSyncTravel'] ?? true,
          (val) => _updateSetting('autoSyncTravel', val, settings),
        ),
        _buildSyncTile(
          "Sync Accommodations",
          "Include hotel & flight details",
          settings['syncAccommodations'] ?? true,
          (val) => _updateSetting('syncAccommodations', val, settings),
        ),
        _buildSyncTile(
          "Calendar Notifications",
          "Get reminders for upcoming plans",
          settings['enableNotifications'] ?? false,
          (val) => _updateSetting('enableNotifications', val, settings),
        ),
      ],
    );
  }

  Widget _buildSyncTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        activeColor: Colors.green,
        onChanged: onChanged,
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isConnected;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _ConnectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isConnected,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: isConnected ? Colors.green : Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isConnected ? onDisconnect : onConnect,
            style: ElevatedButton.styleFrom(
              backgroundColor: isConnected
                  ? Colors.red.shade50
                  : Colors.green.shade50,
              foregroundColor: isConnected ? Colors.red : Colors.green,
              elevation: 0,
            ),
            child: Text(isConnected ? "Disconnect" : "Connect"),
          ),
        ],
      ),
    );
  }
}
