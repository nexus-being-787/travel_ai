import 'package:flutter/material.dart';
import 'theme.dart';
import 'data_model.dart';
import 'widgets.dart';
import 'packing_screen.dart'; // ✅ IMPORT THE PACKING SCREEN
import 'translator_screen.dart'; // <--- Add this line
import 'currency_screen.dart';
import 'tour_guide_screen.dart'; // <--- ADD THIS
import 'safety_screen.dart'; // <--- ADD THIS
import 'budget_screen.dart';
import 'radar_screen.dart';
import 'food_lens_screen.dart';

class TripCompanionScreen extends StatelessWidget {
  final Trip trip;
  const TripCompanionScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Immersive Mode
      body: CustomScrollView(
        slivers: [
          // 1. LIVE HEADER (Weather & Time)
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[900]!, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.wb_sunny, size: 60, color: Colors.amber),
                    const SizedBox(height: 10),
                    const Text("24°C • Sunny",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    Text("Local Time: 14:30 PM (${trip.localTimeOffset})",
                        style: const TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            ),
          ),

          // 2. SMART TOOLS GRID
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildToolCard(context, Icons.translate, "Interpreter",
                    "Voice Translation",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TranslatorScreen()))),
                _buildToolCard(
                    context, Icons.radar, "Hidden Gems", "Scan Local Area",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RadarScreen(
                                city: trip.title.replaceAll("Trip to ", ""))))),
                _buildToolCard(
                    context, Icons.restaurant, "Food Lens", "Identify Dish",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FoodLensScreen()))),
                _buildToolCard(
                    context, Icons.pie_chart, "Smart Budget", "Scan Receipts",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BudgetScreen()))),
                _buildToolCard(
                    context,
                    Icons.shield, // Changed icon to Shield
                    "Safety Shield",
                    "SOS & Alerts",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SafetyScreen(
                                city: trip.title.replaceAll("Trip to ", ""))))),
                _buildToolCard(context, Icons.currency_exchange, "Currency",
                    "1 USD = 150 ${trip.currencyCode}",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CurrencyScreen(
                                localCurrency: trip.currencyCode)))),
                _buildToolCard(context, Icons.headphones, "Audio Guide",
                    "Hear the History",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TourGuideScreen(
                                placeName:
                                    trip.title.replaceAll("Trip to ", ""))))),
                // 1. SMART PACKING (New!)
                _buildToolCard(
                    context, Icons.backpack, "Smart Pack", "AI Checklist",
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PackingScreen(
                                city: trip.title.replaceAll("Trip to ", ""))))),

                // 2. CURRENCY
                _buildToolCard(context, Icons.currency_exchange, "Currency",
                    "1 USD = 150 ${trip.currencyCode}"),

                // 3. EMERGENCY
                _buildToolCard(
                    context, Icons.local_hospital, "Emergency", "SOS"),

                // 4. OFFLINE MAP
                _buildToolCard(context, Icons.map, "Offline Map", "Download"),
              ],
            ),
          ),

          // 3. TODAY'S ITINERARY
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Text("Up Next",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final activity = trip.itinerary[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(activity.icon, color: Colors.white),
                  ),
                  title: Text(activity.title,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(activity.time,
                      style: const TextStyle(color: Colors.white54)),
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white24),
                );
              },
              childCount: trip.itinerary.length,
            ),
          )
        ],
      ),
      // AI ASSISTANT FAB
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        onPressed: () {
          // Future: Open AI Chat specifically for this location
        },
        icon: const Icon(Icons.mic, color: Colors.black),
        label: const Text("Ask AI",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- HELPER FUNCTION ---
  Widget _buildToolCard(
      BuildContext context, IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return Bounceable(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
