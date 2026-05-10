import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'theme.dart';
import 'widgets.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool _isAuthenticating = false;

  // 🔐 YOUR BIOMETRIC FUNCTION
  Future<bool> _authenticateUser() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      setState(() => _isAuthenticating = true);
      
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to unlock your secure documents.',
        options: const AuthenticationOptions(
          biometricOnly: true, // Forces Fingerprint or FaceID
          stickyAuth: true,    // Keeps the prompt open if the app goes to background
        ),
      );
      
      setState(() => _isAuthenticating = false);
      return didAuthenticate;
    } catch (e) {
      setState(() => _isAuthenticating = false);
      debugPrint("Auth Error: $e");
      return false;
    }
  }

  // 🛡️ THE SECURITY GATEKEEPER
  void _securelyOpenDocument(String documentName) async {
    HapticFeedback.heavyImpact(); // Give a physical "thud" feel
    
    // 1. Ask for fingerprint/Face ID
    bool isUnlocked = await _authenticateUser();

    if (!mounted) return;

    // 2. Decide what to do based on the result
    if (isUnlocked) {
      // SUCCESS! Open the document.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.accent, content: Text("🔓 Access Granted to $documentName")),
      );
      // TODO: Navigate to the actual document viewer screen here!
    } else {
      // FAILED! Lock them out.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("🔒 Access Denied.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Travel Vault", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // HEADER INFO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: AppColors.accent, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Military-Grade Encryption", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                          Text("Your documents are secured with local biometric locks.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // SECURE DOCUMENTS GRID
              const Text("SECURE DOCUMENTS", style: TextStyle(color: Colors.white54, letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  _buildLockedFile("Passport", Icons.book, Colors.blueAccent),
                  _buildLockedFile("Vaccine Card", Icons.health_and_safety, Colors.greenAccent),
                  _buildLockedFile("Flight Tickets", Icons.airplane_ticket, Colors.orangeAccent),
                  _buildLockedFile("Hotel Booking", Icons.hotel, Colors.purpleAccent),
                ],
              ),
              const SizedBox(height: 30),

              // THE PRIVATE FOLDER
              const Text("PRIVATE STORAGE", style: TextStyle(color: Colors.white54, letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Bounceable(
                onTap: () => _securelyOpenDocument("Private Folder"),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.folder_special, color: Colors.redAccent, size: 40),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hidden Files", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                            Text("Requires FaceID / TouchID to open", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.lock, color: Colors.redAccent),
                    ],
                  ),
                ),
              )
            ],
          ),

          // LOADING OVERLAY (Darkens the screen while scanning fingerprint)
          if (_isAuthenticating)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint, color: AppColors.accent, size: 80),
                    SizedBox(height: 20),
                    Text("Verifying Identity...", style: TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLockedFile(String title, IconData icon, Color color) {
    return Bounceable(
      onTap: () => _securelyOpenDocument(title),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Icon(icon, color: color, size: 50),
                const Icon(Icons.lock, color: Colors.white, size: 16), // Little lock icon indicating it's secure
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}