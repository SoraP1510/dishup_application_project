class Activity {
  final String type;
  final String hours;
  final String description;
  final String calories;

  Activity({
    required this.type,
    required this.hours,
    required this.description,
    required this.calories,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      type: json['activity_type'] ?? '',
      hours: json['duration_minutes'].toString(),
      description: json['description'] ?? '',
      calories: json['cal_burned']?.toString() ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_type': type.toLowerCase(),
      'duration_minutes': int.tryParse(hours) ?? 0,
      'description': description,
      'cal_burned': calories == 'unknown' ? null : int.tryParse(calories),
    };
  }
}
