import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'todo_screen.dart';
import 'providers/task_list_provider.dart';

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
    // Access provider (optional)
    final taskListProvider = Provider.of<TaskListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Student Helper App"),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ChatScreen(),
          TodoScreen(), // ✅ TodoScreen can still use Provider
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
