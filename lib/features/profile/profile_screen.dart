
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const ProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool waterReminder = true;
  bool movementReminder = true;
  bool eyeReminder = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      waterReminder = prefs.getBool('water_reminder') ?? true;
      movementReminder = prefs.getBool('movement_reminder') ?? true;
      eyeReminder = prefs.getBool('eye_reminder') ?? true;
    });
  }

  Future<void> saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: AppTheme.mint,
                child: Icon(
                  Icons.person,
                  size: 45,
                  color: AppTheme.darkTeal,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.profile['name'],
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTeal,
                ),
              ),
              const Text(
                'FitMind Member',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'My Fitness Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        _InfoTile(
          icon: Icons.flag_outlined,
          title: 'Fitness Goal',
          value: widget.profile['fitness_goal'].toString(),
        ),
        _InfoTile(
          icon: Icons.directions_run,
          title: 'Activity Level',
          value: widget.profile['activity_level'].toString(),
        ),
        _InfoTile(
          icon: Icons.schedule,
          title: 'Available Time',
          value: '${widget.profile['available_minutes']} minutes/day',
        ),

        const SizedBox(height: 25),

        const Text(
          'Reminder Preferences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Water reminders'),
          subtitle: const Text('Remember to stay hydrated'),
          value: waterReminder,
          activeThumbColor: AppTheme.primary,
          onChanged: (value) {
            setState(() => waterReminder = value);
            saveSetting('water_reminder', value);
          },
        ),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Movement reminders'),
          subtitle: const Text('Take short movement breaks'),
          value: movementReminder,
          activeThumbColor: AppTheme.primary,
          onChanged: (value) {
            setState(() => movementReminder = value);
            saveSetting('movement_reminder', value);
          },
        ),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Eye relaxation reminders'),
          subtitle: const Text('Take a break from the screen'),
          value: eyeReminder,
          activeThumbColor: AppTheme.primary,
          onChanged: (value) {
            setState(() => eyeReminder = value);
            saveSetting('eye_reminder', value);
          },
        ),

        const SizedBox(height: 15),

        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.eco_outlined, color: AppTheme.primary, size: 30),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'FitMind helps you build healthier habits, '
                    'one day at a time.',
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Center(
          child: Text(
            'FitMind v1.0',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkTeal,
          ),
        ),
      ),
    );
  }
}
