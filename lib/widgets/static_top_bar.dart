import 'dart:convert';
import 'package:dishup_application/account_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

class StaticTopBar extends StatefulWidget {
  const StaticTopBar({super.key});

  @override
  State<StaticTopBar> createState() => StaticTopBarState();
}

class StaticTopBarState extends State<StaticTopBar> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  String? avatarUrl;
  List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _initializeNotifications();
    _startHydrationReminder();
    _initializeNotifications();
  }

  Future<bool> _isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  void refreshNotifications() {
    _initializeNotifications();
  }

  void _startHydrationReminder() {
    Timer.periodic(const Duration(hours: 1), (timer) {
      _addNotification("💧 Time to drink some water!");
    });
  }

  Future<void> _initializeNotifications() async {
    if (!mounted) return;
    setState(() {
      _notifications.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final baseUrl = dotenv.env['BASE_URL']!;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final mealRes = await http.get(Uri.parse(
        '$baseUrl/api/meals/day?user_id=$userId&start=${todayStart.toIso8601String()}&end=${todayEnd.toIso8601String()}'));
    if (mealRes.statusCode == 200) {
      final List meals = jsonDecode(mealRes.body);
      final int totalKcal = meals.fold(0, (sum, m) {
        final energy = m['energy'];
        return sum +
            (energy is int ? energy : int.tryParse(energy.toString()) ?? 0);
      });
      final profileRes =
          await http.get(Uri.parse('$baseUrl/api/profile/$userId'));
      if (profileRes.statusCode == 200) {
        final profile = jsonDecode(profileRes.body);
        final goal = profile['kcal_target'] ?? 2000;
        if (totalKcal >= goal) {
          _addNotification("🎯 You’ve reached your calorie goal!");
        }
      }
    }

    final actRes = await http.get(Uri.parse(
        '$baseUrl/api/activities/day?user_id=$userId&start=${todayStart.toIso8601String()}&end=${todayEnd.toIso8601String()}'));
    if (actRes.statusCode == 200) {
      final List activities = jsonDecode(actRes.body);
      final bool slept = activities.any((a) => a['activity_type'] == 'sleep');
      final bool exercised =
          activities.any((a) => a['activity_type'] == 'exercise');

      if (!slept) _addNotification("🛏 Don’t forget to log your sleep today!");
      if (!exercised) _addNotification("🏃 Don’t forget to exercise today!");
    }
  }

  void _addNotification(String message) {
    if (!_notifications.contains(message)) {
      if (!mounted) return;
      setState(() {
        _notifications.add(message);
      });
    }
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    final baseUrl = dotenv.env['BASE_URL']!;
    final response = await http.get(Uri.parse('$baseUrl/api/profile/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        avatarUrl = data['avatar_url'];
      });
    }
  }

  void _toggleNotifications(BuildContext context) async {
    final isEnabled = await _isNotificationEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notifications are disabled")),
      );
      return;
    }

    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 260,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(110, 50),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  if (_notifications.isEmpty)
                    const Text("No recent notifications",
                        style: TextStyle(fontSize: 13)),
                  ..._notifications.map(_notificationItem).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async {
                final currentRoute = ModalRoute.of(context)?.settings.name;

                if (currentRoute == '/account') {
                  Navigator.pop(context);
                } else {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AccountPage(),
                      settings: const RouteSettings(name: '/account'),
                    ),
                  );
                  if (result == 'refresh') _loadAvatar();
                }
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? NetworkImage(avatarUrl!)
                    : const AssetImage('assets/images/user.jpg')
                        as ImageProvider,
              ),
            ),
            const Text('DishUp',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => _toggleNotifications(context),
              child: const Icon(Icons.notifications, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }
}
