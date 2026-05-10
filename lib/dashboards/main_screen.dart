import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_tab.dart';
import 'smart_wallet.dart';
import 'journal_screen.dart';
import 'profile_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // The 4 Main Tabs
  final List<Widget> _pages = [
    const HomeTab(),
    const SmartWalletScreen(),
    const JournalScreen(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: Colors.white24,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
            BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: "Journal"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}