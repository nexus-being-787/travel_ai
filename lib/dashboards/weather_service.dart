import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // 🔑 PASTE YOUR OPENWEATHER API KEY HERE
  static const String _apiKey = "55d7fc46dbae6e2d3f6fe08d3d3e4531";
  
  // Base URL for current weather data
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  /// Fetches the current weather for a specific city (e.g., "Tokyo, Japan")
  static Future<Map<String, dynamic>> getWeather(String location) async {
    // Failsafe if the key isn't pasted yet
    if (_apiKey == "PASTE_YOUR_UNSPLASH_KEY_HERE" || _apiKey.isEmpty) {
      debugPrint("⚠️ OpenWeather Key missing.");
      return _errorWeather();
    }

    try {
      debugPrint("🌤️ Fetching weather for: $location...");
      
      // Clean up the location string (sometimes AI adds extra info we don't need for the weather API)
      String cleanLocation = location.split(',')[0].trim(); // Grabs just the city name

      // Build the URL (units=metric gives Celsius, use units=imperial for Fahrenheit)
      final url = Uri.parse('$_baseUrl?q=$cleanLocation&appid=$_apiKey&units=metric');
      
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ Weather found: ${data['weather'][0]['main']}, ${data['main']['temp']}°C");
        
        return {
          "temp": data['main']['temp'].round(), // e.g., 24
          "condition": data['weather'][0]['main'], // e.g., "Clouds" or "Clear"
          "description": data['weather'][0]['description'], // e.g., "scattered clouds"
          "iconUrl": "https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png",
          "humidity": data['main']['humidity'],
          "isError": false,
        };
      } else {
        debugPrint("❌ Weather API Error (${response.statusCode}): ${response.body}");
        return _errorWeather();
      }
    } catch (e) {
      debugPrint("⚠️ Weather Crash: $e");
      return _errorWeather();
    }
  }

  // Fallback data so the UI never crashes
  static Map<String, dynamic> _errorWeather() {
    return {
      "temp": "--",
      "condition": "Unknown",
      "description": "Weather unavailable",
      "iconUrl": "",
      "humidity": "--",
      "isError": true,
    };
  }
}