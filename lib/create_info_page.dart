import 'package:dishup_application/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CreateInfoPage extends StatefulWidget {
  final String fullName;
  final String email;
  final String password;

  const CreateInfoPage({
    super.key,
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  State<CreateInfoPage> createState() => _CreateInfoPageState();
}

class _CreateInfoPageState extends State<CreateInfoPage> {
  String? selectedGender;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  final List<String> genderOptions = ['Male', 'Female', 'Prefer not to answer'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 10),

                        const Text(
                          'ENTER YOUR INFO',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 25),

                        const _Label("Gender"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[100],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            value: selectedGender,
                            hint: const Text("Gender"),
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            items: genderOptions
                                .map((gender) => DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        const _Label("USERNAME"),
                        _inputField("Username", usernameController),
                        const SizedBox(height: 20),

                        const _Label("AGE"),
                        _inputField("Age", ageController,
                            inputType: TextInputType.number),
                        const SizedBox(height: 20),

                        const _Label("WEIGHT (Kilogram)"),
                        _inputField("Weight", weightController,
                            inputType: TextInputType.number),
                        const SizedBox(height: 20),

                        const _Label("HEIGHT (Centimeter)"),
                        _inputField("Height", heightController,
                            inputType: TextInputType.number),
                        const SizedBox(height: 40),

                        
                        Center(
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
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
                                  'FINISH',
                                  style: TextStyle(
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
                        const SizedBox(height: 20), 
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final uuid = const Uuid().v4();
    final username = usernameController.text.trim();
    final age = int.tryParse(ageController.text.trim()) ?? 0;
    final weight = double.tryParse(weightController.text.trim()) ?? 0.0;
    final height = double.tryParse(heightController.text.trim()) ?? 0.0;

    if (username.isEmpty || selectedGender == null || age == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    final baseUrl = dotenv.env['BASE_URL']!;
    final url = Uri.parse('$baseUrl/api/signup');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "id": uuid,
        "fullname": widget.fullName,
        "email": widget.email,
        "password": widget.password,
        "gender": selectedGender,
        "username": username,
        "age": age,
        "weight": weight,
        "height": height,
        "kcal_target": 2000,
        "avatar_url": null,
      }),
    );

    if (response.statusCode == 201) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);
      await prefs.setString('userId', uuid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${response.body}")),
      );
    }
  }

  Widget _inputField(String hint, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    );
  }
}
