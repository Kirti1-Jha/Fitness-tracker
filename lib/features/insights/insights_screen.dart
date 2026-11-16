
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AppDatabase.instance.getWeeklyLogs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = snapshot.data!;

        final stepsByDate = {
          for (final log in logs)
            log['log_date'] as String: log['steps'] as int
        };

        final lastSevenDays = List.generate(7, (index) {
          return DateTime.now().subtract(Duration(days: 6 - index));
        });

        final values = lastSevenDays.map((date) {
          final key = '${date.year}-'
              '${date.month.toString().padLeft(2, '0')}-'
              '${date.day.toString().padLeft(2, '0')}';

          return stepsByDate[key] ?? 0;
        }).toList();

        final maximumSteps = values.reduce(max);
        final chartMax = max(1000, maximumSteps + 1000).toDouble();

        final totalSteps = values.fold<int>(0, (sum, value) => sum + value);

        final activeDays = values.where((value) => value > 0).length;

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Your weekly progress',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkTeal,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Review your activity and celebrate your consistency.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Steps',
                    value: totalSteps.toString(),
                    icon: Icons.directions_walk,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Active Days',
                    value: '$activeDays / 7',
                    icon: Icons.calendar_today,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Steps this week',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 18, 12),
                child: SizedBox(
                  height: 240,
                  child: BarChart(
                    BarChartData(
                      maxY: chartMax,
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: values[index].toDouble(),
                              width: 18,
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 42,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();

                              if (index < 0 || index >= 7) {
                                return const SizedBox.shrink();
                              }

                              const days = [
                                'M', 'T', 'W', 'T', 'F', 'S', 'S'
                              ];

                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  days[lastSevenDays[index].weekday - 1],
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Focus time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            FutureBuilder<int>(
              future: AppDatabase.instance.getTotalFocusMinutes(),
              builder: (context, focusSnapshot) {
                final minutes = focusSnapshot.data ?? 0;

                return _SummaryCard(
                  title: 'Total recorded focus time',
                  value: '$minutes minutes',
                  icon: Icons.timer_outlined,
                );
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Keep going! Your progress is built through small, consistent actions.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkTeal,
              ),
            ),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
