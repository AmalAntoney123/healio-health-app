import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'weight_screen.dart';
import 'steps_screen.dart';
import 'package:intl/intl.dart';
import 'sleep_screen.dart';
import 'water_screen.dart';
import 'nutrition_screen.dart';
import 'mood_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Healio'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Trackers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DashboardTab(),
            TrackersTab(),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('healthBox').listenable(),
      builder: (context, box, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GoalCard(
              title: 'Daily Steps',
              current: int.tryParse(box.get('steps', defaultValue: '0')) ?? 0,
              goal: box.get('steps_goal', defaultValue: 10000),
              unit: 'steps',
            ),
            const SizedBox(height: 16),
            _GoalCard(
              title: 'Weight',
              current:
                  double.tryParse(box.get('weight', defaultValue: '0')) ?? 0,
              goal: box.get('weight_goal', defaultValue: 70),
              unit: 'kg',
            ),
            const SizedBox(height: 16),
            _WeeklyProgressChart(),
          ],
        );
      },
    );
  }
}

class TrackersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _HealthCard(
          title: 'Weight',
          icon: Icons.monitor_weight,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WeightScreen()),
          ),
        ),
        _HealthCard(
          title: 'Steps',
          icon: Icons.directions_walk,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StepsScreen()),
          ),
        ),
        _HealthCard(
          title: 'Sleep',
          icon: Icons.bedtime,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SleepScreen()),
          ),
        ),
        _HealthCard(
          title: 'Water',
          icon: Icons.water_drop,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WaterScreen()),
          ),
        ),
        _HealthCard(
          title: 'Nutrition',
          icon: Icons.restaurant,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NutritionScreen()),
          ),
        ),
        _HealthCard(
          title: 'Mood',
          icon: Icons.mood,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MoodScreen()),
          ),
        ),
      ],
    );
  }
}

class _HealthCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _HealthCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final num current;
  final num goal;
  final String unit;

  const _GoalCard({
    required this.title,
    required this.current,
    required this.goal,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal != 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current: $current $unit'),
                Text('Goal: $goal $unit'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyProgressChart extends StatelessWidget {
  List<FlSpot> _getWeightData(Box box) {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Try to get the date-specific value first
      var value = box.get('weight_$dateKey');

      // For today, if no date-specific value exists, try to get the current value
      if (i == 0 && value == null) {
        final currentWeight = box.get('weight');
        if (currentWeight != null) {
          value = double.tryParse(currentWeight);
        }
      }

      spots.add(FlSpot((6 - i).toDouble(), value?.toDouble() ?? 0));
    }

    return spots;
  }

  List<FlSpot> _getStepsData(Box box) {
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Try to get the date-specific value first
      var value = box.get('steps_$dateKey');

      // For today, if no date-specific value exists, try to get the current value
      if (i == 0 && value == null) {
        final currentSteps = box.get('steps');
        if (currentSteps != null) {
          value = int.tryParse(currentSteps);
        }
      }

      spots.add(FlSpot((6 - i).toDouble(),
          (value?.toDouble() ?? 0) / 1000)); // Convert steps to thousands
    }

    return spots;
  }

  String _getDayLabel(int index) {
    final date = DateTime.now().subtract(Duration(days: 6 - index));
    return DateFormat('E')
        .format(date); // Returns abbreviated day name (Mon, Tue, etc.)
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ValueListenableBuilder(
                valueListenable: Hive.box('healthBox').listenable(),
                builder: (context, box, _) {
                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < 7) {
                                return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    _getDayLabel(index),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Steps data
                        LineChartBarData(
                          spots: _getStepsData(box),
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                        // Weight data
                        LineChartBarData(
                          spots: _getWeightData(box),
                          isCurved: true,
                          color: Theme.of(context).colorScheme.secondary,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ChartLegend(
                  color: Theme.of(context).colorScheme.primary,
                  label: 'Steps (thousands)',
                ),
                const SizedBox(width: 16),
                _ChartLegend(
                  color: Theme.of(context).colorScheme.secondary,
                  label: 'Weight (kg)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
