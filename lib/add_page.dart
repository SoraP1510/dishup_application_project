import 'package:flutter/material.dart';
import 'models/meal.dart';

class AddPage extends StatefulWidget {
  final Meal? existingMeal; // ✅ ใช้สำหรับแก้ไข

  const AddPage({super.key, this.existingMeal});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String? _mealType;
  final _menuController = TextEditingController();
  final _kcalController = TextEditingController();
  final _portionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingMeal != null) {
      _mealType = widget.existingMeal!.type;
      _menuController.text = widget.existingMeal!.menu;
      _kcalController.text = widget.existingMeal!.kcal;
      _portionController.text = widget.existingMeal!.portion;
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
              const Text('MEAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _mealType,
                items: ['Breakfast','Lunch','Dinner','Snack','Drink']
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('MENU', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _menuController,
                decoration: InputDecoration(
                  hintText: 'Menu',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              if (_mealType != 'Drink') ...[
                const Text('Calorie', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _kcalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Kcal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Text('PORTION', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _portionController,
                decoration: InputDecoration(
                  hintText: portionHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final newMeal = Meal(
                      type: _mealType ?? '',
                      menu: _menuController.text,
                      kcal: _mealType == 'Drink' ? '0' : _kcalController.text,
                      portion: _portionController.text,
                    );
                    Navigator.pop(context, newMeal);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60BC2B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(widget.existingMeal != null ? 'SAVE CHANGES' : 'SAVE',
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
