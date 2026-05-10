import 'dart:io';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'gemini_service.dart';
import 'package:image_picker/image_picker.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final ImagePicker _picker = ImagePicker();
  
  // Mock Data (In real app, load from DB)
  double _totalBudget = 2000.0;
  List<Map<String, dynamic>> _expenses = [
    {"merchant": "Uber Ride", "amount": 25.50, "category": "Transport", "icon": Icons.directions_car},
    {"merchant": "Sushi Dinner", "amount": 45.00, "category": "Food", "icon": Icons.restaurant},
  ];

  bool _isScanning = false;

  double get _totalSpent => _expenses.fold(0.0, (sum, item) => sum + item['amount']);
  double get _remaining => _totalBudget - _totalSpent;
  double get _progress => (_totalSpent / _totalBudget).clamp(0.0, 1.0);

  Future<void> _scanReceipt() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      File file = File(photo.path);
      
      setState(() => _isScanning = true);

      // AI MAGIC
      final data = await GeminiService.scanReceipt(file);

      setState(() {
        _expenses.insert(0, {
          "merchant": data['merchant'],
          "amount": (data['amount'] as num).toDouble(),
          "category": data['category'],
          "icon": _getIconForCategory(data['category'])
        });
        _isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Receipt Added!")));
    }
  }

  IconData _getIconForCategory(String category) {
    if (category.contains("Food")) return Icons.restaurant;
    if (category.contains("Transport")) return Icons.directions_car;
    if (category.contains("Shopping")) return Icons.shopping_bag;
    if (category.contains("Hotel")) return Icons.hotel;
    return Icons.receipt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Trip Budget"),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // 1. BUDGET VISUALIZER
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF11998e), Color(0xFF38ef7d)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF38ef7d).withOpacity(0.3), blurRadius: 20)],
            ),
            child: Column(
              children: [
                const Text("Remaining Budget", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),
                Text("\$${_remaining.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.black26,
                    color: Colors.white,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Spent: \$${_totalSpent.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("Total: \$${_totalBudget.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),

          // 2. EXPENSE LIST
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _isScanning 
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: AppColors.accent), SizedBox(height: 20), Text("AI is reading your receipt...", style: TextStyle(color: Colors.white54))]))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final item = _expenses[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                          child: Icon(item['icon'], color: AppColors.accent),
                        ),
                        title: Text(item['merchant'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(item['category'], style: const TextStyle(color: Colors.white54)),
                        trailing: Text("-\$${item['amount']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      );
                    },
                  ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        onPressed: _scanReceipt,
        icon: const Icon(Icons.camera_alt, color: Colors.black),
        label: const Text("Scan Receipt", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}