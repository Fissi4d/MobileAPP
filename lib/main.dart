import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_helper_app/screens/home_screen.dart'; // Import the Home Screen
import 'package:student_helper_app/screens/login_screen.dart'; // Import the Login Screen
import 'package:student_helper_app/screens/providers/task_list_provider.dart'; // Import the TaskListProvider
import 'package:permission_handler/permission_handler.dart';  // Add this import
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Request runtime permissions
  await _requestPermissions();
  await Firebase.initializeApp();

  // Run the app
  runApp(MyApp());
}

// Function to request permissions
Future<void> _requestPermissions() async {
  // Request storage permission (for example, you can add others like notifications, etc.)
  await Permission.storage.request();

  // You can also request other permissions like camera, notifications, etc.
  // await Permission.camera.request();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskListProvider()), // Provide TaskListProvider
        // Add other providers here if needed
      ],
      child: MaterialApp(
        title: 'Student Helper App',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white, // Set global background color to white
          primaryColor: Colors.black, // Set primary color to black
          textTheme: const TextTheme(
            titleLarge: TextStyle(color: Colors.black), // Black app bar title
            bodyMedium: TextStyle(color: Colors.black), // Black task text
          ),
          iconTheme: IconThemeData(color: Colors.black), // Black icons
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white, // White app bar background
            elevation: 0, // Remove shadow
            iconTheme: IconThemeData(color: Colors.black), // Black back arrow
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 20), // Black app bar title
          ),
        ),
        home: AuthGate(), // Use AuthGate to decide which screen to show based on auth state
        routes: {
          '/home': (context) => HomeScreen(), // Define the route for HomeScreen
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking the auth state, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // If the user is logged in, navigate to HomeScreen.
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen();
        }
        // Otherwise, show the LoginScreen.
        return LoginScreen();
      },
    );
  }
}