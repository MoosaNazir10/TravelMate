import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static Future<void> init() async {
    tz.initializeTimeZones(); // Required for scheduling

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    final String timeZoneName = timezoneInfo.identifier;

    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  static Future<void> scheduleTripReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Check if the time is in the future
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
      // Using INEXACT to ensure it works on your S20 Ultra without crashing
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
    // 1. Schedule Check-in Reminder
    await scheduleTripReminder(
      id: baseId,
      title: "🏨 Check-in: $hotelName",
      body: "It's time to check in to your accommodation!",
      scheduledDate: checkInTime,
    );

    await scheduleTripReminder(
      id: baseId + 1, // Unique ID for Check-out
      title: "🔑 Check-out: $hotelName",
      body: "Don't forget to check out and gather your belongings!",
      scheduledDate: checkOutTime,
    );
  }
  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);  }
}