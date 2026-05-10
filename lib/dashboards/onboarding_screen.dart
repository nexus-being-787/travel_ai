import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'login_page.dart'; // Where we go after finishing
import 'theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Common Style for text
    const bodyStyle = TextStyle(fontSize: 18.0, color: Colors.white70);
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.black, // Dark Theme
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      globalBackgroundColor: Colors.black,
      allowImplicitScrolling: true,
      autoScrollDuration: 3000, // Auto slide every 3 seconds
      
      pages: [
        // SLIDE 1: PLANNER
        PageViewModel(
          title: "AI Travel Architect",
          body: "Don't just plan. Create. \nLet Gemini build your perfect itinerary in seconds.",
          image: _buildImage(Icons.map_outlined, Colors.blueAccent),
          decoration: pageDecoration,
        ),
        
        // SLIDE 2: TRANSLATOR
        PageViewModel(
          title: "Speak Like a Local",
          body: "Real-time voice translation breaks down every language barrier.",
          image: _buildImage(Icons.record_voice_over, Colors.purpleAccent),
          decoration: pageDecoration,
        ),
        
        // SLIDE 3: SAFETY & TOOLS
        PageViewModel(
          title: "Travel Fearlessly",
          body: "Safety ratings, hidden gems, and expense tracking in one secure vault.",
          image: _buildImage(Icons.shield_moon, AppColors.accent),
          decoration: pageDecoration,
        ),
      ],
      
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can skip to login
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      
      // BUTTON STYLES
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white54)),
      next: const Icon(Icons.arrow_forward, color: AppColors.accent),
      done: const Text('START', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
      
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.white24,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25.0))),
        activeColor: AppColors.accent,
      ),
    );
  }

  Widget _buildImage(IconData icon, Color color) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 50)],
      ),
      child: Icon(icon, size: 100, color: color),
    );
  }
}