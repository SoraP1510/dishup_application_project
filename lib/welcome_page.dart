import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/meal_bg.png'), // use your asset path
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // Green Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withOpacity(0.5),
                  Colors.white.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Main Text
          Positioned(
            top: 170,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PLAN", style: _bigText),
                Text("YOUR", style: _bigText),
                Text("MEALS", style: _bigText),
                Text("TODAY!", style: _bigText),
              ],
            ),
          ),

          // Curved white bottom container with buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(30, 50, 30, 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _greenButton(context, "LOGIN", const LoginPage()),
                    const SizedBox(height: 20),
                    _outlinedButton(context, "SIGN UP", const SignUpPage()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlinedButton(BuildContext context, String label, Widget page) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF6DDC5A), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6DDC5A),
          ),
        ),
      ),
    );
  }

  Widget _greenButton(BuildContext context, String label, Widget page) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6DDC5A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

final TextStyle _bigText = GoogleFonts.delaGothicOne(
    fontSize: 50,
    color: Colors.black,
    height: 1.1,
    letterSpacing: 15,
    fontWeight: FontWeight.w400);

// Custom wave clipper for white bottom shape
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 40);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, 40);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}