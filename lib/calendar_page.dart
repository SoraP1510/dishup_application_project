import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'home_page.dart';
import 'add_page.dart';
import 'activity_page.dart';
import 'setting_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final int _selectedIndex = 1;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = HomePage();
        break;
      case 2:
        page = AddPage();
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.account_circle, size: 28),
                  Text('DishUp', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Icon(Icons.notifications, size: 24),
                ],
              ),
              const SizedBox(height: 20),
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: const [
                    Text('Meal/Activity History Placeholder'),
                  ],
                ),
              ),
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
      icon: Icon(icon, color: _selectedIndex == index ? Color(0xFF60BC2B) : Colors.black),
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
