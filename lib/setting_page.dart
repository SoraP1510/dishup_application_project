import 'package:flutter/material.dart';
import 'home_page.dart';
import 'calendar_page.dart';
import 'add_page.dart';
import 'activity_page.dart';
import 'welcome_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final int _selectedIndex = 4;
  bool _notificationEnabled = true;

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
      case 2:
        page = AddPage();
        break;
      case 3:
        page = ActivityPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => WelcomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.account_circle, size: 28),
                  Text('DishUp',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Icon(Icons.notifications, size: 24),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notification',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Switch(
                    value: _notificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationEnabled = value;
                      });
                    },
                    activeColor: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('FAQ / Help Center',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _logout,
                child: const Text(
                  'Log out',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              const Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('App Version', style: TextStyle(fontSize: 14)),
                  Text('0.0.1 (Beta)', style: TextStyle(fontSize: 14)),
                ],
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
