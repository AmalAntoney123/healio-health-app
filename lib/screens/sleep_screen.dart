import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final _healthBox = Hive.box('healthBox');
  final sleepController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentSleep = _healthBox.get('sleep_hours');
    if (currentSleep != null) {
      sleepController.text = currentSleep;
    }
  }

  void _saveSleep() {
    if (sleepController.text.isNotEmpty) {
      final now = DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(now);

      _healthBox.put('sleep_hours', sleepController.text);
      _healthBox.put(
          'sleep_hours_$dateKey', double.parse(sleepController.text));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sleep hours saved!')),
      );
    }
  }

  Widget _buildSleepChart() {
    return SizedBox(
      height: 200,
      child: ValueListenableBuilder(
        valueListenable: _healthBox.listenable(),
        builder: (context, box, _) {
          final sleepData = _getLast7DaysData();

          return LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < sleepData.length) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            DateFormat('MM/dd').format(
                              DateTime.now().subtract(
                                Duration(
                                    days: sleepData.length - 1 - value.toInt()),
                              ),
                            ),
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
                  spots: sleepData.asMap().entries.map((entry) {
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
      var value = _healthBox.get('sleep_hours_$dateKey');

      // For today, if no date-specific value exists, try to get the current value
      if (i == 0 && value == null) {
        final currentSleep = _healthBox.get('sleep_hours');
        if (currentSleep != null) {
          value = double.tryParse(currentSleep);
        }
      }

      data.add(value?.toDouble() ?? 0);
    }

    return data;
  }

  List<String> _getLast7DaysQuality() {
    final List<String> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Try to get the date-specific value first
      var quality = _healthBox.get('sleep_quality_$dateKey');

      // For today, if no date-specific value exists, try to get the current value
      if (i == 0 && quality == null) {
        final currentQuality = _healthBox.get('sleep_quality');
        if (currentQuality != null) {
          // If we have current quality data, use it and save it for today
          quality = currentQuality;
          _healthBox.put('sleep_quality_$dateKey', currentQuality);
        }
      }

      data.add(quality ?? 'No data');
    }

    return data;
  }

  Color _getQualityColor(String quality) {
    switch (quality) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                      'Sleep Duration',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: sleepController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Hours of Sleep',
                        suffixText: 'hours',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveSleep,
                      child: const Text('Save Sleep Hours'),
                    ),
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
                      'Sleep Quality',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: _healthBox.listenable(),
                      builder: (context, box, _) {
                        final sleepQuality =
                            box.get('sleep_quality', defaultValue: 'Good');
                        return DropdownButton<String>(
                          value: sleepQuality,
                          isExpanded: true,
                          items: ['Excellent', 'Good', 'Fair', 'Poor']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              box.put('sleep_quality', newValue);
                              final dateKey = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now());
                              box.put('sleep_quality_$dateKey', newValue);
                            }
                          },
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
                      'Sleep History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildSleepChart(),
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
                      'Quality History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder(
                      valueListenable: _healthBox.listenable(),
                      builder: (context, box, _) {
                        final qualityData = _getLast7DaysQuality();
                        if (qualityData
                            .every((quality) => quality == 'No data')) {
                          return const Center(
                            child: Text('No sleep quality data recorded yet'),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: qualityData.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final date = DateTime.now().subtract(
                              Duration(days: qualityData.length - 1 - index),
                            );
                            return ListTile(
                              title: Text(
                                DateFormat('EEEE, MMM dd').format(date),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getQualityColor(qualityData[index]),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  qualityData[index],
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
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context) {
    final box = Hive.box('healthBox');
    final currentGoal = box.get('sleep_goal', defaultValue: 8.0);
    final controller = TextEditingController(text: currentGoal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Sleep Goal'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Goal (hours)',
            suffixText: 'hours',
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
                box.put('sleep_goal', newGoal);
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
