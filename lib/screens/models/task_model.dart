import 'package:flutter/foundation.dart';

class TaskModel {
  final String id;
  late final String title;
  bool isCompleted;
  DateTime? reminderTime; // ⏰ New field for reminders

  TaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.reminderTime,
  });
}
