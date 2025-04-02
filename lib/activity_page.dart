import 'package:flutter/material.dart';
import 'models/activity.dart';

class ActivityPage extends StatefulWidget {
  final Activity? existingActivity;
  final void Function(Activity)? onSave;

  const ActivityPage({super.key, this.existingActivity, this.onSave});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final _hourController = TextEditingController();
  String? _selectedActivity;

  @override
  void initState() {
    super.initState();
    _selectedActivity = widget.existingActivity?.type;
    _hourController.text = widget.existingActivity?.hours ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      widget.existingActivity != null ? 'Edit Activity' : 'Add Activity',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text('ACTIVITY',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedActivity,
                      items: ['นอน', 'ออกกำลังกาย'].map((activity) {
                        return DropdownMenuItem(value: activity, child: Text(activity));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedActivity = value),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                          if (_selectedActivity == null || _hourController.text.isEmpty) return;

                          final activity = Activity(
                            type: _selectedActivity!,
                            hours: _hourController.text,
                          );

                          widget.onSave?.call(activity);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF60BC2B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        child: const Text('SAVE', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
