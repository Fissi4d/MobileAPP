import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the notification plugin
  static Future<void> initialize() async {
    tz_data.initializeTimeZones(); // Initialize time zones

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('app_icon'); // Replace 'app_icon' with your app icon name

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitSettings);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Show a scheduled notification
  static Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Channel ID
      'Your Channel Name', // Channel name
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Convert scheduledDate to TZDateTime
    final scheduledTZDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    // Use zonedSchedule with the updated parameters
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDateTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Ensure delivery while idle
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}