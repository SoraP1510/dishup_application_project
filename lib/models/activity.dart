class Activity {
  final String id; 
  final String type;
  final String hours;
  final String description;
  final String calories;
  final String? sleepTime;
  final String? wakeTime;
  final String? timestamp; 

  Activity({
    required this.id, 
    required this.type,
    required this.hours,
    required this.description,
    required this.calories,
    this.sleepTime,
    this.wakeTime,
    this.timestamp, 
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '', 
      type: json['activity_type'] ?? '',
      hours: json['duration_minutes'].toString(),
      description: json['description'] ?? '',
      calories: json['cal_burned']?.toString() ?? 'unknown',
      sleepTime: json['sleep_time'],
      wakeTime: json['wake_time'],
      timestamp: json['timestamp'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'activity_type': type.toLowerCase(),
      'duration_minutes': int.tryParse(hours) ?? 0,
      'description': description,
      'cal_burned': calories == 'unknown' ? null : int.tryParse(calories),
      'sleep_time': sleepTime,
      'wake_time': wakeTime,
      'timestamp': timestamp, 
    };
  }
}
