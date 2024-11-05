import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final _healthBox = Hive.box('healthBox');
  final weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentWeight = _healthBox.get('weight');
    if (currentWeight != null) {
      weightController.text = currentWeight;
    }
  }

  void _saveWeight() {
    if (weightController.text.isNotEmpty) {
      final now = DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(now);

      _healthBox.put('weight', weightController.text);
      _healthBox.put('weight_$dateKey', double.parse(weightController.text));

      weightController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight saved!')),
      );
    }
  }

  Widget _buildWeightChart() {
    return SizedBox(
      height: 200,
      child: ValueListenableBuilder(
        valueListenable: _healthBox.listenable(),
        builder: (context, box, _) {
          final weightData = _getLast7DaysData();

          return LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < weightData.length) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            DateFormat('MM/dd').format(DateTime.now().subtract(
                                Duration(
                                    days: weightData.length -
                                        1 -
                                        value.toInt()))),
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
              lineBarsData: [
                LineChartBarData(
                  spots: weightData.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value);
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<double> _getLast7DaysData() {
    final List<double> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Try to get the date-specific value first
      var value = _healthBox.get('weight_$dateKey');

      // For today, if no date-specific value exists, try to get the current value
      if (i == 0 && value == null) {
        final currentWeight = _healthBox.get('weight');
        if (currentWeight != null) {
          value = double.tryParse(currentWeight);
        }
      }

      data.add(value?.toDouble() ?? 0);
    }

    return data;
  }

  Color _getWeightProgressColor(double weight, double goal) {
    if (goal == 0) return Colors.grey;
    final difference = (weight - goal).abs();
    final percentDifference = difference / goal * 100;

    if (percentDifference <= 1) {
      return Colors.green; // Within 1% of goal
    } else if (percentDifference <= 5) {
      return Colors.blue; // Within 5% of goal
    } else if (percentDifference <= 10) {
      return Colors.orange; // Within 10% of goal
    } else {
      return Colors.red; // More than 10% from goal
    }
  }

  String _getWeightProgressMessage(double weight, double goal) {
    if (goal == 0) return 'No goal set';
    final difference = weight - goal;
    final percentDifference = (difference / goal * 100).abs();

    if (percentDifference <= 1) {
      return 'At goal weight!';
    } else if (percentDifference <= 5) {
      return difference > 0
          ? 'Close to goal (${difference.toStringAsFixed(1)} kg over)'
          : 'Close to goal (${(-difference).toStringAsFixed(1)} kg under)';
    } else if (percentDifference <= 10) {
      return difference > 0
          ? 'Making progress (${difference.toStringAsFixed(1)} kg over)'
          : 'Making progress (${(-difference).toStringAsFixed(1)} kg under)';
    } else {
      return difference > 0
          ? '${difference.toStringAsFixed(1)} kg over goal'
          : '${(-difference).toStringAsFixed(1)} kg under goal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracker'),
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
                      'Current Weight',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveWeight,
                      child: const Text('Save Weight'),
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
                      'Weight History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildWeightChart(),
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
                      'Daily Records',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: _healthBox.listenable(),
                      builder: (context, box, _) {
                        final weightData = _getLast7DaysData();
                        final goal = box.get('weight_goal', defaultValue: 70.0);

                        if (weightData.every((weight) => weight == 0)) {
                          return const Center(
                            child: Text('No weight data recorded yet'),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: weightData.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final date = DateTime.now().subtract(
                              Duration(days: weightData.length - 1 - index),
                            );
                            final weight = weightData[index];

                            if (weight == 0) {
                              return ListTile(
                                title: Text(
                                  DateFormat('EEEE, MMM dd').format(date),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: const Text('No data'),
                              );
                            }

                            return ListTile(
                              leading: Icon(
                                Icons.monitor_weight,
                                color: _getWeightProgressColor(weight, goal),
                                size: 28,
                              ),
                              title: Text(
                                DateFormat('EEEE, MMM dd').format(date),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                _getWeightProgressMessage(weight, goal),
                                style: TextStyle(
                                  color: _getWeightProgressColor(weight, goal),
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getWeightProgressColor(weight, goal),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${weight.toStringAsFixed(1)} kg',
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
                final currentWeight =
                    box.get('weight', defaultValue: 'No data');
                final goal = box.get('weight_goal', defaultValue: 70.0);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Progress Summary',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Current: $currentWeight kg',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Goal: $goal kg',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (currentWeight != 'No data')
                          Text(
                            _getWeightProgressMessage(
                              double.tryParse(currentWeight) ?? 0,
                              goal,
                            ),
                            style: TextStyle(
                              color: _getWeightProgressColor(
                                double.tryParse(currentWeight) ?? 0,
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
    final currentGoal = box.get('weight_goal', defaultValue: 70.0);
    final controller = TextEditingController(text: currentGoal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Weight Goal'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Goal (kg)',
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newGoal = double.tryParse(controller.text);
              if (newGoal != null) {
                box.put('weight_goal', newGoal);
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
