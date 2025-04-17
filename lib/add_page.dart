import 'package:flutter/material.dart';
import 'models/meal.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddPage extends StatefulWidget {
  final Meal? existingMeal;

  const AddPage({super.key, this.existingMeal});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String? _mealType;
  final _menuController = TextEditingController();
  final _kcalController = TextEditingController();
  final _portionController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    if (widget.existingMeal != null) {
      _mealType = widget.existingMeal!.type[0].toUpperCase() +
          widget.existingMeal!.type.substring(1);
      _menuController.text = widget.existingMeal!.menu;
      _kcalController.text = widget.existingMeal!.kcal;
      _portionController.text = widget.existingMeal!.portion;
      _selectedDateTime = widget.existingMeal!.timestamp.toLocal();
    }
  }

  String get portionHint {
    if (_mealType == 'Drink') return 'Glass';
    return 'Gram';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingMeal != null ? 'Edit Meal' : 'Add Meal'),
        backgroundColor: const Color(0xFF60BC2B),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('MEAL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _mealType,
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Drink']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _mealType = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('NAME', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _menuController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Calorie',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _kcalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter calorie',
                  suffixText: 'Kcal',
                  suffixStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('PORTION',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _portionController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  suffixText: _mealType == 'Drink' ? 'glass' : 'grams',
                  suffixStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('DATE & TIME',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          _selectedDateTime ?? DateTime.now()),
                    );

                    if (pickedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedDateTime != null
                        ? '${_selectedDateTime!.toLocal()}'.split('.').first
                        : 'Select date and time',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_mealType == null ||
                        _menuController.text.isEmpty ||
                        _portionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please complete all fields')),
                      );
                      return;
                    }

                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getString('userId');

                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in')),
                      );
                      return;
                    }

                    final baseUrl = dotenv.env['BASE_URL']!;
                    final mealId = widget.existingMeal?.id ?? const Uuid().v4();
                    final DateTime timestamp =
                        (_selectedDateTime ?? DateTime.now());
                    String _twoDigits(int n) => n.toString().padLeft(2, '0');
                    final formattedTimestamp =
                        '${timestamp.year}-${_twoDigits(timestamp.month)}-${_twoDigits(timestamp.day)} '
                        '${_twoDigits(timestamp.hour)}:${_twoDigits(timestamp.minute)}:${_twoDigits(timestamp.second)}';

                    final mealData = {
                      'id': mealId,
                      'user_id': userId,
                      'name': _menuController.text,
                      'type': _mealType!.toLowerCase(),
                      'portion': _portionController.text,
                      'energy': int.tryParse(_kcalController.text) ?? 0,
                      'timestamp': formattedTimestamp,
                    };

                    final url = widget.existingMeal == null
                        ? Uri.parse('$baseUrl/api/meals')
                        : Uri.parse(
                            '$baseUrl/api/meals/${widget.existingMeal!.id}');

                    final response = await (widget.existingMeal == null
                        ? http.post(url,
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode(mealData))
                        : http.put(url,
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode(mealData)));

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      final meal = Meal(
                        id: mealId,
                        userId: userId,
                        menu: _menuController.text,
                        kcal: _kcalController.text,
                        type: _mealType!,
                        portion: _portionController.text,
                        timestamp: (_selectedDateTime ?? DateTime.now()),
                      );

                      Navigator.pop(context, meal);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${response.body}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60BC2B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                      widget.existingMeal != null ? 'SAVE CHANGES' : 'SAVE',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
