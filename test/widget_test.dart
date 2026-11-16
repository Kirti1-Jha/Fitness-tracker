import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_habit_tracker/core/theme/app_theme.dart';

void main() {
  test('FitMind theme uses the correct primary colour', () {
    expect(AppTheme.primary.toARGB32(), 0xFF159B87);
  });

  test('FitMind theme uses Material 3', () {
    expect(AppTheme.lightTheme.useMaterial3, isTrue);
  });
}