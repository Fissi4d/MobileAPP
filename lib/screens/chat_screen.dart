import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool _isLoading = false;

  // Function to send a message to OpenRouter API
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

    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "deepseek/deepseek-r1-distill-llama-70b:free",
          "messages": [{"role": "user", "content": message}],
        }),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (data['choices'] == null || data['choices'].isEmpty) {
          throw Exception("Invalid API response: ${response.body}");
        }

        final String botMessage = data['choices'][0]['message']['content']?.trim() ?? "No response.";

        setState(() {
          messages.add({
            "text": botMessage,
            "isUser": false,
            "timestamp": DateTime.now(),
          });
        });
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        messages.add({
          "text": "An error occurred: $e",
          "isUser": false,
          "timestamp": DateTime.now(),
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Chat", style: TextStyle(color: Colors.black)),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  var message = messages[index];
                  return ChatBubble(
                    text: message["text"],
                    isUser: message["isUser"],
                    timestamp: message["timestamp"],
                  );
                } else {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SpinKitThreeBounce(color: Colors.black, size: 20.0),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: Colors.black,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading
                        ? null
                        : () {
                            sendUserMessage(_textController.text);
                            _textController.clear();
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

// ✅ Fixed Emoji Display Using RichText (No Need for External Fonts)
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
            color: isUser ? Colors.black : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: RichText(
            text: TextSpan(
              text: text,
              style: TextStyle(
                fontSize: 16,
                color: isUser ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            DateFormat.jm().format(timestamp),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
