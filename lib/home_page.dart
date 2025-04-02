import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'add_page.dart';
import 'activity_page.dart';
import 'setting_page.dart';
import 'models/meal.dart';
import 'models/activity.dart';
import 'goal_page.dart';
import 'widgets/static_top_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Meal> _meals = [];
  List<Activity> _activities = [];
  int _goalKcal = 6000;

  Map<DateTime, List<Meal>> mealsPerDay = {};
  Map<DateTime, List<Activity>> activitiesPerDay = {};

  void _updateGoalKcal(int newGoal) {
    setState(() {
      _goalKcal = newGoal;
    });
  }

  int _totalKcal() => _meals.fold(0, (sum, meal) {
        final parsed = int.tryParse(meal.kcal);
        return sum + (parsed ?? 0);
      });

  void _onItemTapped(int index) async {
    if (index == 2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddPage()),
      );
      if (result != null && result is Meal) {
        final now = DateTime.now();
        final dayKey = DateTime(now.year, now.month, now.day);

        setState(() {
          _meals.add(result);
          mealsPerDay.putIfAbsent(dayKey, () => []);
          mealsPerDay[dayKey]!.add(result);
          _selectedIndex = 0;
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _MainHomeContent(
        meals: _meals,
        activities: _activities,
        goalKcal: _goalKcal,
        totalKcal: _totalKcal(),
        onTapGoalCard: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GoalPage(currentGoal: _goalKcal)),
          );
          if (result != null && result is int) {
            _updateGoalKcal(result);
          }
        },
        onEditMeal: (oldMeal) async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPage(existingMeal: oldMeal)),
          );
          if (result != null && result is Meal) {
            setState(() {
              final index = _meals.indexOf(oldMeal);
              if (index != -1) _meals[index] = result;
            });
          }
        },
        onDeleteMeal: (meal) {
          setState(() => _meals.remove(meal));
        },
        onEditActivity: (oldAct) async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ActivityPage(existingActivity: oldAct)),
          );
          if (result != null && result is Activity) {
            setState(() {
              final index = _activities.indexOf(oldAct);
              if (index != -1) _activities[index] = result;
            });
          }
        },
        onDeleteActivity: (act) {
          setState(() => _activities.remove(act));
        },
      ),
      CalendarPage(
        mealsPerDay: mealsPerDay,
        activitiesPerDay: activitiesPerDay,
        onEditMeal: (_) {},
        onDeleteMeal: (_) {},
        onEditActivity: (_) {},
        onDeleteActivity: (_) {},
      ),
      const AddPage(),
      const ActivityPage(), 
      const SettingPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
  padding: const EdgeInsets.only(top: 18.0, left: 16.0, right: 16.0),
  child: const StaticTopBar(),
),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: pages,
              ),
            ),
          ],
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
                icon: Icon(Icons.home, color: _selectedIndex == 0 ? const Color(0xFF60BC2B) : Colors.black),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(Icons.calendar_month, color: _selectedIndex == 1 ? const Color(0xFF60BC2B) : Colors.black),
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
                icon: Icon(Icons.monitor_heart, color: _selectedIndex == 3 ? const Color(0xFF60BC2B) : Colors.black),
                onPressed: () => _onItemTapped(3),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: _selectedIndex == 4 ? const Color(0xFF60BC2B) : Colors.black),
                onPressed: () => _onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====== MAIN CONTENT ======

class _MainHomeContent extends StatelessWidget {
  final List<Meal> meals;
  final List<Activity> activities;
  final int goalKcal;
  final int totalKcal;
  final VoidCallback onTapGoalCard;
  final Function(Meal) onEditMeal;
  final Function(Meal) onDeleteMeal;
  final Function(Activity) onEditActivity;
  final Function(Activity) onDeleteActivity;

  const _MainHomeContent({
    required this.meals,
    required this.activities,
    required this.goalKcal,
    required this.totalKcal,
    required this.onTapGoalCard,
    required this.onEditMeal,
    required this.onDeleteMeal,
    required this.onEditActivity,
    required this.onDeleteActivity,
  });

  List<Meal> _filterMeals(String type) =>
      meals.where((m) => m.type.toLowerCase() == type.toLowerCase()).toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: onTapGoalCard,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("Today's Goal", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: goalKcal == 0 ? 0 : totalKcal / goalKcal,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  Text('$totalKcal / $goalKcal Kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        for (var type in ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Drink'])
          _MealCard(type, _filterMeals(type), onEditMeal, onDeleteMeal),
        _ActivityCard(activities, onEditActivity, onDeleteActivity),
      ],
    );
  }
}

// ====== MEAL CARD ======

class _MealCard extends StatelessWidget {
  final String title;
  final List<Meal> meals;
  final Function(Meal) onEdit;
  final Function(Meal) onDelete;

  const _MealCard(this.title, this.meals, this.onEdit, this.onDelete);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15.0), 
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height:8),
          if (meals.isEmpty)
            const Text('No meals yet')
          else
            ...meals.map((m) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${m.menu} (${m.kcal} kcal, ${m.portion})')),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => onEdit(m),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => onDelete(m),
                        ),
                      ],
                    ),
                  ],
                )),
        ],
      ),
    );
  }
}

// ====== ACTIVITY CARD ======

class _ActivityCard extends StatelessWidget {
  final List<Activity> activities;
  final Function(Activity) onEdit;
  final Function(Activity) onDelete;

  const _ActivityCard(this.activities, this.onEdit, this.onDelete);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15.0), 
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (activities.isEmpty)
            const Text('No activity yet')
          else
            ...activities.map((a) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${a.type} ${a.hours} ชม.')),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => onEdit(a),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => onDelete(a),
                        ),
                      ],
                    ),
                  ],
                )),
        ],
      ),
    );
  }
}
