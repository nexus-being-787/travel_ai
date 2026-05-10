import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets.dart';
import 'gemini_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TourGuideScreen extends StatefulWidget {
  final String placeName;
  const TourGuideScreen({super.key, required this.placeName});

  @override
  State<TourGuideScreen> createState() => _TourGuideScreenState();
}

class _TourGuideScreenState extends State<TourGuideScreen> {
  final FlutterTts _tts = FlutterTts();
  String _script = "Generating audio tour...";
  bool _isLoading = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _generateScript();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _generateScript() async {
    // 1. Get Text from AI
    String text = await GeminiService.generateTourScript(widget.placeName);
    
    // 2. Configure Voice
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5); // Slower for storytelling

    if (mounted) {
      setState(() {
        _script = text;
        _isLoading = false;
      });
      // Auto-play when ready
      _togglePlay();
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _tts.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _tts.speak(_script);
      // When finished, update icon
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Audio Guide"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE (Immersive)
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://source.unsplash.com/800x600/?${widget.placeName}"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.1), AppColors.background],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 2. CONTENT PLAYER
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 20),
                  Text(widget.placeName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text("AI Audio Tour", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                  
                  const SizedBox(height: 20),
                  
                  // SCRIPT AREA
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _script,
                        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PLAYER CONTROLS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: const Icon(Icons.replay_10, color: Colors.white), onPressed: () {}),
                      const SizedBox(width: 20),
                      Bounceable(
                        onTap: _isLoading ? () {} : _togglePlay,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 40),
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(icon: const Icon(Icons.forward_10, color: Colors.white), onPressed: () {}),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}