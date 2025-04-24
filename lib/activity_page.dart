import 'package:dishup_application/home_page.dart';
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

  DateTime? _sleepDate;
  DateTime? _exerciseDate;
  bool _dontKnowCalories = false;

  String? _selectedActivity;
  TimeOfDay? _sleepStart;
  TimeOfDay? _sleepEnd;

  @override
  void initState() {
    super.initState();

    final existing = widget.existingActivity;
    _selectedActivity = existing?.type;

    if (_selectedActivity != null) {
      _selectedActivity = _selectedActivity![0].toUpperCase() +
          _selectedActivity!.substring(1).toLowerCase();
    }

    if (existing != null && existing.hours.isNotEmpty) {
      final minutes = int.tryParse(existing.hours) ?? 0;
      _hourController.text = (minutes / 60).toStringAsFixed(2);
    }

    _descriptionController.text = existing?.description ?? '';
    _caloriesController.text = existing?.calories ?? '';

    if (existing?.type.toLowerCase() == 'sleep') {
      if (existing!.sleepTime != null) {
        final sleepTime = DateTime.parse(existing.sleepTime!).toLocal();
        _sleepDate = DateTime(sleepTime.year, sleepTime.month, sleepTime.day);
        _sleepStart = TimeOfDay(hour: sleepTime.hour, minute: sleepTime.minute);
      }
      if (existing.wakeTime != null) {
        final wakeTime = DateTime.parse(existing.wakeTime!).toLocal();
        _sleepEnd = TimeOfDay(hour: wakeTime.hour, minute: wakeTime.minute);
      }
    }

    if (existing?.type.toLowerCase() == 'exercise' &&
        existing!.timestamp != null) {
      final exerciseDate = DateTime.tryParse(existing.timestamp!);
      if (exerciseDate != null) {
        _exerciseDate =
            DateTime(exerciseDate.year, exerciseDate.month, exerciseDate.day);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSleep = _selectedActivity == 'Sleep';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.existingActivity != null,
        title: Text(
            widget.existingActivity != null ? 'Edit Activity' : 'Add Activity'),
        backgroundColor: const Color(0xFF60BC2B),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActivityDropdown(),
              const SizedBox(height: 20),
              if (_selectedActivity == 'Exercise' ||
                  _selectedActivity == 'Sleep')
                _buildDescriptionField(),
              if (_selectedActivity == 'Sleep')
                _buildDatePickerSection(
                  'SLEEP DATE',
                  _sleepDate,
                  () => _selectDate(isSleep: true),
                ),
              if (_selectedActivity == 'Exercise')
                _buildDatePickerSection(
                  'EXERCISE DATE',
                  _exerciseDate,
                  () => _selectDate(isSleep: false),
                ),
              if (_selectedActivity == 'Exercise') _buildCaloriesField(),
              if (_selectedActivity == 'Exercise') _buildDurationField(),
              if (_selectedActivity == 'Sleep') _buildTimePickers(),
              const SizedBox(height: 30),
              if (_selectedActivity != null) Center(child: _buildSaveButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedActivity,
      items: ['Sleep', 'Exercise'].map((activity) {
        return DropdownMenuItem(value: activity, child: Text(activity));
      }).toList(),
      onChanged: (value) => setState(() {
        _selectedActivity = value;
        _hourController.clear();
        _descriptionController.clear();
        _caloriesController.clear();
        _sleepDate = null;
        _sleepStart = null;
        _sleepEnd = null;
        _exerciseDate = null;
        _dontKnowCalories = false;
      }),
      decoration: InputDecoration(
        labelText: 'ACTIVITY',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DESCRIPTION',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: _descriptionController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Enter activity description (optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDatePickerSection(
      String title, DateTime? date, VoidCallback onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _buildDatePicker(
            label: 'Select date', date: date, onPressed: onPressed),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCaloriesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CALORIES BURNED',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _caloriesController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                  onChanged: (val) => setState(() {
                    _dontKnowCalories = val ?? false;
                    if (_dontKnowCalories) _caloriesController.clear();
                  }),
                ),
                const Text("Don't\nknow", style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DURATION', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: _hourController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Hours exercised',
            suffixText: 'hrs',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickers() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('SLEEP TIME', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('WAKE TIME', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
                child: _buildTimePicker(
                    label: 'Sleep time',
                    time: _sleepStart,
                    onPressed: () => _selectTime(context, true))),
            const SizedBox(width: 10),
            Expanded(
                child: _buildTimePicker(
                    label: 'Wake time',
                    time: _sleepEnd,
                    onPressed: () => _selectTime(context, false))),
          ],
        ),
      ],
    );
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

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF60BC2B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      ),
      child: const Text('SAVE', style: TextStyle(color: Colors.white)),
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

  Future<void> _selectDate({required bool isSleep}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isSleep) {
          _sleepDate = picked;
        } else {
          _exerciseDate = picked;
        }
      });
    }
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
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
          date != null ? "${date.toLocal()}".split(' ')[0] : label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final uuid = const Uuid().v4();
    final id = widget.existingActivity?.id ?? uuid;
    final activity = Activity(
      id: id,
      type: _selectedActivity!,
      hours: _hourController.text,
      description: _descriptionController.text,
      calories: _dontKnowCalories ? 'unknown' : _caloriesController.text,
    );

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }
    if (_selectedActivity == 'Exercise') {
      if (_exerciseDate == null || _hourController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all exercise fields')),
        );
        return;
      }
    } else if (_selectedActivity == 'Sleep') {
      if (_sleepDate == null || _sleepStart == null || _sleepEnd == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all sleep fields')),
        );
        return;
      }
    }

    String minutes = '0';
    if (_selectedActivity == 'Sleep' &&
        _sleepStart != null &&
        _sleepEnd != null) {
      final baseDate = _sleepDate ?? DateTime.now();
      final start = DateTime(baseDate.year, baseDate.month, baseDate.day,
          _sleepStart!.hour, _sleepStart!.minute);
      var end = DateTime(baseDate.year, baseDate.month, baseDate.day,
          _sleepEnd!.hour, _sleepEnd!.minute);
      if (end.isBefore(start)) end = end.add(const Duration(days: 1));
      minutes = end.difference(start).inMinutes.toString();
    } else if (_selectedActivity == 'Exercise') {
      final hourValue = double.tryParse(_hourController.text.trim()) ?? 0;
      minutes = (hourValue * 60).round().toString();
    }

    final baseUrl = dotenv.env['BASE_URL']!;
    final now = DateTime.now();
    final activityDate =
        _selectedActivity == 'Exercise' ? _exerciseDate : _sleepDate;
    final timestamp = DateTime(
      activityDate?.year ?? now.year,
      activityDate?.month ?? now.month,
      activityDate?.day ?? now.day,
      now.hour,
      now.minute,
      now.second,
    ).toIso8601String();

    final sleepStart = _sleepDate != null && _sleepStart != null
        ? DateTime(_sleepDate!.year, _sleepDate!.month, _sleepDate!.day,
                _sleepStart!.hour, _sleepStart!.minute)
            .toIso8601String()
        : null;

    final sleepEnd = _sleepDate != null && _sleepEnd != null
        ? DateTime(_sleepDate!.year, _sleepDate!.month, _sleepDate!.day,
                _sleepEnd!.hour, _sleepEnd!.minute)
            .toIso8601String()
        : null;

    final isEditing = widget.existingActivity != null;
    final url = isEditing
        ? '$baseUrl/api/activities/${widget.existingActivity!.id}'
        : '$baseUrl/api/activities';

    final response = isEditing
        ? await http.put(Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'user_id': userId,
              'activity_type': _selectedActivity?.toLowerCase() ?? '',
              'description': _descriptionController.text.trim(),
              'duration_minutes': int.tryParse(minutes) ?? 0,
              'timestamp': timestamp,
              'sleep_time': sleepStart,
              'wake_time': sleepEnd,
              'cal_burned': _dontKnowCalories
                  ? null
                  : int.tryParse(_caloriesController.text.trim()) ?? 0,
            }))
        : await http.post(Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'id': uuid,
              'user_id': userId,
              'activity_type': _selectedActivity?.toLowerCase() ?? '',
              'description': _descriptionController.text.trim(),
              'duration_minutes': int.tryParse(minutes) ?? 0,
              'timestamp': timestamp,
              'sleep_time': sleepStart,
              'wake_time': sleepEnd,
              'cal_burned': _dontKnowCalories
                  ? null
                  : int.tryParse(_caloriesController.text.trim()) ?? 0,
            }));

    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Activity saved successfully')),
      );
      if (widget.onSave != null) widget.onSave!(activity);

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Go to Home?'),
          content: const Text(
              'Your activity has been saved. Would you like to go to the Home page?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay here'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${response.body}')),
      );
    }
  }
}
