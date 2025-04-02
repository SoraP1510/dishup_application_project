import 'package:flutter/material.dart';

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
              onPressed: () {
                final goal = int.tryParse(_controller.text);
                if (goal != null && goal > 0) {
                  Navigator.pop(context, goal);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF60BC2B),
              ),
              child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
