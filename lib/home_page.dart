import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'add_page.dart';
import 'activity_page.dart';
import 'setting_page.dart';
import 'account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _MainHomeContent(),
    CalendarPage(),
    AddPage(),
    ActivityPage(),
    SettingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          SlidePageRoute(page: const AccountPage()),
                        );
                        if (result == 'refresh') {
                          setState(() {});
                        }
                      },
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black12,
                        child: Icon(Icons.person, size: 20, color: Colors.black),
                      ),
                    ),
                    const Text(
                      'DishUp',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home,
                    color: _selectedIndex == 0 ? const Color(0xFF60BC2B) : Colors.black),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(Icons.calendar_month,
                    color: _selectedIndex == 1 ? const Color(0xFF60BC2B) : Colors.black),
                onPressed: () => _onItemTapped(1),
              ),
              Container(
                height: 120,
                width: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFF60BC2B),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  iconSize: 35,
                  onPressed: () => _onItemTapped(2),
                ),
              ),
              IconButton(
                icon: Icon(Icons.monitor_heart,
                    color: _selectedIndex == 3 ? const Color(0xFF60BC2B) : Colors.black),
                onPressed: () => _onItemTapped(3),
              ),
              IconButton(
                icon: Icon(Icons.settings,
                    color: _selectedIndex == 4 ? const Color(0xFF60BC2B) : Colors.black),
                onPressed: () => _onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainHomeContent extends StatelessWidget {
  const _MainHomeContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const Text("Today's Goal", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: 0.5,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 3,
                ),
                const SizedBox(height: 8),
                const Text(
                  '3000 / 6000 Kcal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: const [
                _MealCard('Breakfast'),
                _MealCard('Lunch'),
                _MealCard('Dinner'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  const _MealCard(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(title, style: const TextStyle(fontSize: 16)),
    );
  }
}

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        );
}
