// lib/providers/task_list_provider.dart

import 'package:flutter/foundation.dart';
import '../models/task_model.dart'; // Import the Task model

class TaskListProvider with ChangeNotifier {
  List<Task> _tasks = []; // Private list to store tasks

  // Getter to expose the list of tasks
  List<Task> get tasks => _tasks;

  // Method to add a new task
  void addTask(String title) {
    if (title.isNotEmpty) {
      _tasks.add(Task(title: title)); // Create a new Task object and add it to the list
      notifyListeners(); // Notify listeners that the state has changed
    }
  }

  // Method to toggle the completion status of a task
  void toggleTask(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted; // Toggle completion status
      notifyListeners(); // Notify listeners about the change
    }
  }

  // Method to delete a task
  void deleteTask(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks.removeAt(index); // Remove the task at the specified index
      notifyListeners(); // Notify listeners about the change
    }
  }

  // Method to clear all completed tasks
  void clearCompletedTasks() {
    _tasks.removeWhere((task) => task.isCompleted); // Remove all completed tasks
    notifyListeners(); // Notify listeners about the change
  }
}