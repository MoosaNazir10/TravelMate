import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:travelmate/services/firebase_service.dart'; // Import the service

class DeviceCalendarService {
  static final DeviceCalendarPlugin _deviceCalendarPlugin =
      DeviceCalendarPlugin();
  static String? _selectedCalendarId;
  static bool _hasPermission = false;
  static final FirebaseService _firebaseService = FirebaseService();

  // Initialize service by fetching saved ID from Firebase
  static Future<void> init() async {
    _selectedCalendarId = await _firebaseService.getSavedCalendarId();
    await requestPermissions();
  }

  // Request calendar permissions
  static Future<bool> requestPermissions() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
          return false;
        }
      }
      _hasPermission = true;
      return true;
    } on PlatformException catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  // Select a calendar and SAVE to Firebase
  static Future<void> selectCalendar(String calendarId) async {
    _selectedCalendarId = calendarId;
    await _firebaseService.saveSelectedCalendarId(calendarId);
  }

  // Create event with improved error handling
  static Future<bool> createEvent({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? location,
    String? description,
  }) async {
    if (!_hasPermission) {
      bool granted = await requestPermissions();
      if (!granted) return false;
    }

    // If no calendar is selected, try to find the default one
    if (_selectedCalendarId == null) {
      final calendars = await getCalendars();
      if (calendars.isNotEmpty) {
        await selectCalendar(calendars.first.id!);
      } else {
        return false;
      }
    }

    try {
      final event = Event(_selectedCalendarId);
      event.title = title;
      event.start = TZDateTime.from(startDate, local);
      event.end = TZDateTime.from(endDate, local);
      event.location = location;
      event.description = description;

      final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      return result?.isSuccess ?? false;
    } catch (e) {
      print('Error creating device calendar event: $e');
      return false;
    }
  }

  // Get available calendars
  static Future<List<Calendar>> getCalendars() async {
    if (!_hasPermission) await requestPermissions();
    try {
      final result = await _deviceCalendarPlugin.retrieveCalendars();
      return (result.isSuccess && result.data != null) ? result.data! : [];
    } catch (e) {
      return [];
    }
  }

  static bool get hasPermission => _hasPermission;

  static String? get selectedCalendarId => _selectedCalendarId;
}
