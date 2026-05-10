import 'dart:io';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets.dart';
import 'gemini_service.dart';
import 'package:image_picker/image_picker.dart';

class FoodLensScreen extends StatefulWidget {
  const FoodLensScreen({super.key});

  @override
  State<FoodLensScreen> createState() => _FoodLensScreenState();
}

class _FoodLensScreenState extends State<FoodLensScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  Map<String, dynamic>? _foodData;
  bool _isLoading = false;

  Future<void> _captureFood() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera); // Direct to Camera
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
        _isLoading = true;
        _foodData = null;
      });

      final data = await GeminiService.analyzeFood(_image!);

      setState(() {
        _foodData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Gastro-Vision"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. IMAGE BACKGROUND
          Positioned.fill(
            child: _image == null
                ? Container(
                    color: Colors.black,
                    child: Icon(Icons.restaurant_menu, color: Colors.white.withOpacity(0.1), size: 100),
                  )
                : Image.file(_image!, fit: BoxFit.cover),
          ),
          
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 2. SCANNING ANIMATION
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 20),
                  Text("Identifying flavors...", style: TextStyle(color: Colors.white, letterSpacing: 1.5)),
                ],
              ),
            ),

          // 3. RESULTS CARD
          if (_foodData != null && !_isLoading)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.95), // Glass effect
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_foodData!['name'], style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                              Text("Origin: ${_foodData!['origin']}", style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        if (_foodData!['is_vegetarian'])
                          const Icon(Icons.eco, color: Colors.green, size: 30),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // TASTE PROFILE
                    Text(_foodData!['taste'], style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 20),

                    // ALLERGEN WARNING
                    if ((_foodData!['allergens'] as List).isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent)),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.redAccent),
                            const SizedBox(width: 10),
                            Expanded(child: Text("Contains: ${(_foodData!['allergens'] as List).join(", ")}", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // STATS ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat(Icons.local_fire_department, _foodData!['calories'], "Energy"),
                        _buildStat(Icons.menu_book, "${(_foodData!['ingredients'] as List).length} Items", "Ingredients"),
                      ],
                    )
                  ],
                ),
              ),
            ),
            
          // 4. SCAN BUTTON (When Empty)
          if (_image == null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Bounceable(
                  onTap: _captureFood,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(30)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.black),
                        SizedBox(width: 10),
                        Text("Scan Dish", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
          // 5. CLOSE BUTTON (When Result Shown)
          if (_foodData != null)
             Positioned(
               top: 50,
               right: 20,
               child: IconButton(
                 icon: const Icon(Icons.close, color: Colors.white, size: 30),
                 onPressed: () => setState(() { _image = null; _foodData = null; }),
               ),
             )
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        )
      ],
    );
  }
}