import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoalPage extends StatefulWidget {
  final int currentGoal;
  const GoalPage({super.key, required this.currentGoal});

  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentGoal.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งเป้าหมาย Kcal'),
        backgroundColor: const Color(0xFF60BC2B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('กำหนดเป้าหมายพลังงานที่ต้องการในแต่ละวัน (Kcal)',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'เป้าหมาย Kcal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final goal = int.tryParse(_controller.text);
                if (goal != null && goal > 0) {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('userId');
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not logged in')),
                    );
                    return;
                  }

                  final baseUrl = dotenv.env['BASE_URL']!;
                  final response = await http.put(
                    Uri.parse('$baseUrl/api/profile/$userId'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'kcal_target': goal}),
                  );

                  if (response.statusCode == 200) {
                    Navigator.pop(context, goal); 
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Failed to update goal: ${response.body}')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF60BC2B),
              ),
              child:
                  const Text('บันทึก', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
