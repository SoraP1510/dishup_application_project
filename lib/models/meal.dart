class Meal {
  final String id;
  final String userId;
  final String menu;
  final String kcal;
  final String type;
  final String portion;
  final DateTime timestamp; 

  Meal({
    required this.id,
    required this.userId,
    required this.menu,
    required this.kcal,
    required this.type,
    required this.portion,
    required this.timestamp,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      userId: json['user_id'],
      menu: json['name'],
      kcal: json['energy'].toString(),
      type: json['type'],
      portion: json['portion'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': menu,
        'energy': int.tryParse(kcal) ?? 0,
        'type': type,
        'portion': portion,
        'timestamp': timestamp.toIso8601String(),
      };
}
