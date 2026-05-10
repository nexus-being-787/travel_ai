import 'package:flutter/material.dart';
import 'theme.dart';
import 'data_model.dart';
import 'gemini_service.dart';

class PackingScreen extends StatefulWidget {
  final String city;
  const PackingScreen({super.key, required this.city});

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
  List<String> _items = [];
  bool _isLoading = true;
  final Set<int> _checkedIndices = {};

  @override
  void initState() {
    super.initState();
    _generateList();
  }

  Future<void> _generateList() async {
    // We use the UserPreferences we created earlier!
    final list = await GeminiService.generatePackingList(
      widget.city, 
      "Spring", // You can make this dynamic later
      UserPreferences.interests
    );
    
    if (mounted) {
      setState(() {
        _items = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Packing for ${widget.city}"),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accent), 
            onPressed: () {
              setState(() => _isLoading = true);
              _generateList();
            }
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
        : Column(
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.backpack, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("AI Suggestion", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                          Text("Based on your love for ${UserPreferences.interests.take(2).join(" & ")}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // CHECKLIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final isChecked = _checkedIndices.contains(index);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isChecked ? Colors.green.withOpacity(0.1) : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isChecked ? Colors.green : Colors.transparent),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isChecked ? Icons.check_circle : Icons.circle_outlined,
                          color: isChecked ? Colors.green : Colors.white54,
                        ),
                        title: Text(
                          _items[index],
                          style: TextStyle(
                            color: Colors.white,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.green,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (isChecked) {
                              _checkedIndices.remove(index);
                            } else {
                              _checkedIndices.add(index);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // PROGRESS
              Container(
                padding: const EdgeInsets.all(20),
                color: AppColors.surface,
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${_checkedIndices.length}/${_items.length} Packed", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      if (_checkedIndices.length == _items.length && _items.isNotEmpty)
                        const Text("READY TO GO! ✈️", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
    );
  }
}