import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:student_helper_app/screens/models/task_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TaskListProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  TaskListProvider() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    _notificationsPlugin.initialize(settings);
    tz.initializeTimeZones(); // Initialize time zones
  }

  void addTask(TaskModel task) {
    _tasks.add(task);
    notifyListeners();
  }

  void deleteTask(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks.removeAt(index);
      notifyListeners();
    }
  }

  void updateTask(int index, String newTitle) {
    if (index >= 0 && index < _tasks.length && newTitle.isNotEmpty) {
      _tasks[index].title = newTitle;
      notifyListeners();
    }
  }

  void toggleTaskCompletion(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
    }
  }

  void clearTasks() {
    _tasks.clear();
    notifyListeners();
  }

  void setReminder(int index, DateTime reminderTime) async {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index].reminderTime = reminderTime;
      notifyListeners();

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'task_reminders', // Channel ID
        'Task Reminders', // Channel name
        importance: Importance.high,
        priority: Priority.high,
        playSound: true, // Optional: Play a sound when the notification is triggered
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      // Use zonedSchedule with updated parameters
      await _notificationsPlugin.zonedSchedule(
        index, // Notification ID
        "Task Reminder", // Title
        "Don't forget: ${_tasks[index].title}", // Body
        tz.TZDateTime.from(reminderTime, tz.local), // Scheduled time
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Required for exact scheduling
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'task_reminder_${_tasks[index].id}', // Optional payload
      );
    }
  }
}