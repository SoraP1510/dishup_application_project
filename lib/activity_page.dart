import 'package:flutter/material.dart';
import 'home_page.dart';
import 'calendar_page.dart';
import 'add_page.dart';
import 'setting_page.dart';
import 'widgets/static_top_bar.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final int _selectedIndex = 3;
  String? _selectedActivity;
  final _hourController = TextEditingController();

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
      case 4:
        page = SettingPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
  context,
  PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  ),
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
              StaticTopBar(),
              const SizedBox(height: 20),
              const Text('ACTIVITY'),
              const SizedBox(height: 6),
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
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('TIME (ชั่วโมง)'),
              const SizedBox(height: 6),
              TextField(
                controller: _hourController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Hours',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    print(
                        "กิจกรรม: $_selectedActivity, เวลา: ${_hourController.text}");

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('บันทึกกิจกรรมเรียบร้อย')),
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