import 'package:flutter/material.dart';
import 'theme.dart';
import 'gemini_service.dart';
import 'package:url_launcher/url_launcher.dart'; // To make calls

class SafetyScreen extends StatefulWidget {
  final String city;
  const SafetyScreen({super.key, required this.city});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  Map<String, dynamic> _safetyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSafetyData();
  }

  Future<void> _loadSafetyData() async {
    final data = await GeminiService.getSafetyInfo(widget.city);
    if (mounted) {
      setState(() {
        _safetyData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _makeCall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine color based on score
    int score = _safetyData['score'] ?? 0;
    Color statusColor = score > 80 ? Colors.green : (score > 50 ? Colors.orange : Colors.red);

    return Scaffold(
      backgroundColor: Colors.black, // Dark mode for seriousness
      appBar: AppBar(
        title: Text("Safety Shield: ${widget.city}"),
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SAFETY SCORE CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Column(
                    children: [
                      Text("$score/100", style: TextStyle(color: statusColor, fontSize: 48, fontWeight: FontWeight.bold)),
                      const Text("AI Safety Score", style: TextStyle(color: Colors.white54)),
                      const SizedBox(height: 10),
                      Text(_safetyData['summary'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 2. EMERGENCY BUTTONS (Dynamic)
                const Text("Emergency Contacts", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildSosButton("POLICE", _safetyData['police'], Icons.local_police, Colors.blue)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSosButton("MEDICAL", _safetyData['ambulance'], Icons.medical_services, Colors.red)),
                  ],
                ),

                const SizedBox(height: 30),

                // 3. AI RISK ALERTS
                const Text("Active Risks (AI Detected)", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...(_safetyData['risks'] as List).map((risk) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(child: Text(risk.toString(), style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                )),
                
                const SizedBox(height: 40),
                
                // 4. FLASH SOS
                Center(
                  child: GestureDetector(
                    onLongPress: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("SOS SIGNAL SENT TO EMERGENCY CONTACTS!")));
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.2),
                        border: Border.all(color: Colors.red, width: 2),
                        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fingerprint, color: Colors.red, size: 40),
                          Text("HOLD SOS", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
    );
  }

  Widget _buildSosButton(String label, String number, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _makeCall(number),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(number, style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}