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
  final GlobalKey<StaticTopBarState> staticTopBarKey = GlobalKey();
  List<Meal> _meals = [];
  List<Activity> _activities = [];
  int _goalKcal = 2000;
  String? _quote;

  Map<DateTime, List<Meal>> mealsPerDay = {};
  Map<DateTime, List<Activity>> activitiesPerDay = {};

  @override
  void initState() {
    super.initState();
    _fetchTodayData();
    _fetchGoalKcal();
    _fetchQuote();
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

  Future<void> _fetchQuote() async {
    final baseUrl = dotenv.env['BASE_URL']!;
    final response = await http.get(Uri.parse('$baseUrl/api/quotes/random'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _quote = data['quote'];
      });
    } else {
      print('❌ Failed to load quote');
    }
  }

  Future<void> _fetchTodayData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final baseUrl = dotenv.env['BASE_URL']!;
    final DateTime today = DateTime.now();
    final DateTime start = DateTime(today.year, today.month, today.day);
    final DateTime end = start.add(const Duration(days: 1));

    final mealRes = await http.get(Uri.parse(
      '$baseUrl/api/meals/day?user_id=$userId&start=${start.toIso8601String()}&end=${end.toIso8601String()}',
    ));
    final actRes = await http.get(Uri.parse(
      '$baseUrl/api/activities/day?user_id=$userId&start=${start.toIso8601String()}&end=${end.toIso8601String()}',
    ));

    if (mealRes.statusCode == 200 && actRes.statusCode == 200) {
      final List mealJson = jsonDecode(mealRes.body);
      final List actJson = jsonDecode(actRes.body);
      final meals = mealJson.map((m) => Meal.fromJson(m)).toList();
      final activities = actJson.map((a) => Activity.fromJson(a)).toList();

      setState(() {
        _meals = meals;
        _activities = activities;
      });
    } else {
      print('❌ Failed to fetch today meals or activities');
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
    if (index == 0) {
      staticTopBarKey.currentState?.refreshNotifications();
      _fetchTodayData(); 
    }
    if (index == 2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddPage()),
      );

      if (result != null && result is Meal) {
        final today = DateTime.now();
        final dateKey = DateTime(
          result.timestamp.year,
          result.timestamp.month,
          result.timestamp.day,
        );

        setState(() {
          if (dateKey.year == today.year &&
              dateKey.month == today.month &&
              dateKey.day == today.day) {
            _meals.add(result); 
          }

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

          String formatTimestamp(DateTime dt) {
            String twoDigits(int n) => n.toString().padLeft(2, '0');
            return "${dt.year}-${twoDigits(dt.month)}-${twoDigits(dt.day)} "
                "${twoDigits(dt.hour)}:${twoDigits(dt.minute)}:${twoDigits(dt.second)}";
          }

          if (result != null && result is Meal) {
            final baseUrl = dotenv.env['BASE_URL']!;
            final response = await http.put(
              Uri.parse('$baseUrl/api/meals/${editedMeal.id}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'id': result.id,
                'user_id': result.userId,
                'name': result.menu,
                'type': result.type.toLowerCase(),
                'portion': result.portion,
                'energy': int.tryParse(result.kcal) ?? 0,
                'timestamp': formatTimestamp(result.timestamp),
              }),
            );

            if (response.statusCode == 200) {
              setState(() {
                final index = _meals.indexWhere((m) => m.id == editedMeal.id);
                if (index != -1) _meals[index] = result;
              });
            } else {
              print('❌ Failed to update meal: ${response.body}');
            }
          }
        },
        onDeleteMeal: (meal) async {
          final baseUrl = dotenv.env['BASE_URL']!;
          final response =
              await http.delete(Uri.parse('$baseUrl/api/meals/${meal.id}'));

          if (response.statusCode == 200) {
            setState(() {
              _meals.removeWhere((m) => m.id == meal.id);
            });
          } else {
            print('❌ Failed to delete meal: ${response.body}');
          }
        },
        onEditActivity: (oldAct) async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ActivityPage(existingActivity: oldAct)),
          );

          if (result != null && result is Activity) {
            final baseUrl = dotenv.env['BASE_URL']!;
            final response = await http.put(
              Uri.parse('$baseUrl/api/activities/${oldAct.id}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(result.toJson()),
            );

            if (response.statusCode == 200) {
              setState(() {
                final index = _activities.indexWhere((a) => a.id == oldAct.id);
                if (index != -1) _activities[index] = result;
              });
            } else {
              print('❌ Failed to update activity: ${response.body}');
            }
          }
        },
        onDeleteActivity: (act) async {
          final baseUrl = dotenv.env['BASE_URL']!;
          final response =
              await http.delete(Uri.parse('$baseUrl/api/activities/${act.id}'));

          if (response.statusCode == 200) {
            setState(() {
              _activities.removeWhere((a) => a.id == act.id);
            });
          } else {
            print('❌ Failed to delete activity: ${response.body}');
          }
        },
        quote: _quote,
        onRefresh: () async {
          await _fetchTodayData();
          await _fetchQuote();
          await _fetchGoalKcal();
          staticTopBarKey.currentState?.refreshNotifications();
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
              child: StaticTopBar(key: staticTopBarKey),
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

class AnimatedQuoteContainer extends StatefulWidget {
  final String? quote;

  const AnimatedQuoteContainer({super.key, required this.quote});

  @override
  State<AnimatedQuoteContainer> createState() => _AnimatedQuoteContainerState();
}

class _AnimatedQuoteContainerState extends State<AnimatedQuoteContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _alignmentAnimation = Tween<Alignment>(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _alignmentAnimation,
      builder: (context, child) {
        return Container(
          height: 120,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _alignmentAnimation.value,
              end: Alignment(-_alignmentAnimation.value.x, 0),
              colors: const [
                Color(0xFF81C784),
                Color(0xFF4CAF50),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.quote != null ? '"${widget.quote}"' : '“Loading quote...”',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
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
  final String? quote;
  final Future<void> Function() onRefresh;

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
    required this.quote,
    required this.onRefresh,
  });

  List<Meal> _filterMeals(String type) =>
      meals.where((m) => m.type.toLowerCase() == type.toLowerCase()).toList();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          AnimatedQuoteContainer(quote: quote),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: onTapGoalCard,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
      ),
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
                    Expanded(child: Text(() {
                      final portion = double.tryParse(m.portion) ?? 0;
                      final isDrink = m.type.toLowerCase() == 'drink';
                      final unit = isDrink
                          ? (portion == 1 ? ' Glass' : ' Glasses')
                          : (portion == 1 ? 'g' : 'g');
                      return '${m.menu} (${m.kcal} kcal, ${m.portion}$unit)';
                    }())),
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
                    Expanded(
                      child: Text(() {
                        final totalMinutes = int.tryParse(a.hours) ?? 0;
                        final hours = totalMinutes ~/ 60;
                        final minutes = totalMinutes % 60;
                        if (minutes == 0) {
                          return '${a.type} for ${hours} hr.';
                        }
                        return '${a.type} for ${hours} hr. ${minutes} min';
                      }()),
                    ),
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
