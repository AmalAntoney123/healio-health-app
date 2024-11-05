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
import 'health_assessment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardTab(),
    TrackersTab(),
  ];

  void _onFabPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Health Assessment'),
            ],
          ),
          content: const Text(
            'Would you like to take a quick health assessment? This will help us provide better insights about your health.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not Now'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HealthAssessmentScreen(),
                  ),
                );
              },
              child: const Text('Start Assessment'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Dashboard' : 'Trackers'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed,
        icon: const Icon(Icons.health_and_safety),
        label: const Text('Health Check'),
        tooltip: 'Take Health Assessment',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined),
            selectedIcon: Icon(Icons.track_changes),
            label: 'Trackers',
          ),
        ],
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
        final now = DateTime.now();
        final dateKey = DateFormat('yyyy-MM-dd').format(now);

        // Get all stats for today
        final steps = int.tryParse(box.get('steps', defaultValue: '0')) ?? 0;
        final stepsGoal = box.get('steps_goal', defaultValue: 10000);

        final weight =
            double.tryParse(box.get('weight', defaultValue: '0')) ?? 0;
        final weightGoal = box.get('weight_goal', defaultValue: 70.0);

        final water =
            int.tryParse(box.get('water_intake', defaultValue: '0')) ?? 0;
        final waterGoal =
            int.tryParse(box.get('water_goal', defaultValue: '2000')) ?? 2000;

        final calories =
            int.tryParse(box.get('calories', defaultValue: '0')) ?? 0;
        final caloriesGoal =
            int.tryParse(box.get('calorie_goal', defaultValue: '2000')) ?? 2000;

        final sleep =
            double.tryParse(box.get('sleep_hours', defaultValue: '0')) ?? 0;
        final sleepGoal = box.get('sleep_goal', defaultValue: 8.0);

        final mood = box.get('mood', defaultValue: 'No data');

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Today\'s Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVerticalProgressCard(
                    context,
                    'Steps',
                    steps,
                    stepsGoal,
                    Icons.directions_walk,
                    suffix: ' steps',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVerticalProgressCard(
                    context,
                    'Water',
                    water,
                    waterGoal,
                    Icons.water_drop,
                    suffix: ' ml',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVerticalProgressCard(
                    context,
                    'Calories',
                    calories,
                    caloriesGoal,
                    Icons.local_fire_department,
                    suffix: ' kcal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weight',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Icon(Icons.monitor_weight),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: weightGoal != 0
                                    ? (weight / weightGoal).clamp(0.0, 1.0)
                                    : 0,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Text('Current: ${weight.toStringAsFixed(1)} kg'),
                              Text('Goal: ${weightGoal.toStringAsFixed(1)} kg'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sleep',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Icon(Icons.bedtime),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: sleepGoal != 0
                                    ? (sleep / sleepGoal).clamp(0.0, 1.0)
                                    : 0,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Text('Slept: ${sleep.toStringAsFixed(1)} hours'),
                              Text(
                                  'Goal: ${sleepGoal.toStringAsFixed(1)} hours'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mood',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        _buildMoodIcon(mood),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(mood == 'No data'
                        ? 'No mood recorded today'
                        : 'Feeling $mood'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _WeeklyProgressChart(),
          ],
        );
      },
    );
  }

  Widget _buildVerticalProgressCard(
    BuildContext context,
    String title,
    num current,
    num goal,
    IconData icon, {
    String suffix = '',
  }) {
    final progress = goal != 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              width: 24,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  FractionallySizedBox(
                    heightFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('$percentage%'),
            const SizedBox(height: 4),
            Text(
              '$current$suffix',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'of $goal$suffix',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodIcon(String mood) {
    IconData icon;
    Color color;

    switch (mood) {
      case 'Happy':
        icon = Icons.sentiment_very_satisfied;
        color = Colors.green;
        break;
      case 'Excited':
        icon = Icons.celebration;
        color = Colors.orange;
        break;
      case 'Calm':
        icon = Icons.spa;
        color = Colors.blue;
        break;
      case 'Tired':
        icon = Icons.bedtime;
        color = Colors.purple;
        break;
      case 'Stressed':
        icon = Icons.warning_amber;
        color = Colors.red;
        break;
      case 'Sad':
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.grey.shade700;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Icon(icon, color: color);
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
