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

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);

    // Create notification channel for Android 8+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_reminders',
      'Task Reminders',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    tz.initializeTimeZones();
  }

  void addTask(TaskModel task) {
    _tasks.add(task);
    notifyListeners();
  }

  void deleteTask(int index) {
    if (index >= 0 && index < _tasks.length) {
      final task = _tasks[index];
      _notificationsPlugin.cancel(task.id.hashCode);
      _tasks.removeAt(index);
      notifyListeners();
    }
  }

  void updateTask(int index, String newTitle) {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index] = _tasks[index].copyWith(title: newTitle);
      notifyListeners();
    }
  }

  void toggleTaskCompletion(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      notifyListeners();
    }
  }

  void clearTasks() {
    for (final task in _tasks) {
      _notificationsPlugin.cancel(task.id.hashCode);
    }
    _tasks.clear();
    notifyListeners();
  }

  void removeReminder(int index) async {
    if (index >= 0 && index < _tasks.length) {
      final task = _tasks[index];
      await _notificationsPlugin.cancel(task.id.hashCode);
      _tasks[index] = task.copyWith(reminderTime: null);
      notifyListeners();
    }
  }

  void setReminder(int index, DateTime reminderTime) async {
    if (index >= 0 && index < _tasks.length) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(reminderTime: reminderTime);
      notifyListeners();

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'task_reminders',
        'Task Reminders',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.zonedSchedule(
        task.id.hashCode,
        "Task Reminder",
        "Don't forget: ${task.title}",
        tz.TZDateTime.from(reminderTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}