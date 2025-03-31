import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _navigateWithSlide(BuildContext context, Widget page) async {
    await _textController.forward();
    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/meal_bg1.jpg'),
                fit: BoxFit.cover,
                alignment: Alignment(-0.25, 0),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DishUp',
                        style: GoogleFonts.fugazOne(
                          fontSize: 70,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 0),
                      Text(
                        'PLAN YOUR',
                        style: GoogleFonts.fugazOne(
                          fontSize: 18,
                          color: Colors.black,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'MEALS TODAY !',
                        style: GoogleFonts.fugazOne(
                          fontSize: 22,
                          color: Colors.black,
                          letterSpacing: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 160),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _animatedButton(context, "LOGIN", const LoginPage()),
                  const SizedBox(height: 20),
                  _animatedButton(context, "SIGN UP", const SignUpPage()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedButton(BuildContext context, String label, Widget page) {
    return GestureDetector(
      onTap: () => _navigateWithSlide(context, page),
      child: Container(
        width: 300,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6DDC5A), Color(0xFF5ACD49)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
