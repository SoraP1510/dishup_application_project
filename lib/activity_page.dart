import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String? _selectedActivity;
  final _hourController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('ACTIVITY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedActivity,
            items: ['นอน', 'ออกกำลังกาย']
                .map((activity) => DropdownMenuItem(
                      value: activity,
                      child: Text(activity),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedActivity = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('TIME (ชั่วโมง)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _hourController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Hours',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: () {
                print("กิจกรรม: $_selectedActivity, เวลา: ${_hourController.text}");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('บันทึกกิจกรรมเรียบร้อย')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF60BC2B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('SAVE', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
