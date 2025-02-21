class TaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? reminderTime;

  TaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.reminderTime,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? reminderTime,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}