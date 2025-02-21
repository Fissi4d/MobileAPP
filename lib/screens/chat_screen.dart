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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _showClearConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Chat History'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete all chat messages?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Clear', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                setState(() => messages.clear());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
          "messages": [{"role": "user", "content": message}],
        })),
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);

        if (data['choices'] == null || data['choices'].isEmpty) {
          throw Exception("Invalid API response: $decodedBody");
        }

        final String botMessage = data['choices'][0]['message']['content']?.trim() ?? "No response.";

        setState(() {
          messages.add({
            "text": botMessage,
            "isUser": false,
            "timestamp": DateTime.now(),
          });
        });
        _scrollToBottom();
      } else {
        final String errorBody = utf8.decode(response.bodyBytes);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Chat", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.red),
            tooltip: 'Clear chat',
            onPressed: messages.isEmpty
                ? null
                : () => _showClearConfirmation(),
          ),
        ],
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
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        sendUserMessage(_textController.text);
                        _textController.clear();
                      }
                    },
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