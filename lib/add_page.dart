import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String? _mealType;
  final _menuController = TextEditingController();
  final _kcalController = TextEditingController();
  final _portionController = TextEditingController();

  String get portionHint {
    if (_mealType == 'drink') return 'Glass';
    return 'Gram';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              items: ['meal', 'snack', 'drink']
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('MENU', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _menuController,
              decoration: InputDecoration(
                hintText: 'Menu',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                hintText: 'Kcal',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('PORTION',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _portionController,
              decoration: InputDecoration(
                hintText: portionHint,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print({
                    'type': _mealType,
                    'menu': _menuController.text,
                    'kcal': _kcalController.text,
                    'portion': _portionController.text,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('บันทึกเรียบร้อย')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF60BC2B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                ),
                child: const Text('SAVE',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
