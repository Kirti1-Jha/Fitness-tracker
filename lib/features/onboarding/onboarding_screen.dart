
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final nameController = TextEditingController();

  String goal = 'Stay Fit';
  String activity = 'Moderate';
  int availableMinutes = 30;

  bool loading = false;

  Future<void> finishSetup() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => loading = true);

    await AppDatabase.instance.saveProfile(
      name: nameController.text.trim(),
      goal: goal,
      activityLevel: activity,
      availableMinutes: availableMinutes,
    );

    widget.onComplete();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              const Icon(
                Icons.eco_rounded,
                size: 65,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to FitMind!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTeal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Small daily actions create a healthier you. '
                'Let us personalise your experience.',
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 30),

              const Text('What should we call you?',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 25),
              const Text('What is your main goal?',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: goal,
                decoration: const InputDecoration(),
                items: [
                  'Stay Fit',
                  'Lose Weight',
                  'Build Strength',
                  'Improve Flexibility',
                  'Build Healthy Habits',
                ].map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => goal = value);
                },
              ),

              const SizedBox(height: 25),
              const Text('Your current activity level',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: activity,
                decoration: const InputDecoration(),
                items: ['Beginner', 'Moderate', 'Active'].map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => activity = value);
                },
              ),

              const SizedBox(height: 25),
              const Text('How much time can you spare daily?',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Slider(
                value: availableMinutes.toDouble(),
                min: 10,
                max: 120,
                divisions: 11,
                activeColor: AppTheme.primary,
                label: '$availableMinutes minutes',
                onChanged: (value) {
                  setState(() => availableMinutes = value.round());
                },
              ),
              Text(
                '$availableMinutes minutes per day',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: loading ? null : finishSetup,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
