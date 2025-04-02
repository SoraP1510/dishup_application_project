import 'package:flutter/material.dart';
import 'home_page.dart';
import 'calendar_page.dart';
import 'activity_page.dart';
import 'setting_page.dart';
import 'widgets/static_top_bar.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final int _selectedIndex = 2;

  String? _mealType;
  final _menuController = TextEditingController();
  final _kcalController = TextEditingController();
  final _portionController = TextEditingController();

  String get portionHint {
    if (_mealType == 'drink') return 'Glass';
    return 'Gram';
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = CalendarPage();
        break;
      case 3:
        page = ActivityPage();
        break;
      case 4:
        page = SettingPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaticTopBar(),
              const SizedBox(height: 20),
              const Text('MEAL'),
              const SizedBox(height: 6),
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('MENU'),
              const SizedBox(height: 6),
              TextField(
                controller: _menuController,
                decoration: InputDecoration(
                  hintText: 'Menu',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Calorie'),
              const SizedBox(height: 6),
              TextField(
                controller: _kcalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Kcal',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('PORTION'),
              const SizedBox(height: 6),
              TextField(
                controller: _portionController,
                decoration: InputDecoration(
                  hintText: portionHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                      SnackBar(content: Text('บันทึกเรียบร้อย')),
                    );

                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => HomePage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF60BC2B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child:
                      const Text('SAVE', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navIcon(Icons.home, 0),
            _navIcon(Icons.calendar_month, 1),
            _navAddButton(),
            _navIcon(Icons.monitor_heart, 3),
            _navIcon(Icons.settings, 4),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon,
          color: _selectedIndex == index ? Color(0xFF60BC2B) : Colors.black),
      onPressed: () => _onItemTapped(index),
    );
  }

  Widget _navAddButton() {
    return Container(
      height: 120,
      width: 55,
      decoration: BoxDecoration(
        color: Color(0xFF60BC2B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white),
        iconSize: 35,
        onPressed: () => _onItemTapped(2),
      ),
    );
  }
}