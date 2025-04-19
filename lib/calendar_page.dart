import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/meal.dart';
import 'models/activity.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'add_page.dart';
import 'activity_page.dart';

class CalendarPage extends StatefulWidget {
  final Function(Meal) onEditMeal;
  final Function(Meal) onDeleteMeal;
  final Function(Activity) onEditActivity;
  final Function(Activity) onDeleteActivity;

  const CalendarPage({
    super.key,
    required this.onEditMeal,
    required this.onDeleteMeal,
    required this.onEditActivity,
    required this.onDeleteActivity,
  });

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  DateTime get _dayKey =>
      DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

  final Map<DateTime, List<Meal>> _mealsPerDay = {};
  final Map<DateTime, List<Activity>> _activitiesPerDay = {};

  List<Meal> get _mealsForDay => _mealsPerDay[_dayKey] ?? [];
  List<Activity> get _activitiesForDay => _activitiesPerDay[_dayKey] ?? [];

  int get _totalKcalForDay {
    return _mealsForDay.fold(0, (sum, m) => sum + (int.tryParse(m.kcal) ?? 0));
  }

  String get _totalPortionSummary {
    double totalGrams = 0;
    double totalGlasses = 0;

    for (var meal in _mealsForDay) {
      final portion = double.tryParse(meal.portion) ?? 0;
      if (meal.type.toLowerCase() == 'drink') {
        totalGlasses += portion;
      } else {
        totalGrams += portion;
      }
    }

    List<String> parts = [];
    if (totalGrams > 0) {
      parts.add('$totalGrams ${totalGrams == 1 ? 'Gram' : 'Grams'}');
    }
    if (totalGlasses > 0) {
      parts.add('$totalGlasses ${totalGlasses == 1 ? 'Glass' : 'Glasses'}');
    }

    return parts.isEmpty ? '' : parts.join(', ');
  }

  List<Meal> _filterMeals(String type) => _mealsForDay
      .where((m) => m.type.toLowerCase() == type.toLowerCase())
      .toList();

  void _editMeal(Meal oldMeal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddPage(existingMeal: oldMeal)),
    );

    if (result != null && result is Meal) {
      setState(() {
        final meals = _mealsPerDay[_dayKey];
        if (meals != null) {
          final index = meals.indexWhere((m) => m.id == oldMeal.id);
          if (index != -1) {
            meals[index] = result;
          }
        }
      });
    }
  }

  void _deleteMeal(Meal meal) async {
    final baseUrl = dotenv.env['BASE_URL'];
    final response =
        await http.delete(Uri.parse('$baseUrl/api/meals/${meal.id}'));

    if (response.statusCode == 200) {
      setState(() {
        _mealsPerDay[_dayKey]?.removeWhere((m) => m.id == meal.id);
      });
    }
  }

  void _editActivity(Activity oldAct) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ActivityPage(existingActivity: oldAct)),
    );

    if (result != null && result is Activity) {
      setState(() {
        final activities = _activitiesPerDay[_dayKey];
        if (activities != null) {
          final index = activities.indexWhere((a) => a.id == oldAct.id);
          if (index != -1) {
            activities[index] = result;
          }
        }
      });
    }
  }

  void _deleteActivity(Activity act) async {
    final baseUrl = dotenv.env['BASE_URL'];
    final response =
        await http.delete(Uri.parse('$baseUrl/api/activities/${act.id}'));

    if (response.statusCode == 200) {
      setState(() {
        _activitiesPerDay[_dayKey]?.removeWhere((a) => a.id == act.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            headerStyle:
                HeaderStyle(formatButtonVisible: false, titleCentered: true),
            lastDay: DateTime.utc(2030, 12, 31),
            daysOfWeekVisible: true,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(
                    selectedDay.year, selectedDay.month, selectedDay.day);
                _focusedDay = focusedDay;
              });
              _fetchDataForDay(selectedDay);
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Meal Summary',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Energy: $_totalKcalForDay kcal',
                            style: const TextStyle(fontSize: 14)),
                        if (_totalPortionSummary.isNotEmpty)
                          Text('Portions: $_totalPortionSummary',
                              style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Activity Summary',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (_activitiesForDay.any((a) => a.type == 'exercise'))
                          Text(
                            () {
                              final minutes = _activitiesForDay
                                  .where((a) => a.type == 'exercise')
                                  .fold(
                                      0,
                                      (sum, a) =>
                                          sum + (int.tryParse(a.hours) ?? 0));
                              final h = minutes ~/ 60;
                              final m = minutes % 60;
                              return 'Exercise: $h hr${m > 0 ? ' $m min' : ''}';
                            }(),
                          ),
                        if (_activitiesForDay.any((a) => a.type == 'sleep'))
                          Text(
                            () {
                              final minutes = _activitiesForDay
                                  .where((a) => a.type == 'sleep')
                                  .fold(
                                      0,
                                      (sum, a) =>
                                          sum + (int.tryParse(a.hours) ?? 0));
                              final h = minutes ~/ 60;
                              final m = minutes % 60;
                              return 'Sleep: $h hr${m > 0 ? ' $m min' : ''}';
                            }(),
                          ),
                      ],
                    ),
                  ),
                ),
                _MealCard('Breakfast', _filterMeals('Breakfast'), _editMeal,
                    _deleteMeal),
                _MealCard(
                    'Lunch', _filterMeals('Lunch'), _editMeal, _deleteMeal),
                _MealCard(
                    'Dinner', _filterMeals('Dinner'), _editMeal, _deleteMeal),
                _MealCard(
                    'Snack', _filterMeals('Snack'), _editMeal, _deleteMeal),
                _MealCard(
                    'Drink', _filterMeals('Drink'), _editMeal, _deleteMeal),
                _ActivityCard(
                    _activitiesForDay, _editActivity, _deleteActivity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchDataForDay(_selectedDay);
  }

  void _fetchDataForDay(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final baseUrl = dotenv.env['BASE_URL'];

    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final mealResponse = await http.get(Uri.parse(
      '$baseUrl/api/meals/day?user_id=$userId&start=${dayStart.toIso8601String()}&end=${dayEnd.toIso8601String()}',
    ));

    final activityResponse = await http.get(Uri.parse(
      '$baseUrl/api/activities/day?user_id=$userId&start=${dayStart.toIso8601String()}&end=${dayEnd.toIso8601String()}',
    ));

    if (mealResponse.statusCode == 200 && activityResponse.statusCode == 200) {
      final mealData = jsonDecode(mealResponse.body) as List;
      final activityData = jsonDecode(activityResponse.body) as List;

      final meals = mealData.map((m) => Meal.fromJson(m)).toList();
      final activities = activityData.map((a) => Activity.fromJson(a)).toList();

      setState(() {
        _mealsPerDay[_dayKey] = meals;
        _activitiesPerDay[_dayKey] = activities;
      });
    }
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final List<Meal> meals;
  final void Function(Meal) onEdit;
  final void Function(Meal) onDelete;

  const _MealCard(this.title, this.meals, this.onEdit, this.onDelete);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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

class _ActivityCard extends StatelessWidget {
  final List<Activity> activities;
  final void Function(Activity) onEdit;
  final void Function(Activity) onDelete;

  const _ActivityCard(this.activities, this.onEdit, this.onDelete);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
