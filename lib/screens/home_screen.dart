import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart'; // Import the Chat Screen
import 'todo_screen.dart'; // Import the Todo Screen
import 'providers/task_list_provider.dart'; // Import the TaskListProvider

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Helper App"),
      ),
      body: IndexedStack( // Prevent widget recreation when switching tabs
        index: _currentIndex,
        children: [
          ChatScreen(),
          TodoScreen(), // ✅ Now uses the provider from `main.dart`
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Todo",
          ),
        ],
      ),
    );
  }
}
