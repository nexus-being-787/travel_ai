import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UnsplashService {
  // 🔑 PASTE YOUR UNSPLASH ACCESS KEY HERE
  static const String _accessKey = "02hsi_YH3s8qO1Jny4kPaLtAxyxerKu5BdHWaJAGNNU";
  
  static Future<String> getCityPhoto(String location) async {
    // If the key is missing, return a beautiful default travel image so the app doesn't break
    if (_accessKey == "PASTE_YOUR_UNSPLASH_KEY_HERE" || _accessKey.isEmpty) {
      debugPrint("⚠️ Unsplash Key missing. Using default fallback image.");
      return "https://images.unsplash.com/photo-1488085061387-422e29b40080?q=80&w=1000&auto=format&fit=crop"; 
    }

    try {
      debugPrint("📸 Fetching photo for: $location...");
      // We search for the location, ask for only 1 photo, and ensure it's landscape orientation
      final url = Uri.parse(
          'https://api.unsplash.com/search/photos?query=$location&client_id=$_accessKey&per_page=1&orientation=landscape');
      
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          debugPrint("✅ Unsplash photo found!");
          // We grab the "regular" sized URL which is perfect for mobile screens
          return data['results'][0]['urls']['regular'];
        }
      } else {
        debugPrint("❌ Unsplash API Error (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      debugPrint("⚠️ Unsplash Crash: $e");
    }
    
    // Fallback image if the city isn't found or the internet drops
    return "https://images.unsplash.com/photo-1488085061387-422e29b40080?q=80&w=1000&auto=format&fit=crop"; 
  }
}