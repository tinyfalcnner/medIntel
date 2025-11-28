import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';

class ChatbotPopup extends StatefulWidget {
  final User user;

  const ChatbotPopup({
    super.key,
    required this.user,
  });

  @override
  State<ChatbotPopup> createState() => _ChatbotPopupState();
}

class _ChatbotPopupState extends State<ChatbotPopup> {
  final List<Map<String, String>> _messages = []; // {role: "user"/"bot", text: "..."}
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  // Call chatbot API using User's id
  Future<String> _fetchBotResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse("https://your-api-endpoint.com/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.user.id, // uses User object's id property
          "message": userMessage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data["response"] as String? ??
            "I'm not sure, please try again.";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Failed to connect to server.";
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _controller.clear();
      _isLoading = true;
    });

    final botResponse = await _fetchBotResponse(text);

    if (!mounted) return;
    setState(() {
      _messages.add({"role": "bot", "text": botResponse});
      _isLoading = false;
    });
  }

  void _openChatPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.health_and_safety, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      "MedIntel Chatbot",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg["role"] == "user";
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isUser ? Colors.blue[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg["text"] ?? ""),
                        ),
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Type your message...",
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () => _openChatPopup(context),
      ),
    );
  }
}
