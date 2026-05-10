import 'package:flutter/material.dart';
import 'theme.dart';
import 'gemini_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  
  bool _isListening = false;
  String _sourceText = "Tap mic to speak...";
  String _translatedText = "Translation will appear here.";
  String _pronunciation = "";
  
  String _targetLang = "Japanese"; // Default (Tokyo Trip)

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _sourceText = val.recognizedWords;
            });
            
            // Auto-translate when silence is detected (final result)
            if (val.hasConfidenceRating && val.confidence > 0) {
               // In a real app, we'd wait for a pause. 
               // Here we rely on the user stopping the mic manually for control.
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _translate(); // Trigger translation on stop
    }
  }

  Future<void> _translate() async {
    if (_sourceText.isEmpty || _sourceText == "Tap mic to speak...") return;

    final result = await GeminiService.translateText(_sourceText, _targetLang);
    
    setState(() {
      _translatedText = result['translated']!;
      _pronunciation = result['pronunciation']!;
    });

    // AUTO SPEAK
    await _tts.setLanguage("en-US"); // For now, Gemini outputs text. 
    // Note: Setting correct TTS language code (e.g. 'ja-JP') requires mapping languages.
    // For this demo, we will let the user read it or try to speak it.
    await _tts.speak(_translatedText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("AI Interpreter"),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          DropdownButton<String>(
            value: _targetLang,
            dropdownColor: AppColors.card,
            underline: Container(),
            icon: const Icon(Icons.language, color: AppColors.accent),
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => setState(() => _targetLang = val!),
            items: ["Japanese", "Spanish", "French", "Hindi", "German"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          // 1. INPUT AREA (You)
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              color: AppColors.background,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("ENGLISH (YOU)", style: TextStyle(color: Colors.white54, letterSpacing: 1.5)),
                  const SizedBox(height: 20),
                  Text(
                    _sourceText, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          ),

          // 2. DIVIDER
          Container(height: 1, color: Colors.white10),

          // 3. OUTPUT AREA (Them)
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              color: AppColors.surface,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_targetLang.toUpperCase(), style: const TextStyle(color: AppColors.accent, letterSpacing: 1.5)),
                  const SizedBox(height: 20),
                  Text(
                    _translatedText, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.accent, fontSize: 32, fontWeight: FontWeight.bold)
                  ),
                  if (_pronunciation.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(_pronunciation, style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                    ),
                  
                  const SizedBox(height: 30),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.white, size: 40),
                    onPressed: () => _tts.speak(_translatedText),
                  )
                ],
              ),
            ),
          ),

          // 4. MICROPHONE BUTTON
          GestureDetector(
            onTap: _listen,
            child: Container(
              height: 100,
              width: double.infinity,
              color: _isListening ? Colors.redAccent : AppColors.accent,
              child: Center(
                child: _isListening 
                  ? const Icon(Icons.stop, color: Colors.white, size: 50)
                  : const Icon(Icons.mic, color: Colors.black, size: 50),
              ),
            ),
          )
        ],
      ),
    );
  }
}