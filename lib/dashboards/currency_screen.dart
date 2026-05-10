import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets.dart'; // We'll ask AI for insights

class CurrencyScreen extends StatefulWidget {
  final String localCurrency; // e.g. "JPY"
  const CurrencyScreen({super.key, this.localCurrency = "JPY"});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  // Hardcoded rates for demo stability (Real apps use an API like Fixer.io)
  final Map<String, double> _rates = {
    "USD": 1.0,
    "JPY": 150.0,
    "EUR": 0.92,
    "GBP": 0.79,
    "INR": 83.0,
  };

  String _fromCurrency = "USD";
  late String _toCurrency;
  String _input = "0";
  String _result = "0.00";
  String _aiInsight = "Enter an amount to see AI insights.";
  bool _isLoadingInsight = false;

  @override
  void initState() {
    super.initState();
    _toCurrency = widget.localCurrency;
  }

  void _onDigitPress(String digit) {
    setState(() {
      if (_input == "0") {
        _input = digit;
      } else {
        _input += digit;
      }
      _calculate();
    });
  }

  void _onBackspace() {
    setState(() {
      if (_input.length > 1) {
        _input = _input.substring(0, _input.length - 1);
      } else {
        _input = "0";
      }
      _calculate();
    });
  }

  void _calculate() {
    double amount = double.parse(_input);
    double fromRate = _rates[_fromCurrency]!;
    double toRate = _rates[_toCurrency]!;
    
    // Convert to USD first, then to Target
    double inUSD = amount / fromRate;
    double finalAmount = inUSD * toRate;

    _result = finalAmount.toStringAsFixed(2);
  }

  // --- THE AI FEATURE ---
  Future<void> _askAI() async {
    setState(() => _isLoadingInsight = true);
    
    // We simulate a quick AI call or you can hook up GeminiService here
    // For this huge process, let's use the Real Gemini Service if you want actual value context
    // But to keep it fast, I'll simulate the "Brain" logic for the demo:
    
    await Future.delayed(const Duration(milliseconds: 1500)); // Fake network delay for "Thinking"

    double val = double.parse(_input);
    String insight = "";

    if (_toCurrency == "JPY") {
      if (val < 1000) insight = "Cheap! Like a convenience store snack. 🍙";
      else if (val < 5000) insight = "Average lunch price for one person. 🍜";
      else insight = "Getting expensive! Nice dinner range. 🍱";
    } else {
      insight = "That's about ${(val / 15).toStringAsFixed(1)} coffees in $_toCurrency. ☕";
    }

    setState(() {
      _aiInsight = insight;
      _isLoadingInsight = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Smart Converter"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. DISPLAY AREA
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCurrencyRow(_fromCurrency, _input, true),
                  Container(height: 1, color: Colors.white10, margin: const EdgeInsets.symmetric(vertical: 20)),
                  _buildCurrencyRow(_toCurrency, _result, false),
                  
                  const SizedBox(height: 30),
                  
                  // AI INSIGHT CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _isLoadingInsight 
                            ? const Text("Analyzing purchasing power...", style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic))
                            : Text(_aiInsight, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // 2. KEYPAD
          Expanded(
            flex: 5,
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildKeyRow(["1", "2", "3"]),
                  _buildKeyRow(["4", "5", "6"]),
                  _buildKeyRow(["7", "8", "9"]),
                  _buildKeyRow([".", "0", "<"]),
                  const SizedBox(height: 10),
                  Bounceable(
                    onTap: _askAI,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(30)),
                      child: const Center(child: Text("Is this a good price?", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18))),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(String currency, String value, bool isSource) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: currency,
          dropdownColor: AppColors.card,
          underline: Container(),
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          onChanged: (val) => setState(() {
            if (isSource) _fromCurrency = val!;
            else _toCurrency = val!;
            _calculate();
          }),
          items: _rates.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
        Text(
          value, 
          style: TextStyle(
            color: isSource ? Colors.white54 : Colors.white, 
            fontSize: 40, 
            fontWeight: isSource ? FontWeight.normal : FontWeight.bold
          )
        ),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((k) => _buildKey(k)).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    return InkWell(
      onTap: () {
        if (key == "<") _onBackspace();
        else _onDigitPress(key);
      },
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        width: 80,
        height: 80,
        child: Center(
          child: key == "<" 
            ? const Icon(Icons.backspace_outlined, color: Colors.white) 
            : Text(key, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}