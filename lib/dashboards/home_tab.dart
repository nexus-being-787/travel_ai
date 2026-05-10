import 'package:flutter/material.dart';
import 'ai_planner.dart'; // Import the AI Page

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text("Travel AI 🌍", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hides back button on home screen
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Logo or Icon
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4CA1AF).withOpacity(0.1),
                border: Border.all(color: const Color(0xFF4CA1AF), width: 2),
              ),
              child: const Icon(Icons.flight_takeoff, size: 60, color: Color(0xFF4CA1AF)),
            ),
            const SizedBox(height: 30),
            
            const Text(
              "Where to next?",
              style: TextStyle(
                color: Colors.white, 
                fontSize: 24, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Plan your dream trip with AI",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 50),

            // 🔘 BIG BUTTON: Go to AI Planner
            SizedBox(
              width: 250,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // 👉 Navigate to the AI Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AIPlannerScreen()),
                  );
                },
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: const Text(
                  "Start Planning", 
                  style: TextStyle(color: Colors.white, fontSize: 18)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CA1AF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}