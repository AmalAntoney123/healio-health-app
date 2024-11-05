import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final _healthBox = Hive.box('healthBox');
  final stepsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentSteps = _healthBox.get('steps');
    if (currentSteps != null) {
      stepsController.text = currentSteps;
    }
  }

  void _saveSteps() {
    if (stepsController.text.isNotEmpty) {
      final now = DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(now);

      _healthBox.put('steps', stepsController.text);
      _healthBox.put('steps_$dateKey', int.parse(stepsController.text));

      stepsController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Steps updated!')),
      );
    }
  }

  Widget _buildStepsChart() {
    return SizedBox(
      height: 200,
      child: ValueListenableBuilder(
        valueListenable: _healthBox.listenable(),
        builder: (context, box, _) {
          final stepsData = _getLast7DaysData();

          return BarChart(
            BarChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < stepsData.length) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            DateFormat('MM/dd').format(DateTime.now().subtract(
                                Duration(
                                    days:
                                        stepsData.length - 1 - value.toInt()))),
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
              borderData: FlBorderData(show: true),
              barGroups: stepsData.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.toDouble(),
                      color: Theme.of(context).colorScheme.primary,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  List<int> _getLast7DaysData() {
    final List<int> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Try to get the date-specific value first
      var value = _healthBox.get('steps_$dateKey');

      // For today, if no date-specific value exists, try to get the current value
      if (i == 0 && value == null) {
        final currentSteps = _healthBox.get('steps');
        if (currentSteps != null) {
          value = int.tryParse(currentSteps);
        }
      }

      data.add(value ?? 0);
    }

    return data;
  }

  Color _getProgressColor(int steps, int goal) {
    if (goal == 0) return Colors.grey;
    final percentage = steps / goal;
    if (percentage >= 1) {
      return Colors.green;
    } else if (percentage >= 0.7) {
      return Colors.blue;
    } else if (percentage >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getProgressMessage(int steps, int goal) {
    if (goal == 0) return 'No goal set';
    final percentage = steps / goal;
    if (percentage >= 1) {
      return 'Goal achieved!';
    } else if (percentage >= 0.7) {
      return 'Almost there!';
    } else if (percentage >= 0.4) {
      return 'Making progress';
    } else {
      return 'Keep moving';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Steps Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showGoalDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Steps',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: stepsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Steps',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: _healthBox.listenable(),
                      builder: (context, box, _) {
                        final hasData = box.get('steps', defaultValue: null) != null;
                        return ElevatedButton(
                          onPressed: _saveSteps,
                          child: Text(hasData ? 'Update Steps' : 'Save Steps'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Steps History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildStepsChart(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: _healthBox.listenable(),
                      builder: (context, box, _) {
                        final stepsData = _getLast7DaysData();
                        final goal = box.get('steps_goal', defaultValue: 10000);

                        if (stepsData.every((steps) => steps == 0)) {
                          return const Center(
                            child: Text('No steps data recorded yet'),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stepsData.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final date = DateTime.now().subtract(
                              Duration(days: stepsData.length - 1 - index),
                            );
                            final steps = stepsData[index];
                            
                            return ListTile(
                              leading: Icon(
                                Icons.directions_walk,
                                color: _getProgressColor(steps, goal),
                                size: 28,
                              ),
                              title: Text(
                                DateFormat('EEEE, MMM dd').format(date),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                _getProgressMessage(steps, goal),
                                style: TextStyle(
                                  color: _getProgressColor(steps, goal),
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: steps == 0 
                                    ? Colors.grey 
                                    : _getProgressColor(steps, goal),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  steps == 0 ? 'No data' : '$steps steps',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: _healthBox.listenable(),
              builder: (context, box, _) {
                final currentSteps = box.get('steps', defaultValue: 'No data');
                final goal = box.get('steps_goal', defaultValue: 10000);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Today\'s Progress',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$currentSteps / $goal steps',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (currentSteps != 'No data')
                          Text(
                            _getProgressMessage(
                              int.tryParse(currentSteps) ?? 0, 
                              goal,
                            ),
                            style: TextStyle(
                              color: _getProgressColor(
                                int.tryParse(currentSteps) ?? 0, 
                                goal,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context) {
    final box = Hive.box('healthBox');
    final currentGoal = box.get('steps_goal', defaultValue: 10000);
    final controller = TextEditingController(text: currentGoal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Steps Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Goal (steps)',
            suffixText: 'steps',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text);
              if (newGoal != null) {
                box.put('steps_goal', newGoal);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
