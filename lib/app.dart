
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/database/app_database.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';

class FitMindApp extends StatefulWidget {
  const FitMindApp({super.key});

  @override
  State<FitMindApp> createState() => _FitMindAppState();
}

class _FitMindAppState extends State<FitMindApp> {
  late Future<Map<String, dynamic>?> profileFuture;

  @override
  void initState() {
    super.initState();
    profileFuture = AppDatabase.instance.getProfile();
  }

  void refreshApp() {
    setState(() {
      profileFuture = AppDatabase.instance.getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<Map<String, dynamic>?>(
        future: profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == null) {
            return OnboardingScreen(onComplete: refreshApp);
          }

          return HomeScreen(profile: snapshot.data!);
        },
      ),
    );
  }
}
