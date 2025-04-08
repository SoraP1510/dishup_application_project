import 'dart:convert';
import 'package:dishup_application/account_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StaticTopBar extends StatefulWidget {
  const StaticTopBar({super.key});

  @override
  State<StaticTopBar> createState() => _StaticTopBarState();
}

class _StaticTopBarState extends State<StaticTopBar> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) return;

    final baseUrl = dotenv.env['BASE_URL']!;

    final uri = Uri.parse('$baseUrl/api/profile/$userId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        avatarUrl = data['avatar_url'];
      });
    } else {
      debugPrint('Failed to load avatar');
    }
  }

  void _toggleNotifications(BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 250,
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
                  _notificationItem("🍎 You added a healthy meal!"),
                  _notificationItem("🚶‍♂️ Walked 4.5km today."),
                  _notificationItem("💧 Don’t forget to hydrate!"),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    // child: TextButton(
                    //   onPressed: () {
                    //     _overlayEntry?.remove();
                    //     _overlayEntry = null;
                    //   },
                    //   child: const Text("Close"),
                    // ),
                  )
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
            // Avatar button
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

                  if (result == 'refresh') {
                    _loadAvatar();
                  }
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

            const Text(
              'DishUp',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

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
