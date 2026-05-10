import 'package:flutter/material.dart';
import 'theme.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _biometric = true;
  bool _notifications = true;
  bool _darkMode = true;
  String _aiPersonality = "Professional";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("System Preferences"), backgroundColor: AppColors.background),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection("SECURITY"),
          _buildSwitch("Biometric Login", "FaceID / Fingerprint", _biometric, (v) => setState(() => _biometric = v)),
          
          _buildSection("AI CORE"),
          _buildSwitch("Push Notifications", "Travel Alerts & Updates", _notifications, (v) => setState(() => _notifications = v)),
          ListTile(
            title: const Text("AI Personality", style: TextStyle(color: Colors.white)),
            subtitle: Text(_aiPersonality, style: const TextStyle(color: AppColors.accent)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            onTap: () {
              setState(() {
                _aiPersonality = _aiPersonality == "Professional" ? "Friendly Guide" : "Professional";
              });
            },
          ),

          _buildSection("DISPLAY"),
          _buildSwitch("Dark Mode", "Battery Saver", _darkMode, (v) => setState(() => _darkMode = v)),
          
          const SizedBox(height: 40),
          const Center(child: Text("Version 1.0.0 (Beta)", style: TextStyle(color: Colors.white24))),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      activeColor: AppColors.accent,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      value: value,
      onChanged: onChanged,
    );
  }
}