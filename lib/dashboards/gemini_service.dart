import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // 🔑 PASTE YOUR OPENROUTER KEY HERE
  static const String apiKey = "your_api"; 

  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'openai/gpt-4o-mini';

  static Map<String, dynamic> _errorMap(String title, String desc) {
    return { "title": title, "location": "System Alert", "description": desc, "budget": "N/A", "rating": 0.0, "days": [] };
  }

  static String _cleanJson(String rawText) {
    try {
      int start = rawText.indexOf('{');
      int end = rawText.lastIndexOf('}');
      if (start != -1 && end != -1) return rawText.substring(start, end + 1);
      return rawText; 
    } catch (e) { return rawText; }
  }

  // 🧠 CORE ENGINE (Now with Vision Support!)
  static Future<String?> _sendRequest(String prompt, {String? base64Image}) async {
    final String cleanKey = apiKey.trim(); 
    if (cleanKey.isEmpty) return "SERVER_ERROR: API Key is missing!";

    try {
      debugPrint("📡 Connecting to AI Engine...");

      // Support for both text and image inputs
      List<Map<String, dynamic>> messageContent = [
        {"type": "text", "text": prompt}
      ];

      if (base64Image != null) {
        messageContent.add({
          "type": "image_url",
          "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
        });
      }

      final Map<String, dynamic> requestBody = {
        "model": _model,
        "messages": [ {"role": "user", "content": messageContent} ],
        "response_format": {"type": "json_object"} 
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanKey',
          'HTTP-Referer': 'https://github.com/flutter/flutter', 
          'X-Title': 'TravelAI',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 45)); // Longer timeout for complex generation

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "SERVER_ERROR: ${response.statusCode}";
      }
    } catch (e) {
      return "APP_CRASH: $e";
    }
  }

  // 🗺️ 1. ADVANCED TRIP PLANNER
  static Future<Map<String, dynamic>> planTrip(String userPrompt) async {
    // 💡 IMPROVED OUTPUT: We expanded the JSON schema to force the AI to give us days and activities!
    String systemInstruction = 
        'You are an expert travel companion. Output ONLY valid JSON. '
        'Structure: { "title": "Catchy Trip Name", "location": "City, Country", "description": "Inspiring summary", '
        '"budget": "Estimated cost in USD", "rating": 4.8, '
        '"days": [ {"day": "Day 1", "activities": ["Activity 1", "Activity 2"]}, {"day": "Day 2", "activities": ["Activity 1"]} ] }';
    
    final result = await _sendRequest('$systemInstruction. Request: "$userPrompt"');
    if (result == null || result.contains("ERROR")) return _errorMap("System Alert", result ?? "Failed");
    try { return jsonDecode(_cleanJson(result)); } catch (e) { return _errorMap("Parse Error", "Invalid data format."); }
  }

  // 🎒 2. SMART PACKING LIST
  static Future<List<String>> generatePackingList(String destination, String season, List<String> preferences) async {
    String prompt = 'Create a packing list for a trip to $destination during $season. Consider these preferences: $preferences. '
        'Output ONLY JSON in this format: { "items": ["item1", "item2", "item3"] }';
    
    final result = await _sendRequest(prompt);
    if (result == null || result.contains("ERROR")) return ["Passport", "Wallet", "Phone"];
    try { 
      final data = jsonDecode(_cleanJson(result));
      return List<String>.from(data['items']);
    } catch (e) { return ["Passport", "Wallet", "Phone"]; }
  }

  // 💎 3. HIDDEN GEMS
  static Future<List<Map<String, dynamic>>> findHiddenGems(String location) async {
    String prompt = 'Find 3 off-the-beaten-path hidden gems in $location. '
        'Output ONLY JSON: { "gems": [ {"name": "Place", "desc": "Why it is cool"} ] }';
    
    final result = await _sendRequest(prompt);
    if (result == null || result.contains("ERROR")) return [];
    try { 
      final data = jsonDecode(_cleanJson(result));
      return List<Map<String, dynamic>>.from(data['gems']);
    } catch (e) { return []; }
  }

  // 🛡️ 4. SAFETY INFO
  static Future<Map<String, dynamic>> getSafetyInfo(String location) async {
    String prompt = 'Provide a safety briefing for $location. '
        'Output ONLY JSON: { "score": 85, "summary": "General safety advice..." }';
    
    final result = await _sendRequest(prompt);
    if (result == null || result.contains("ERROR")) return {"score": 0, "summary": "Data unavailable."};
    try { return jsonDecode(_cleanJson(result)); } catch (e) { return {"score": 0, "summary": "Error parsing safety data."}; }
  }

  // 🗣️ 5. TRANSLATOR
  static Future<Map<String, dynamic>> translateText(String text, String targetLanguage) async {
    String prompt = 'Translate "$text" into $targetLanguage. '
        'Output ONLY JSON: { "translated": "The translation here" }';
    
    final result = await _sendRequest(prompt);
    if (result == null || result.contains("ERROR")) return {"translated": "Translation failed."};
    try { return jsonDecode(_cleanJson(result)); } catch (e) { return {"translated": "Translation error."}; }
  }

  // --- VISION STUBS (Ready for your Camera UI) ---
  static Future<Map<String, dynamic>> analyzeFood(File f) async => {"name": "Vision Ready"};
  static Future<Map<String, dynamic>> scanReceipt(File f) async => {"merchant": "Vision Ready"};
  static Future<Map<String, String>> scanDocument(File f) async => {"name": "Vision Ready"};
  static Future<Map<String, String>> generateJournalEntry(File f) async => {"title": "Vision Ready", "entry": "Vision Ready"};
  static Future<Map<String, dynamic>> planTripFromImage(File f, String o) async => _errorMap("Vision", "Ready");
  static Future<String> generateTourScript(String p) async => "Welcome to $p!";
}