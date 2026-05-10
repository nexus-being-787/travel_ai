import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboards/onboarding_screen.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ☁️ SUPABASE CONNECTION (DO NOT REMOVE!)
  // This ensures your trips still save to the cloud while using the old main.dart flow.
  Supabase.initialize(
    url: 'https://pfwfhncoqhlfypsgovnf.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBmd2ZobmNvcWhsZnlwc2dvdm5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAxODI3NzQsImV4cCI6MjA4NTc1ODc3NH0.S2f6lH_RbFw3HnPLAvFTsaMZZpWg-3mCXnQO4PwCOdA',
  ).then((_) {
    debugPrint("✅ Supabase Connected in background!");
  }).catchError((error) {
    debugPrint("⚠️ Supabase Error: $error");
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), 
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      // 👇 This starts your app at the Onboarding Screen again!
      home: const OnboardingScreen(), 
    );
  }
}