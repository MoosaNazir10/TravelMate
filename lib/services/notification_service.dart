import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones(); // Required for scheduling

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timezoneInfo.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // ✅ Check if notifications are disabled in settings
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool('notifications_enabled') ?? true;

    if (!isEnabled) return; // Stop here if disabled

    const androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Instant Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> scheduleTripReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trip_reminders',
          'Trip Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleAccommodationReminders({
    required int baseId,
    required String hotelName,
    required DateTime checkInTime,
    required DateTime checkOutTime,
  }) async {
    await scheduleTripReminder(
      id: baseId,
      title: "🏨 Check-in: $hotelName",
      body: "It's time to check in to your accommodation!",
      scheduledDate: checkInTime,
    );

    await scheduleTripReminder(
      id: baseId + 1,
      title: "🔑 Check-out: $hotelName",
      body: "Don't forget to check out and gather your belongings!",
      scheduledDate: checkOutTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}