import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets.dart';
import 'login_page.dart';
import 'data_model.dart';
import 'preferences_screen.dart'; 

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencesScreen()))
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. PROFESSIONAL ID CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundImage: NetworkImage("https://i.pravatar.cc/300")),
                  const SizedBox(height: 20),
                  Text(UserProfile.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text("Premium Member", style: TextStyle(color: AppColors.accent, letterSpacing: 1.5, fontSize: 12)),
                  const SizedBox(height: 30),
                  
                  // Clean Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSimpleStat("${UserProfile.countriesVisited}", "Countries"),
                      Container(width: 1, height: 40, color: Colors.white10),
                      _buildSimpleStat("${UserProfile.tripsTaken}", "Trips"),
                      Container(width: 1, height: 40, color: Colors.white10),
                      _buildSimpleStat("${(UserProfile.kmTraveled/1000).toStringAsFixed(0)}k", "Km"),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. SETTINGS MENU (Clean List)
            _buildSectionHeader("General"),
            _buildMenuItem(context, "Personal Information", Icons.person_outline),
            _buildMenuItem(context, "Payment Methods", Icons.credit_card),
            _buildMenuItem(context, "Travel Preferences", Icons.tune, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencesScreen()))),

            const SizedBox(height: 30),

            _buildSectionHeader("Support"),
            _buildMenuItem(context, "Help Center", Icons.help_outline),
            _buildMenuItem(context, "Privacy Policy", Icons.lock_outline),

            const SizedBox(height: 40),

            // LOGOUT
            Bounceable(
              onTap: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Center(child: Text("Log Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap ?? () {},
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
    );
  }
}