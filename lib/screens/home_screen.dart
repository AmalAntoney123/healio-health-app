import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'weight_screen.dart';
import 'steps_screen.dart';

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
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('Mon');
                                case 1:
                                  return const Text('Tue');
                                case 2:
                                  return const Text('Wed');
                                case 3:
                                  return const Text('Thu');
                                case 4:
                                  return const Text('Fri');
                                case 5:
                                  return const Text('Sat');
                                case 6:
                                  return const Text('Sun');
                                default:
                                  return const Text('');
                              }
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
                          spots: List.generate(7, (index) {
                            return FlSpot(
                              index.toDouble(),
                              (double.tryParse(box.get('steps_$index',
                                          defaultValue: '0')) ??
                                      0) /
                                  1000, // Convert steps to thousands
                            );
                          }),
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                        // Weight data
                        LineChartBarData(
                          spots: List.generate(7, (index) {
                            return FlSpot(
                              index.toDouble(),
                              double.tryParse(box.get('weight_$index',
                                      defaultValue: '0')) ??
                                  0,
                            );
                          }),
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
