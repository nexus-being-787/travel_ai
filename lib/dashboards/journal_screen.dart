import 'dart:io';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'gemini_service.dart';
import 'package:image_picker/image_picker.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final ImagePicker _picker = ImagePicker();
  // We store memories in a list (In real app, save to Database)
  final List<Map<String, dynamic>> _memories = [];
  bool _isGenerating = false;

  Future<void> _createMemory() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      File file = File(photo.path);
      
      setState(() => _isGenerating = true);

      // Ask AI to write the story
      Map<String, String> story = await GeminiService.generateJournalEntry(file);

      setState(() {
        _memories.insert(0, {
          "image": file,
          "title": story['title'],
          "entry": story['entry'],
          "date": DateTime.now().toString().split(' ')[0]
        });
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Travel Memories"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _memories.isEmpty && !_isGenerating
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library, size: 80, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 16),
                const Text("No memories yet.", style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 8),
                const Text("Tap + to turn photos into stories.", style: TextStyle(color: Colors.white24)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _memories.length + (_isGenerating ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isGenerating && index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                );
              }
              
              // Adjust index if loading
              final actualIndex = _isGenerating ? index - 1 : index;
              final memory = _memories[actualIndex];

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.file(
                        memory['image'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    // TEXT
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(memory['title'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                              Text(memory['date'], style: const TextStyle(color: Colors.white24, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(memory['entry'], style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, height: 1.5)),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        onPressed: _createMemory,
        icon: const Icon(Icons.add_a_photo, color: Colors.black),
        label: const Text("New Memory", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}