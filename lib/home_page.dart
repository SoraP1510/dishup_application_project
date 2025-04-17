import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'add_page.dart';
import 'activity_page.dart';
import 'setting_page.dart';
import 'models/meal.dart';
import 'models/activity.dart';
import 'goal_page.dart';
import 'widgets/static_top_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Meal> _meals = [];
  List<Activity> _activities = [];
  int _goalKcal = 2000;

  Map<DateTime, List<Meal>> mealsPerDay = {};
  Map<DateTime, List<Activity>> activitiesPerDay = {};

  @override
  void initState() {
    super.initState();
    _fetchMealsFromBackend();
    _fetchGoalKcal();
  }

  Future<void> _fetchGoalKcal() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final baseUrl = dotenv.env['BASE_URL']!;
    final response = await http.get(Uri.parse('$baseUrl/api/profile/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final target = data['kcal_target'];
      if (target != null && target is int) {
        setState(() {
          _goalKcal = target;
        });
      }
    } else {
      print('⚠️ Failed to fetch goal kcal: ${response.body}');
    }
  }

  Future<void> _fetchMealsFromBackend() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final baseUrl = dotenv.env['BASE_URL']!;
    final response =
        await http.get(Uri.parse('$baseUrl/api/meals?user_id=$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      List<Meal> loadedMeals = data.map((json) => Meal.fromJson(json)).toList();

      final Map<DateTime, List<Meal>> mapped = {};
      for (var meal in loadedMeals) {
        final key = DateTime(
            meal.timestamp.year, meal.timestamp.month, meal.timestamp.day);
        mapped.putIfAbsent(key, () => []).add(meal);
      }

      setState(() {
        _meals = loadedMeals;
        mealsPerDay = mapped;
      });
    }
  }

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
        final dateKey = DateTime(
          result.timestamp.year,
          result.timestamp.month,
          result.timestamp.day,
        );

        setState(() {
          _meals.add(result);

          // อัปเดต mealsPerDay
          mealsPerDay.putIfAbsent(dateKey, () => []);
          mealsPerDay[dateKey]!.add(result);

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
        onEditMeal: (editedMeal) async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddPage(existingMeal: editedMeal)),
          );

          if (result != null && result is Meal) {
            final index = _meals.indexWhere((m) => m.id == editedMeal.id);
            if (index != -1) {
              setState(() {
                _meals[index] = result;

                final oldDateKey = DateTime(editedMeal.timestamp.year,
                    editedMeal.timestamp.month, editedMeal.timestamp.day);
                final newDateKey = DateTime(result.timestamp.year,
                    result.timestamp.month, result.timestamp.day);

                mealsPerDay[oldDateKey]
                    ?.removeWhere((m) => m.id == editedMeal.id);
                mealsPerDay.putIfAbsent(newDateKey, () => []).add(result);
              });
            }
          }
        },
        onDeleteMeal: (meal) {
          setState(() {
            _meals.remove(meal);
            final dateKey = DateTime(
                meal.timestamp.year, meal.timestamp.month, meal.timestamp.day);
            mealsPerDay[dateKey]?.remove(meal);
          });
        },
        onEditActivity: (oldAct) async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ActivityPage(existingActivity: oldAct)),
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
              padding:
                  const EdgeInsets.only(top: 18.0, left: 16.0, right: 16.0),
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
                icon: Icon(Icons.home,
                    color: _selectedIndex == 0
                        ? const Color(0xFF60BC2B)
                        : Colors.black),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(Icons.calendar_month,
                    color: _selectedIndex == 1
                        ? const Color(0xFF60BC2B)
                        : Colors.black),
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
                    color: _selectedIndex == 3
                        ? const Color(0xFF60BC2B)
                        : Colors.black),
                onPressed: () => _onItemTapped(3),
              ),
              IconButton(
                icon: Icon(Icons.settings,
                    color: _selectedIndex == 4
                        ? const Color(0xFF60BC2B)
                        : Colors.black),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("Today's Goal", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: goalKcal == 0 ? 0 : totalKcal / goalKcal,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
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
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (meals.isEmpty)
            const Text('No meals yet')
          else
            ...meals.map((m) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child:
                            Text('${m.menu} (${m.kcal} kcal, ${m.portion})')),
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
          const Text('Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
