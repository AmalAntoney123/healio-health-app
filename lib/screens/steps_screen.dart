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
      final value = _healthBox.get('steps_$dateKey');
      data.add(value?.toInt() ?? 0);
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Steps Counter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: stepsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Steps',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: _healthBox.listenable(),
              builder: (context, box, _) {
                final hasData = box.get('steps', defaultValue: null) != null;
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: _saveSteps,
                      child: Text(hasData ? 'Edit Steps' : 'Save Steps'),
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
                    Text(
                      'Today\'s Steps: ${box.get('steps', defaultValue: 'No data')}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    stepsController.dispose();
    super.dispose();
  }
}
