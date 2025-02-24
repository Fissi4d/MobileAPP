import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // For this example, we assume the user is already signed in.
  // In a real app, include an authentication flow or sign in anonymously:
  // await FirebaseAuth.instance.signInAnonymously();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Off-white background to match the reference image
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _controller = TextEditingController();

  // Returns the Firestore collection reference for the current user’s todos.
  CollectionReference get todosRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // In production, handle the case when the user is not logged in.
      throw Exception("User not logged in");
    }
    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("todos");
  }

  /// Show a dialog to add a new task.
  Future<void> _showAddTodoDialog() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Add Task"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "Enter your task",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  await todosRef.add({
                    "text": text,
                    "completed": false,
                    "createdAt": FieldValue.serverTimestamp(),
                  });
                  _controller.clear();
                }
                Navigator.of(ctx).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  /// Toggles the completed status of a todo document.
  Future<void> toggleTodo(String docId, bool currentCompleted) async {
    await todosRef.doc(docId).update({
      "completed": !currentCompleted,
    });
  }

  /// Deletes a todo document.
  Future<void> deleteTodo(String docId) async {
    await todosRef.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    // Grab current date/time to display at the top, as in the reference image.
    final now = DateTime.now();
    final dayNumber = DateFormat('d').format(now);            // e.g. "12"
    final monthYear = DateFormat('MMM yyyy').format(now).toUpperCase(); // e.g. "JAN 2016"
    final weekday = DateFormat('EEEE').format(now).toUpperCase();       // e.g. "TUESDAY"

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      // Floating button at bottom center, matching the reference image
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00C853), // A bright green color
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top section: large date and day
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: big day number + smaller month/year
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayNumber,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        monthYear,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Right side: day of week
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Task list section using a StreamBuilder to listen to Firestore updates.
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: todosRef.orderBy("createdAt", descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No tasks yet. Add one below!",
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80), // Leave space for the FAB
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final text = data["text"] ?? "";
                      final completed = data["completed"] ?? false;

                      return Dismissible(
                        key: Key(doc.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        // Prompt user for confirmation before deleting
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text("Delete Task?"),
                              content: const Text(
                                "Are you sure you want to delete this task?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          deleteTodo(doc.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            // Task text
                            title: Text(
                              text,
                              style: TextStyle(
                                fontSize: 16,
                                color: completed ? Colors.grey : Colors.black87,
                                decoration:
                                    completed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            // Circle on the right to toggle completion
                            trailing: GestureDetector(
                              onTap: () => toggleTodo(doc.id, completed),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: completed
                                        ? const Color(0xFF00C853)
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                  color: completed
                                      ? const Color(0xFF00C853)
                                      : Colors.transparent,
                                ),
                                child: completed
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}