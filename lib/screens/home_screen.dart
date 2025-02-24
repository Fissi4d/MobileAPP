import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import Font Awesome
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
    // Access provider if needed
    final taskListProvider = Provider.of<TaskListProvider>(context);

    return Scaffold(
      // We omit the AppBar to maintain a clean look
      appBar: null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ChatScreen(),
          TodoListScreen(),
        ],
      ),
      // Wrap the BottomNavigationBar in a container that has
      // rounded top corners and a box shadow for a modern design.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            // Hide labels for a sleek icon-only bar
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.commentDots), 
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.clipboardList),
                label: 'Todo',
              ),
            ],
          ),
        ),
      ),
    );
  }
}