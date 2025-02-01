// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Import the Chat Screen
import 'todo_screen.dart'; // Import the Todo Screen
import 'reminder_screen.dart'; // Import the Reminder Screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Track the currently selected tab
  final List<Widget> _screens = [
    ChatScreen(),      // Index 0: Chatbot
    TodoScreen(),      // Index 1: Todo List
    ReminderScreen(),  // Index 2: Reminder System
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the current index when a tab is tapped
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Helper App"),
      ),
      body: _screens[_currentIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Set the current index
        onTap: _onTabTapped, // Handle tab taps
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Todo",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Reminders",
          ),
        ],
      ),
    );
  }
}