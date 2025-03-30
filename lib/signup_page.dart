import 'package:dishup_application/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'create_info_page.dart';
import 'welcome_page.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Arrow
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WelcomePage()),
                      ),
              ),
              const SizedBox(height: 10),

              // Title
              const Text(
                'CREATE ACCOUNT',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Full Name
              const InputLabel("FULL NAME"),
              CustomInputField(hint: "Full name"),
              const SizedBox(height: 20),

              // Email
              const InputLabel("EMAIL"),
              CustomInputField(hint: "Email"),
              const SizedBox(height: 20),

              // Password
              const InputLabel("PASSWORD"),
              CustomInputField(hint: "Password", obscure: true),
              const SizedBox(height: 20),

              // Confirm Password
              const InputLabel("CONFIRM PASSWORD"),
              CustomInputField(hint: "Confirm Password", obscure: true),
              const SizedBox(height: 35),

              // Sign Up Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateInfoPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6DDC5A),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'SIGN UP',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Already have an account?
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Sign in',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3DDC84),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable input label
class InputLabel extends StatelessWidget {
  final String text;
  const InputLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    );
  }
}

// Reusable input field
class CustomInputField extends StatelessWidget {
  final String hint;
  final bool obscure;
  const CustomInputField({super.key, required this.hint, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
