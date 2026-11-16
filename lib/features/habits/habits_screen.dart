
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  Future<List<Map<String, dynamic>>>? habitsFuture;

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  void loadHabits() {
    habitsFuture = AppDatabase.instance.getHabits();
  }

  Future<void> addHabit() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create a habit'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Example: Read for 20 minutes',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name != null) {
      await AppDatabase.instance.addHabit(name);
      setState(loadHabits);
    }
  }

  Future<void> toggle(int id, bool completed) async {
    await AppDatabase.instance.toggleHabit(id, completed);
    setState(loadHabits);
  }

  Future<void> delete(int id) async {
    await AppDatabase.instance.deleteHabit(id);
    setState(loadHabits);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: habitsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final habits = snapshot.data!;
        final completed = habits
            .where((habit) => habit['is_completed'] == 1)
            .length;

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Build better routines',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTeal,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: addHabit,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(95, 42),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.mint.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Today’s progress'),
                  const SizedBox(height: 8),
                  Text(
                    '$completed / ${habits.length} habits completed',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTeal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: habits.isEmpty ? 0 : completed / habits.length,
                    minHeight: 8,
                    color: AppTheme.primary,
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            if (habits.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Icon(Icons.spa_outlined,
                        size: 55, color: AppTheme.primary),
                    SizedBox(height: 12),
                    Text(
                      'No habits added yet.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Tap Add to create your first habit.'),
                  ],
                ),
              ),

            ...habits.map((habit) {
              final isCompleted = habit['is_completed'] == 1;
              final id = habit['id'] as int;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: CheckboxListTile(
                  value: isCompleted,
                  activeColor: AppTheme.primary,
                  title: Text(
                    habit['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    isCompleted ? 'Completed today' : 'Not completed yet',
                  ),
                  secondary: IconButton(
                    onPressed: () => delete(id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  onChanged: (value) => toggle(id, value ?? false),
                ),
              );
            }),

            const SizedBox(height: 15),
            const Text(
              'Tip: Start with small habits that are easy to repeat.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}
