import 'package:flutter/material.dart';
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
  bool _sentIntro = false; // track if disclaimer + profile already sent

  Future<String> _fetchBotResponse(String userMessage) async {
    final text = userMessage.toLowerCase().trim();
    final userId = widget.user.id;

    final intro = StringBuffer();
    final advice = StringBuffer();

    // Only send disclaimer + profile the first time
    if (!_sentIntro) {
      intro.writeln(
        "Note: This chatbot gives general health education and lifestyle tips only. "
        "It cannot diagnose or replace a consultation with a doctor.",
      );
      intro.writeln();

      if (userId == "u1") {
        intro.writeln(
          "Profile: 28‑year‑old with mild asthma, focusing on better cardio fitness and stress control.",
        );
      } else if (userId == "u2") {
        intro.writeln(
          "Profile: 45‑year‑old with hypertension and prediabetes, focusing on weight and blood pressure control.",
        );
      } else if (userId == "u3") {
        intro.writeln(
          "Profile: 60‑year‑old with knee osteoarthritis and high cholesterol, focusing on joint comfort and energy.",
        );
      } else {
        intro.writeln("Profile: Adult user with general health goals.");
      }
      intro.writeln();
    }

    // Weight / diet
    if (text.contains("weight") || text.contains("diet") || text.contains("lose")) {
      if (userId == "u2") {
        advice.writeln(
          "For your blood pressure and sugar, slow, steady weight loss is safest. "
          "Use smaller portions of rice/bread, avoid sugary drinks, and try to fill half the plate with vegetables.",
        );
      } else {
        advice.writeln(
          "For healthy weight, keep regular meals, plenty of vegetables, and limit sweets and deep‑fried foods. "
          "Avoid frequent late‑night snacks where possible.",
        );
      }
      advice.writeln();
    }

    // Blood pressure
    if (text.contains("bp") ||
        text.contains("blood pressure") ||
        text.contains("pressure")) {
      advice.writeln(
        "To support blood pressure, reduce added salt: cut down on packaged snacks, instant noodles, and very salty pickles. "
        "Aim for 20–30 minutes of relaxed walking on most days if your doctor allows it.",
      );
      advice.writeln();
    }

    // Joint / knee pain
    if (text.contains("knee") ||
        text.contains("joint") ||
        text.contains("arthritis") ||
        text.contains("pain")) {
      advice.writeln(
        "For joint comfort, use low‑impact activities such as cycling, swimming, or flat walking. "
        "Avoid running on hard ground, jumping, or long periods of standing if they worsen pain.",
      );
      advice.writeln();
    }

    // Breathing / asthma
    if (text.contains("breath") ||
        text.contains("breathing") ||
        text.contains("asthma") ||
        text.contains("wheeze")) {
      advice.writeln(
        "With breathing problems or asthma, warm up gently before exercise, keep your inhaler available if prescribed, "
        "and avoid heavy exercise in very cold or polluted air. Sudden severe breathlessness is an emergency.",
      );
      advice.writeln();
    }

    // Stress / sleep / tiredness
    if (text.contains("stress") ||
        text.contains("anxious") ||
        text.contains("anxiety") ||
        text.contains("sleep") ||
        text.contains("tired") ||
        text.contains("fatigue")) {
      advice.writeln(
        "For stress and sleep, try a fixed sleep time, limit screens in the last 30 minutes before bed, "
        "and add at least one short walk or stretching break in the day just for relaxation.",
      );
      advice.writeln();
    }

    // Generic advice if nothing matched
    if (advice.isEmpty) {
      advice.writeln(
        "For general health, aim for some movement most days, more vegetables and whole foods, "
        "and regular check‑ups with your doctor if you have ongoing conditions.",
      );
    }

    _sentIntro = true;
    return (intro.toString() + advice.toString()).trim();
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
                        onSubmitted: (_) => _sendMessage(),
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
