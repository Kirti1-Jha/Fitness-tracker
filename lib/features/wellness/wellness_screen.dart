
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  String selectedMood = 'Good';
  double energy = 3;
  final noteController = TextEditingController();

  final moods = {
    'Happy': '😊',
    'Good': '🙂',
    'Okay': '😐',
    'Tired': '😴',
    'Stressed': '😟',
  };

  Future<void> saveCheckIn() async {
    await AppDatabase.instance.saveMood(
      mood: selectedMood,
      energy: energy.round(),
      note: noteController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your check-in has been saved!')),
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Check-in')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkTeal,
            ),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: moods.entries.map((entry) {
              final selected = selectedMood == entry.key;

              return ChoiceChip(
                label: Text('${entry.value} ${entry.key}'),
                selected: selected,
                selectedColor: AppTheme.mint,
                onSelected: (_) {
                  setState(() => selectedMood = entry.key);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 35),
          const Text(
            'How is your energy level?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: energy,
            min: 1,
            max: 5,
            divisions: 4,
            label: energy.round().toString(),
            activeColor: AppTheme.primary,
            onChanged: (value) => setState(() => energy = value),
          ),
          Text(
            'Energy level: ${energy.round()} / 5',
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            'Anything you want to note?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Write a short note about your day...',
            ),
          ),

          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: saveCheckIn,
            child: const Text('Save Check-in'),
          ),
        ],
      ),
    );
  }
}
