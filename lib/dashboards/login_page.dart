import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'main_screen.dart'; 
import 'theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // ✨ SLEEK CUSTOM NOTIFICATION
  void _showNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide old ones instantly
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface, // Blends with your dark theme
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isError ? Colors.redAccent.withOpacity(0.3) : AppColors.accent.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.auto_awesome, 
              color: isError ? Colors.redAccent : AppColors.accent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🚀 AUTHENTICATION LOGIC
  Future<void> _authenticate(bool isLogin) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showNotification("Please enter an email and password.", isError: true);
      return;
    }

    if (password.length < 6) {
      _showNotification("Password must be at least 6 characters.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        ).timeout(const Duration(seconds: 10));
        
        _showNotification("Welcome back!");
      } else {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        ).timeout(const Duration(seconds: 10));
        
        // Sometimes Supabase creates the account but requires a fresh login tap
        if (response.session == null) {
           _showNotification("Account created! You can now log in.");
           setState(() => _isLoading = false);
           return; 
        } else {
           _showNotification("Account successfully created!");
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } on AuthException catch (e) {
      _showNotification(e.message, isError: true);
    } on TimeoutException {
      _showNotification("Network Timeout. Check your internet.", isError: true);
    } catch (e) {
      _showNotification("Something went wrong. Try again.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: const Icon(Icons.travel_explore, size: 60, color: AppColors.accent),
              ),
              const SizedBox(height: 24),
              const Text("Travel AI", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const Text("Your personal journey architect", style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 40),

              // Inputs
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white24),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white24),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),

              // Buttons
              if (_isLoading)
                const CircularProgressIndicator(color: AppColors.accent)
              else ...[
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                    ),
                    onPressed: () => _authenticate(true),
                    child: const Text("Log In", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accent, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _authenticate(false),
                    child: const Text("Create Account", style: TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 30),
                
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                    );
                  },
                  child: const Text("Skip for now (Guest Mode)", style: TextStyle(color: Colors.white54, decoration: TextDecoration.underline)),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}