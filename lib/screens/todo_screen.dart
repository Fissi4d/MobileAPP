// lib/screens/todo_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_list_provider.dart'; // Import the provider
import '../models/task_model.dart'; // Import the Task model

class TodoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: () {
              // Clear all completed tasks
              Provider.of<TaskListProvider>(context, listen: false).clearCompletedTasks();
            },
            tooltip: "Clear Completed Tasks",
          ),
        ],
      ),
      body: Consumer<TaskListProvider>(
        builder: (context, taskListProvider, _) {
          if (taskListProvider.tasks.isEmpty) {
            return Center(
              child: Text("No tasks yet. Add one below!", style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            itemCount: taskListProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskListProvider.tasks[index];
              return Dismissible(
                key: Key(task.title), // Unique key for each task
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  taskListProvider.deleteTask(index); // Delete the task when swiped
                },
                child: ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      taskListProvider.toggleTask(index); // Toggle task completion
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context); // Show dialog to add a new task
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
void _showAddTaskDialog(BuildContext context) {
  final TextEditingController _controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Add Task"),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(hintText: "Enter task description"),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Provider.of<TaskListProvider>(context, listen: false).addTask(value);
            Navigator.pop(context); // Close the dialog
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Cancel the dialog
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final String taskTitle = _controller.text.trim();
            if (taskTitle.isNotEmpty) {
              Provider.of<TaskListProvider>(context, listen: false).addTask(taskTitle);
              Navigator.pop(context); // Close the dialog
            }
          },
          child: Text("Add"),
        ),
      ],
    ),
  );
}