import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './widgets/static_top_bar.dart';
import 'country_list.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController avatarUrlController = TextEditingController();
  String selectedCountry = 'Thailand';
  String? userId;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId == null) return;

    final baseUrl = dotenv.env['BASE_URL']!;
    final uri = Uri.parse('$baseUrl/api/profile/$userId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        nameController.text = data['username'] ?? '';
        emailController.text = data['email'] ?? '';
        passwordController.text = data['password'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        weightController.text = data['weight']?.toString() ?? '';
        heightController.text = data['height']?.toString() ?? '';
        selectedCountry = data['country'] ?? 'Thailand';
        avatarUrl = data['avatar_url'];
      });
    } else {
      print('Error loading profile: ${response.body}');
    }
  }

  Future<void> _saveProfile() async {
    if (userId == null) return;
    final baseUrl = dotenv.env['BASE_URL']!;
    final uri = Uri.parse('$baseUrl/api/profile/$userId');
    final response = await http.put(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": nameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "age": int.tryParse(ageController.text.trim()) ?? 0,
        "country": selectedCountry,
        "weight": double.tryParse(weightController.text.trim()) ?? 0.0,
        "height": double.tryParse(heightController.text.trim()) ?? 0.0,
        "avatar_url": avatarUrl,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      Navigator.pop(context, 'refresh'); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.fromLTRB(20, 18, 18, 0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const StaticTopBar(),
                const SizedBox(height: 10),

                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          avatarUrl != null && avatarUrl!.isNotEmpty
                              ? NetworkImage(avatarUrl!)
                              : const AssetImage('assets/images/user.jpg')
                                  as ImageProvider,
                      backgroundColor: Colors.grey[200],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _promptAvatarUrl,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.camera_alt, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _label("Username"),
                _inputField(nameController),
                const SizedBox(height: 12),
                _label("Email"),
                _inputField(emailController),
                const SizedBox(height: 12),
                _label("Password"),
                _inputField(passwordController, obscure: true),
                const SizedBox(height: 12),
                _label("Age"),
                _inputField(ageController, inputType: TextInputType.number),
                const SizedBox(height: 12),
                _label("Weight (kg)"),
                _inputField(weightController, inputType: TextInputType.number),
                const SizedBox(height: 12),
                _label("Height (cm)"),
                _inputField(heightController, inputType: TextInputType.number),
                const SizedBox(height: 12),
                _label("Country/Region"),
                _countryDropdown(),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6DDC5A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'SAVE',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(text,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      );

  Widget _inputField(TextEditingController controller,
      {bool obscure = false, TextInputType inputType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: inputType,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  void _promptAvatarUrl() async {
    avatarUrlController.text = avatarUrl ?? '';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Image URL'),
        content: TextField(
          controller: avatarUrlController,
          decoration:
              const InputDecoration(hintText: 'https://example.com/avatar.jpg'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                avatarUrl = avatarUrlController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _countryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCountry,
        icon: const Icon(Icons.arrow_drop_down),
        decoration: const InputDecoration(border: InputBorder.none),
        items: countries
            .map((country) => DropdownMenuItem(
                  value: country,
                  child: Text(country),
                ))
            .toList(),
        onChanged: (value) {
          setState(() => selectedCountry = value!);
        },
      ),
    );
  }
}
