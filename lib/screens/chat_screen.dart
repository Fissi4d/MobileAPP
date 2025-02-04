import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For loading animations
import 'package:intl/intl.dart'; // For formatting timestamps

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // For auto-scrolling
  List<Map<String, dynamic>> messages = [];
  bool _isLoading = false; // To track if a request is in progress

  // Function to send a message to the OpenRouter API
  Future<void> sendUserMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      messages.add({
        "text": message,
        "isUser": true,
        "timestamp": DateTime.now(), // Add timestamp for user's message
      });
      _isLoading = true; // Show loading state
    });

    // Scroll to the bottom when a new message is added
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    try {
      // Define the OpenRouter API endpoint
      const String url = 'https://openrouter.ai/api/v1/chat/completions';
      const String apiKey =
          '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'; // Replace with your actual OpenRouter API key

      // Create the request body
      final Map<String, dynamic> requestBody = {
        "model": "google/gemini-2.0-flash-thinking-exp:free", // Use the desired model
        "messages": [
          {
            "role": "user",
            "content": [
              {"type": "text", "text": message},
            ]
          }
        ],
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url), // Use Uri.parse for the URL
        headers: {
          'Authorization': 'Bearer $apiKey', // Add the API key in the Authorization header
          'Content-Type': 'application/json', // Specify JSON content type
          'HTTP-Referer': 'https://your-site-url.com', // Optional: Replace with your site URL
          'X-Title': 'Your Site Name', // Optional: Replace with your site name
        },
        body: jsonEncode(requestBody), // Encode the request body as JSON
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // Parse the response
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final String botMessage = data['choices'][0]['message']['content'].trim();
          setState(() {
            messages.add({
              "text": botMessage,
              "isUser": false,
              "timestamp": DateTime.now(), // Add timestamp for bot's response
            });
          });
        } else {
          throw Exception("No response from the model.");
        }
      } else {
        // Handle API errors
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['error']['message'] ?? "An error occurred. Please try again.";
        throw Exception("API Error: $errorMessage (Status Code: ${response.statusCode})");
      }
    } catch (e) {
      // Handle network or other errors
      print("Error: $e");
      setState(() {
        messages.add({
          "text": "An error occurred. Please check your connection or try again later.",
          "isUser": false,
          "timestamp": DateTime.now(), // Add timestamp for error message
        });
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading state
      });

      // Scroll to the bottom after the bot responds
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Function to show a confirmation dialog before clearing the chat
  void _showClearChatConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear Chat"),
        content: Text("Are you sure you want to clear this chat?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cancel the dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                messages.clear(); // Clear all messages
              });
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Clear"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Chat", style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: _showClearChatConfirmation, // Show confirmation dialog
              child: Text(
                "Clear Chat",
                style: TextStyle(color: Colors.red), // Red text for emphasis
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white, // Default background color
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Attach the scroll controller
              reverse: false, // Show the latest message at the bottom
              itemCount: messages.length + (_isLoading ? 1 : 0), // Add an extra item for the loading indicator
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  var message = messages[index];
                  return ChatBubble(
                    text: message["text"],
                    isUser: message["isUser"],
                    timestamp: message["timestamp"], // Pass the timestamp
                  );
                } else {
                  // Show the loading indicator on the left
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SpinKitThreeBounce(
                        color: Colors.black, // Black loading animation
                        size: 20.0,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: Colors.black, // Black send button
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading
                        ? null // Disable the button while loading
                        : () {
                            sendUserMessage(_textController.text);
                            _textController.clear(); // Clear the text field after sending
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Chat Bubble Widget
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatBubble({required this.text, required this.isUser, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? Colors.black : Colors.grey[300], // Black for user, light gray for bot
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isUser ? 12 : 0),
              topRight: Radius.circular(isUser ? 0 : 12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            DateFormat.jm().format(timestamp), // Format timestamp as "hh:mm a"
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}