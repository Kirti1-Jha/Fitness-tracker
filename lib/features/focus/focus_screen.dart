
import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  static const int focusDuration = 25 * 60;
  static const int breakDuration = 5 * 60;

  int remainingSeconds = focusDuration;
  bool isRunning = false;
  bool isBreak = false;
  Timer? timer;

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startTimer() {
    if (isRunning) return;

    setState(() => isRunning = true);

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        timer.cancel();

        if (!isBreak) {
          await AppDatabase.instance.saveFocusSession(
            focusMinutes: 25,
            breakMinutes: 0,
          );

          if (!mounted) return;

          setState(() {
            isRunning = false;
            isBreak = true;
            remainingSeconds = breakDuration;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Focus session completed! Take a break.'),
            ),
          );
        } else {
          if (!mounted) return;

          setState(() {
            isRunning = false;
            isBreak = false;
            remainingSeconds = focusDuration;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Break completed. Ready to focus?')),
          );
        }
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer() {
    timer?.cancel();

    setState(() {
      isRunning = false;
      isBreak = false;
      remainingSeconds = focusDuration;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = isBreak
        ? 1 - remainingSeconds / breakDuration
        : 1 - remainingSeconds / focusDuration;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Make time for what matters.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkTeal,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isBreak ? 'Break time' : 'Focus session',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 40),

        Center(
          child: SizedBox(
            height: 240,
            width: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 220,
                  width: 220,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 12,
                    backgroundColor: AppTheme.mint,
                    color: AppTheme.primary,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBreak ? Icons.self_improvement : Icons.timer,
                      color: AppTheme.primary,
                      size: 35,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 35),

        ElevatedButton(
          onPressed: isRunning ? pauseTimer : startTimer,
          child: Text(isRunning ? 'Pause' : 'Start'),
        ),
        const SizedBox(height: 12),

        OutlinedButton(
          onPressed: resetTimer,
          child: const Text('Reset Timer'),
        ),

        const SizedBox(height: 25),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  'How it works',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('25 minutes of focused work followed by a 5-minute break.'),
                SizedBox(height: 6),
                Text('Repeat the cycle whenever you need a productive session.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
