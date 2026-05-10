import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets.dart';
import 'gemini_service.dart';
import 'package:url_launcher/url_launcher.dart'; // To open Maps

class RadarScreen extends StatefulWidget {
  final String city;
  const RadarScreen({super.key, required this.city});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Map<String, dynamic>> _gems = [];
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    // Radar Animation
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _startScan();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    // 1. Wait a bit for effect
    await Future.delayed(const Duration(seconds: 3));
    
    // 2. Get Data
    final results = await GeminiService.findHiddenGems(widget.city);
    
    if (mounted) {
      setState(() {
        _gems = results;
        _isScanning = false;
        _controller.stop(); // Stop scanning when found
      });
    }
  }

  Future<void> _openMap(String place) async {
    // Open Google Maps
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$place ${widget.city}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Discovery Radar"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. RADAR VISUALIZER
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated Rings
                if (_isScanning) ...[
                  _buildRing(100),
                  _buildRing(200),
                  _buildRing(300),
                  const Icon(Icons.radar, color: AppColors.accent, size: 50),
                ] else
                   const Icon(Icons.location_on, color: AppColors.accent, size: 50),
                
                // Status Text
                Positioned(
                  bottom: 20,
                  child: Text(
                    _isScanning ? "Scanning Sector: ${widget.city}..." : "${_gems.length} Gems Detected",
                    style: const TextStyle(color: AppColors.accent, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),

          // 2. RESULTS LIST
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _gems.isEmpty && !_isScanning
                  ? const Center(child: Text("No signal found.", style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: _gems.length,
                      itemBuilder: (context, index) {
                        final gem = _gems[index];
                        return Bounceable(
                          onTap: () => _openMap(gem['name']),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(gem['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text(gem['description'], style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(children: [const Icon(Icons.star, color: Colors.amber, size: 12), Text(" ${gem['rating']}", style: const TextStyle(color: Colors.amber, fontSize: 12))]),
                                    const SizedBox(height: 4),
                                    Text(gem['distance'], style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRing(double size) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: size * _controller.value,
          height: size * _controller.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent.withOpacity(1 - _controller.value), width: 2),
          ),
        );
      },
    );
  }
}