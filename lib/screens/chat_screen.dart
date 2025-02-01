// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:openai_dart/openai_dart.dart'; // Import the openai_dart package

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  // Initialize OpenAI client with your API key
  final OpenAIClient _openAI = OpenAIClient(apiKey: 'YOUR_OPENAI_API_KEY'); // Replace with your API key

  void sendUserMessage(String message) async {
    if (message.isNotEmpty) {
      setState(() {
        messages.add({"text": message, "isUser": true}); // Add user's message
      });

      try {
        // Create a chat completion request
        final response = await _openAI.createChatCompletion(
          request: CreateChatCompletionRequest(
            model: ChatCompletionModel.modelId('gpt-3.5-turbo'), // Use a suitable model (e.g., gpt-3.5-turbo or gpt-4)
            messages: [
              ChatCompletionMessage.system(content: 'You are a helpful assistant.'), // System message
              ChatCompletionMessage.user(content: ChatCompletionUserMessageContent.string(message)), // User's message
            ],
            temperature: 0.7, // Adjust the creativity level (0 = deterministic, 1 = creative)
          ),
        );

        // Extract the bot's response
        String? botMessage = response.choices.first.message.content;

        setState(() {
          messages.add({"text": botMessage, "isUser": false}); // Add bot's response
        });
      } catch (e) {
        print("Error: $e");
        setState(() {
          messages.add({"text": "An error occurred. Please try again.", "isUser": false});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with AI"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Show the latest message at the bottom
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                return Align(
                  alignment: message["isUser"] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message["isUser"] ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message["text"],
                      style: TextStyle(
                        color: message["isUser"] ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
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
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendUserMessage(_textController.text);
                    _textController.clear(); // Clear the text field after sending
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}