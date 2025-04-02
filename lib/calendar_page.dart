import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/meal.dart';
import 'models/activity.dart';

class CalendarPage extends StatefulWidget {
  final Map<DateTime, List<Meal>> mealsPerDay;
  final Map<DateTime, List<Activity>> activitiesPerDay;
  final Function(Meal) onEditMeal;
  final Function(Meal) onDeleteMeal;
  final Function(Activity) onEditActivity;
  final Function(Activity) onDeleteActivity;

  const CalendarPage({
    super.key,
    required this.mealsPerDay,
    required this.activitiesPerDay,
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

  DateTime get _dayKey => DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

  List<Meal> get _mealsForDay => widget.mealsPerDay[_dayKey] ?? [];
  List<Activity> get _activitiesForDay => widget.activitiesPerDay[_dayKey] ?? [];

  int get _totalKcalForDay {
    return _mealsForDay.fold(0, (sum, m) => sum + (int.tryParse(m.kcal) ?? 0));
  }

  List<Meal> _filterMeals(String type) =>
      _mealsForDay.where((m) => m.type.toLowerCase() == type.toLowerCase()).toList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                _focusedDay = focusedDay;
              });
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
                    child: Text(
                      'Total: $_totalKcalForDay Kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                _MealCard('Breakfast', _filterMeals('Breakfast'), widget.onEditMeal, widget.onDeleteMeal),
                _MealCard('Lunch', _filterMeals('Lunch'), widget.onEditMeal, widget.onDeleteMeal),
                _MealCard('Dinner', _filterMeals('Dinner'), widget.onEditMeal, widget.onDeleteMeal),
                _MealCard('Snack', _filterMeals('Snack'), widget.onEditMeal, widget.onDeleteMeal),
                _MealCard('Drink', _filterMeals('Drink'), widget.onEditMeal, widget.onDeleteMeal),
                _ActivityCard(_activitiesForDay, widget.onEditActivity, widget.onDeleteActivity),
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
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