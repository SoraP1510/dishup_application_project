import 'package:flutter/material.dart';
import 'models/activity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ActivityPage extends StatefulWidget {
  final Activity? existingActivity;
  final void Function(Activity)? onSave;

  const ActivityPage({super.key, this.existingActivity, this.onSave});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final _hourController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  bool _dontKnowCalories = false;

  String? _selectedActivity;
  TimeOfDay? _sleepStart;
  TimeOfDay? _sleepEnd;

  @override
  void initState() {
    super.initState();
    _selectedActivity = widget.existingActivity?.type;
    _hourController.text = widget.existingActivity?.hours ?? '';
    _descriptionController.text = widget.existingActivity?.description ?? '';
    _caloriesController.text = widget.existingActivity?.calories ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isSleep = _selectedActivity == 'Sleep';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingActivity != null
                    ? 'Edit Activity'
                    : 'Add Activity',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('ACTIVITY',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedActivity,
                items: ['Sleep', 'Exercise'].map((activity) {
                  return DropdownMenuItem(
                      value: activity, child: Text(activity));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivity = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              if (_selectedActivity != 'Sleep') ...[
                const Text('DESCRIPTION',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (!isSleep) ...[
                const Text('CALORIES BURNED (ถ้ามี)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _caloriesController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        enabled: !_dontKnowCalories,
                        decoration: InputDecoration(
                          hintText: 'Calories',
                          suffixText: 'Kcal',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        Checkbox(
                          value: _dontKnowCalories,
                          onChanged: (val) {
                            setState(() {
                              _dontKnowCalories = val ?? false;
                              if (_dontKnowCalories) {
                                _caloriesController.clear();
                              }
                            });
                          },
                        ),
                        const Text('Don\'t\nknow',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 20),
              if (_selectedActivity == 'Exercise') ...[
                const Text('DURATION (ชั่วโมง)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _hourController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Hours exercised',
                    suffixText: 'hrs',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
              if (isSleep) ...[
                const Text('SLEEP TIME',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _buildTimePicker(
                  label: 'Sleep time',
                  time: _sleepStart,
                  onPressed: () => _selectTime(context, true),
                ),
                const SizedBox(height: 10),
                _buildTimePicker(
                  label: 'Wake up time',
                  time: _sleepEnd,
                  onPressed: () => _selectTime(context, false),
                ),
              ],
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedActivity == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select an activity type')),
                      );
                      return;
                    }
                    // Validate Exercise duration
                    if (_selectedActivity == 'Exercise') {
                      final hourVal =
                          double.tryParse(_hourController.text.trim());
                      if (hourVal == null || hourVal <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please enter a valid number of hours')),
                        );
                        return;
                      }
                    }

                    // Validate Sleep time
                    if (_selectedActivity == 'Sleep') {
                      if (_sleepStart == null || _sleepEnd == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please select both sleep and wake times')),
                        );
                        return;
                      }
                    }

                    String minutes = '0';
                    String breakdownMessage = '';

                    if (_selectedActivity == 'Sleep' &&
                        _sleepStart != null &&
                        _sleepEnd != null) {
                      final now = DateTime.now();
                      final start = DateTime(now.year, now.month, now.day,
                          _sleepStart!.hour, _sleepStart!.minute);
                      final end = DateTime(now.year, now.month, now.day,
                          _sleepEnd!.hour, _sleepEnd!.minute);
                      final duration = end.difference(start);
                      minutes = duration.inMinutes.toString();
                      final hours =
                          (duration.inMinutes / 60).toStringAsFixed(2);
                      breakdownMessage =
                          '$minutes minutes = $hours hours (sleep)';
                    } else if (_selectedActivity == 'Exercise') {
                      final hourValue =
                          double.tryParse(_hourController.text.trim()) ?? 0;
                      final calculatedMinutes = (hourValue * 60).round();
                      minutes = calculatedMinutes.toString();
                      breakdownMessage =
                          '$minutes minutes = $hourValue hours (exercise)';
                    }

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: Row(
                          children: const [
                            Icon(Icons.timer, color: Color(0xFF60BC2B)),
                            SizedBox(width: 10),
                            Text('Duration Confirmation'),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedActivity == 'Sleep'
                                  ? '😴 You slept for:\n🕒 $breakdownMessage'
                                  : '🏃 You exercised for:\n🕒 $breakdownMessage',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            const Text('Do you want to save this activity?',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context, true),
                            label: const Text('Save Activity'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF60BC2B),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    final activity = Activity(
                      type: _selectedActivity!,
                      hours: minutes,
                      description: _descriptionController.text,
                      calories: _dontKnowCalories
                          ? 'unknown'
                          : _caloriesController.text,
                    );

                    final uuid = const Uuid().v4();
                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getString('userId');
                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in')),
                      );
                      return;
                    }

                    final now = DateTime.now();
                    DateTime? sleepStartDateTime;
                    DateTime? wakeTimeDateTime;

                    if (_selectedActivity == 'Sleep' &&
                        _sleepStart != null &&
                        _sleepEnd != null) {
                      sleepStartDateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        _sleepStart!.hour,
                        _sleepStart!.minute,
                      );
                      wakeTimeDateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        _sleepEnd!.hour,
                        _sleepEnd!.minute,
                      );

                      // กรณีนอนข้ามวัน
                      if (wakeTimeDateTime.isBefore(sleepStartDateTime)) {
                        wakeTimeDateTime =
                            wakeTimeDateTime.add(const Duration(days: 1));
                      }
                    }
                    final baseUrl = dotenv.env['BASE_URL']!;

                    final response = await http.post(
                      Uri.parse('$baseUrl/api/activities'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'id': uuid,
                        'user_id': userId,
                        "activity_type": _selectedActivity?.toLowerCase() ?? '',
                        'description': _descriptionController.text.trim(),
                        'duration_minutes': int.tryParse(minutes) ?? 0,
                        'timestamp': now.toIso8601String(),
                        'sleep_time': sleepStartDateTime?.toIso8601String(),
                        'wake_time': wakeTimeDateTime?.toIso8601String(),
                        'cal_burned': _dontKnowCalories
                            ? null
                            : int.tryParse(_caloriesController.text.trim()) ??
                                0,
                      }),
                    );

                    if (response.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Activity saved successfully')),
                      );
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${response.body}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60BC2B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child:
                      const Text('SAVE', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _sleepStart = picked;
        } else {
          _sleepEnd = picked;
        }
      });
    }
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          time != null ? time.format(context) : label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
