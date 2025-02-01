// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Import the Home Screen
import 'services/notification_service.dart'; // Import the Notification Service

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await NotificationService.initialize(); // Initialize notifications
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Helper App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // Set the HomeScreen as the root widget
    );
  }
}