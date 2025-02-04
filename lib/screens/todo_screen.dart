import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_helper_app/screens/providers/task_list_provider.dart';
import './models/task_model.dart';

class TodoScreen extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Todo List", style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              _showClearAllTasksConfirmation(context); // Show confirmation dialog
            },
            child: Text(
              "Clear All Tasks",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Consumer<TaskListProvider>(
        builder: (context, taskListProvider, _) {
          if (taskListProvider.tasks.isEmpty) {
            return Center(
              child: Text(
                "No tasks yet. Add one below!",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            itemCount: taskListProvider.tasks.length,
            itemBuilder: (context, index) {
              final TaskModel task = taskListProvider.tasks[index];

              return Dismissible(
                key: Key(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  taskListProvider.deleteTask(index);
                },
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      taskListProvider.toggleTaskCompletion(index);
                    },
                    activeColor: Colors.blue,
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      color: Colors.black,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications, color: task.reminderTime != null ? Colors.orange : Colors.grey),
                        onPressed: () {
                          _pickReminderDateTime(context, index);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red), // Delete icon
                        onPressed: () {
                          _showDeleteTaskConfirmation(context, index); // Show confirmation dialog
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditTaskDialog(context, index, task.title);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _pickReminderDateTime(BuildContext context, int index) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return;

    final DateTime reminderDateTime = DateTime(
      selectedDate.year, selectedDate.month, selectedDate.day,
      selectedTime.hour, selectedTime.minute,
    );

    // Set the reminder
    Provider.of<TaskListProvider>(context, listen: false).setReminder(index, reminderDateTime);

    // Show a SnackBar with the reminder details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Reminder set for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at ${selectedTime.format(context)}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3), // Display for 3 seconds
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Add Task", style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: _textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter task description",
            hintStyle: TextStyle(color: Colors.black54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              final String taskTitle = _textController.text.trim();
              if (taskTitle.isNotEmpty) {
                final newTask = TaskModel(
                  id: DateTime.now().toString(),
                  title: taskTitle,
                );
                Provider.of<TaskListProvider>(context, listen: false).addTask(newTask);
                _textController.clear();
                Navigator.pop(context);
              }
            },
            child: Text("Add", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, int index, String currentTaskTitle) {
    _textController.text = currentTaskTitle; // Pre-fill the text field with the current task title

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Edit Task", style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: _textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter task description",
            hintStyle: TextStyle(color: Colors.black54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              final String updatedTaskTitle = _textController.text.trim();
              if (updatedTaskTitle.isNotEmpty) {
                Provider.of<TaskListProvider>(context, listen: false).updateTask(index, updatedTaskTitle);
                _textController.clear();
                Navigator.pop(context);
              }
            },
            child: Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showDeleteTaskConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Delete Task", style: TextStyle(color: Colors.black)),
        content: Text("Are you sure you want to delete this task?", style: TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TaskListProvider>(context, listen: false).deleteTask(index); // Delete the task
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Delete", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showClearAllTasksConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Clear All Tasks", style: TextStyle(color: Colors.black)),
        content: Text("Are you sure you want to clear all tasks?", style: TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TaskListProvider>(context, listen: false).clearTasks(); // Clear all tasks
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Clear All", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}