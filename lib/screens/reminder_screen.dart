// lib/screens/reminder_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:student_helper_app/services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Initialize with today's date
    _selectedTime = TimeOfDay.now(); // Initialize with current time
  }

  // Select a date using a date picker
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Select a time using a time picker
  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Set the reminder
  void _setReminder() {
    // Combine the selected date and time into a single DateTime object
    final scheduledDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Show a scheduled notification
    NotificationService.showScheduledNotification(
      id: 1,
      title: "Reminder",
      body: "Your task is due!",
      scheduledDate: scheduledDate,
    );

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Reminder set for ${DateFormat.yMd().add_jm().format(scheduledDate)}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Set Reminder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text("Select Date (${DateFormat.yMd().format(_selectedDate)})"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text("Select Time (${_selectedTime.format(context)})"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _setReminder,
              style: ElevatedButton.styleFrom(primary: Colors.green),
              child: Text("Set Reminder"),
            ),
          ],
        ),
      ),
    );
  }
}