import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets.dart';

class BookingFlow extends StatefulWidget {
  final String type;
  const BookingFlow({super.key, required this.type});

  @override
  State<BookingFlow> createState() => _BookingFlowState();
}

class _BookingFlowState extends State<BookingFlow> {
  int _step = 1; 
  String _sortMethod = "Balanced"; 

  // New Smart UI Colors
  final Color _cheapColor = const Color(0xFF00E676);
  final Color _fastColor = const Color(0xFF2979FF);

  // Mock Data
  final List<Map<String, dynamic>> _options = [
    {"provider": "InterCity Bus", "platform": "RedBus", "time": "6h 30m", "price": 850, "rating": 4.5, "tag": "Cheapest", "color": const Color(0xFF00E676)},
    {"provider": "Vande Bharat", "platform": "IRCTC", "time": "4h 15m", "price": 1200, "rating": 4.8, "tag": "Best Value", "color": Colors.amberAccent},
    {"provider": "IndiGo Flight", "platform": "MakeMyTrip", "time": "1h 10m", "price": 3500, "rating": 4.2, "tag": "Fastest", "color": const Color(0xFF2979FF)}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text("Select ${widget.type}"), backgroundColor: AppColors.background, elevation: 0),
      body: _step == 1 ? _buildResultsStep() : _buildSuccessStep(),
    );
  }

  Widget _buildResultsStep() {
    List<Map<String, dynamic>> sortedOptions = List.from(_options);
    if (_sortMethod == "Cheapest") sortedOptions.sort((a, b) => a['price'].compareTo(b['price']));
    if (_sortMethod == "Fastest") sortedOptions.sort((a, b) => a['time'].compareTo(b['time']));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SMART INSIGHTS
          Row(children: [
            Expanded(child: _buildInsightCard("Save ₹2,650", "Take the Bus", Icons.savings, _cheapColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildInsightCard("Save 5 Hours", "Take the Flight", Icons.timer, _fastColor)),
          ]),
          const SizedBox(height: 30),

          // 2. FILTERS
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            _buildFilterChip("Balanced"), const SizedBox(width: 10),
            _buildFilterChip("Cheapest"), const SizedBox(width: 10),
            _buildFilterChip("Fastest"),
          ])),
          const SizedBox(height: 20),

          // 3. COMPARISON CARDS
          ...sortedOptions.map((opt) => _buildOptionCard(opt)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _sortMethod == label;
    return GestureDetector(
      onTap: () => setState(() => _sortMethod = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? AppColors.accent : AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? AppColors.accent : Colors.white10)),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> data) {
    return Bounceable(
      onTap: () => setState(() => _step = 3),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
        child: Column(children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.directions_bus, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data['provider'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text("via ${data['platform']}", style: const TextStyle(color: Colors.white54, fontSize: 12))])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text("₹${data['price']}", style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 18)), Text("⭐ ${data['rating']}", style: const TextStyle(color: Colors.white70, fontSize: 12))])
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: data['color'].withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text(data['tag'], style: TextStyle(color: data['color'], fontWeight: FontWeight.bold, fontSize: 12))),
            Text("⏱ ${data['time']}", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          ])
        ]),
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
      const SizedBox(height: 20),
      const Text("Booking Confirmed!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Done"))
    ]));
  }
}