import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> messages = [];
  bool _isLoading = false;

  // Get the Firebase user's display name; fall back to email username if null.
  String get _userDisplayName {
    if (_currentUser?.displayName != null && _currentUser!.displayName!.isNotEmpty) {
      return _currentUser!.displayName!;
    } else if (_currentUser?.email != null) {
      return _currentUser!.email!.split('@').first;
    }
    return 'User';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendUserMessage(String message) async {
    if (message.isEmpty) return;
    setState(() {
      messages.add({
        "text": message,
        "isUser": true,
        "timestamp": DateTime.now(),
      });
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: utf8.encode(jsonEncode({
          "model": "google/gemini-2.0-flash-lite-preview-02-05:free",
          "messages": [
            {"role": "user", "content": message}
          ],
        })),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);

        if (data['choices'] == null || data['choices'].isEmpty) {
          throw Exception("Invalid API response: $decodedBody");
        }

        final botMessage = data['choices'][0]['message']['content']?.trim() ?? "No response.";

        setState(() {
          messages.add({
            "text": botMessage,
            "isUser": false,
            "timestamp": DateTime.now(),
          });
        });
        _scrollToBottom();
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        throw Exception("API Error (${response.statusCode}): $errorBody");
      }
    } catch (e) {
      setState(() {
        messages.add({
          "text": "An error occurred: ${e.toString()}",
          "isUser": false,
          "timestamp": DateTime.now(),
        });
      });
      _scrollToBottom();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If no messages are present, show a centered header. Otherwise, display the chat list.
    return Scaffold(
      appBar: null, // No default AppBar
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const Center(child: ChatHeader())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && _isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SpinKitThreeBounce(color: Colors.black, size: 20.0),
                          );
                        }
                        final message = messages[index];
                        return ChatBubble(
                          text: message["text"],
                          isUser: message["isUser"],
                          timestamp: message["timestamp"],
                          userDisplayName: _userDisplayName,
                        );
                      },
                    ),
            ),
            // Message input bar at the bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: "Message",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        style: const TextStyle(color: Colors.black),
                        onSubmitted: (_) {
                          if (!_isLoading) {
                            sendUserMessage(_textController.text);
                            _textController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            sendUserMessage(_textController.text);
                            _textController.clear();
                          },
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFF4B1869),
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A header widget that shows "ConvoAI" with a purple dot.
/// Displayed when the chat is empty.
class ChatHeader extends StatelessWidget {
  const ChatHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'EduMate AI',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF4B1869),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

/// ChatBubble widget displays the avatar, name, message text, and timestamp.
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String userDisplayName;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.userDisplayName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For user messages, use the Firebase user's display name; for AI, use "ConvoAI".
    final displayName = isUser ? userDisplayName : "ConvoAI";

    // Both avatars have the same size.
    final avatarWidget = CircleAvatar(
      radius: 20,
      backgroundColor: isUser ? Colors.grey[400] : Colors.black,
      child: isUser
          ? Text(
              _getInitials(displayName),
              style: const TextStyle(color: Colors.white),
            )
          : const Icon(Icons.android, color: Colors.white, size: 20),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          avatarWidget,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat.jm().format(timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return "U";
    return parts.map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }
}
