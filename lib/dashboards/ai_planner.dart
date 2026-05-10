import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'gemini_service.dart';

class AIPlannerScreen extends StatefulWidget {
  const AIPlannerScreen({super.key});

  @override
  State<AIPlannerScreen> createState() => _AIPlannerScreenState();
}

class _AIPlannerScreenState extends State<AIPlannerScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;
    final userText = _controller.text;

    setState(() {
      _messages.add({"role": "user", "text": userText});
      _isLoading = true;
      _controller.clear();
    });

    // Call the AI Service
    final result = await GeminiService.planTrip(userText);

    setState(() {
      _isLoading = false;

      if (result['title'] == "System Alert") {
        _messages.add({
          "role": "ai",
          "text": "${result['description']}",
          "isError": true
        });
      } else {
        _messages.add({
          "role": "ai",
          "text": "I've planned your trip to ${result['location']}!",
          "tripData": result
        });
      }
    });
  }

  /// ✅ SAFELY SAVE TRIP WITH USER AUTH CHECK
  Future<void> _saveTrip(Map<String, dynamic> tripData) async {
    // 1. Safely check if the user is logged into Supabase
    final user = Supabase.instance.client.auth.currentUser;
    
    // 2. If nobody is logged in, stop here and warn them!
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("⚠️ You must log in to save trips!"),
          ),
        );
      }
      return; 
    }

    String rawPrice = tripData['budget']?.toString() ?? "0";
    String cleanPrice = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '');
    double finalPrice = double.tryParse(cleanPrice) ?? 0.0;

    final newTripData = {
      'user_id': user.id, // 👈 Safely attaches the real user's ID
      'title': tripData['title'] ?? "New Trip",
      'subtitle': tripData['location'] ?? "Unknown",
      'price': finalPrice,
      'status': 'Planned',
      'type': 'Adventure',
      'date': 'Upcoming',
    };

    try {
      await Supabase.instance.client.from('trips').insert(newTripData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF4CA1AF),
            content: Text("Trip saved to Database! ☁️"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Database Error: $e")),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          "AI Travel Planner",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color(0xFF4CA1AF)
                              : const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          msg['text'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if (msg['tripData'] != null &&
                          msg['isError'] != true)
                        GestureDetector(
                          onTap: () => _saveTrip(msg['tripData']),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C3E50),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.blueAccent),
                            ),
                            child: const Text(
                              "Tap to Save 💾",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              color: Color(0xFF4CA1AF),
            ),
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF222222),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Where to?",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFF4CA1AF),
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}