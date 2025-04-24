import 'package:dishup_application/login_page.dart';
import 'package:dishup_application/create_info_page.dart';
import 'package:dishup_application/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WelcomePage()),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      'CREATE ACCOUNT',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),

                    const InputLabel("FULL NAME"),
                    CustomInputField(
                        hint: "Full name", controller: nameController),
                    const SizedBox(height: 20),

                    const InputLabel("EMAIL"),
                    CustomInputField(
                        hint: "Email", controller: emailController),
                    const SizedBox(height: 20),

                    const InputLabel("PASSWORD"),
                    CustomInputField(
                        hint: "Password",
                        obscure: true,
                        controller: passwordController),
                    const SizedBox(height: 20),

                    const InputLabel("CONFIRM PASSWORD"),
                    CustomInputField(
                        hint: "Confirm Password",
                        obscure: true,
                        controller: confirmPasswordController),
                    const SizedBox(height: 35),

                    // Sign Up Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          final fullName = nameController.text.trim();
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();
                          final confirm =
                              confirmPasswordController.text.trim();

                          if (fullName.isEmpty ||
                              email.isEmpty ||
                              password.isEmpty ||
                              confirm != password) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please check your input")),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateInfoPage(
                                fullName: fullName,
                                email: email,
                                password: password,
                              ),
                            ),
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
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Already have an account?
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13),
                          children: [
                            TextSpan(
                              text: 'Sign in',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3DDC84),
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Input label
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

// Input field
class CustomInputField extends StatelessWidget {
  final String hint;
  final bool obscure;
  final TextEditingController? controller;

  const CustomInputField({
    super.key,
    required this.hint,
    this.obscure = false,
    this.controller,
  });

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
        controller: controller,
        obscureText: obscure,
        keyboardType: hint.toLowerCase().contains("email")
            ? TextInputType.emailAddress
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
