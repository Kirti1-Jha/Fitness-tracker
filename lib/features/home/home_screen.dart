
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../habits/habits_screen.dart';
import '../focus/focus_screen.dart';
import '../wellness/wellness_screen.dart';
import '../insights/insights_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const HomeScreen({super.key, required this.profile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final titles = [
    'FitMind',
    'My Habits',
    'Focus Mode',
    'Insights',
    'Profile',
  ];

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardTab(
        profile: widget.profile,
        onNavigate: (index) {
          setState(() => selectedIndex = index);
        },
      ),
      HabitsScreen(),
      FocusScreen(),
      const InsightsScreen(),
      ProfileScreen(profile: widget.profile),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => selectedIndex = 4);
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Focus',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  final Map<String, dynamic> profile;
  final Function(int) onNavigate;

  const DashboardTab({
    super.key,
    required this.profile,
    required this.onNavigate,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  Future<Map<String, dynamic>>? logFuture;

  @override
  void initState() {
    super.initState();
    loadLog();
  }

  void loadLog() {
    logFuture = AppDatabase.instance.getTodayLog();
  }

  Future<void> update(String field, int amount) async {
    await AppDatabase.instance.updateDailyActivity(field, amount);
    setState(loadLog);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: logFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final log = snapshot.data!;
        final steps = log['steps'] as int;
        final water = log['water_ml'] as int;
        final workout = log['workout_minutes'] as int;

        final stepProgress = (steps / 8000).clamp(0.0, 1.0);
        final waterProgress = (water / 2000).clamp(0.0, 1.0);
        final workoutProgress = (workout / 30).clamp(0.0, 1.0);

        return RefreshIndicator(
          onRefresh: () async => setState(loadLog),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                'Hello, ${widget.profile['name']} 👋',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTeal,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Let’s make today a little healthier.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.darkTeal],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your daily goal',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.profile['fitness_goal'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Consistency matters more than perfection!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              const Text(
                'Today’s Activity',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              ActivityCard(
                title: 'Steps',
                value: '$steps',
                target: '8,000 steps',
                icon: Icons.directions_walk,
                progress: stepProgress,
                actionText: '+500 steps',
                onPressed: () => update('steps', 500),
              ),
              const SizedBox(height: 12),

              ActivityCard(
                title: 'Water Intake',
                value: '$water ml',
                target: '2,000 ml',
                icon: Icons.water_drop_outlined,
                progress: waterProgress,
                actionText: '+250 ml',
                onPressed: () => update('water_ml', 250),
              ),
              const SizedBox(height: 12),

              ActivityCard(
                title: 'Workout',
                value: '$workout min',
                target: '30 minutes',
                icon: Icons.fitness_center,
                progress: workoutProgress,
                actionText: '+10 min',
                onPressed: () => update('workout_minutes', 10),
              ),

              const SizedBox(height: 25),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: QuickAction(
                      icon: Icons.check_circle_outline,
                      label: 'My Habits',
                      onTap: () => widget.onNavigate(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickAction(
                      icon: Icons.timer_outlined,
                      label: 'Focus',
                      onTap: () => widget.onNavigate(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickAction(
                      icon: Icons.mood,
                      label: 'Mood',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WellnessScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                'Today’s Achievements',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (steps >= 500)
                    const Chip(
                      avatar: Icon(Icons.directions_walk, size: 18),
                      label: Text('First Steps'),
                    ),

                  if (steps >= 8000)
                    const Chip(
                      avatar: Icon(Icons.emoji_events, size: 18),
                      label: Text('Step Champion'),
                    ),

                  if (water >= 1000)
                    const Chip(
                      avatar: Icon(Icons.water_drop, size: 18),
                      label: Text('Hydration Hero'),
                    ),

                  if (workout >= 10)
                    const Chip(
                      avatar: Icon(Icons.fitness_center, size: 18),
                      label: Text('Active Mind'),
                    ),

                  if (workout >= 30)
                    const Chip(
                      avatar: Icon(Icons.star, size: 18),
                      label: Text('Workout Star'),
                    ),
                ],
              ),

              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.mint.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.emoji_events_outlined,
                        color: AppTheme.darkTeal, size: 35),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Every small step counts. Keep building your healthy routine!',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final String value;
  final String target;
  final IconData icon;
  final double progress;
  final String actionText;
  final VoidCallback onPressed;

  const ActivityCard({
    super.key,
    required this.title,
    required this.value,
    required this.target,
    required this.icon,
    required this.progress,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.mint.withValues(alpha: 0.5),
                  child: Icon(icon, color: AppTheme.darkTeal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(target,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.grey.shade200,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
