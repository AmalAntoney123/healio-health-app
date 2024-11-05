import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/history_chart.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  List<double> _getLast7DaysData(Box box) {
    final List<double> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Try to get the date-specific value first
      var value = box.get('water_intake_$dateKey');

      // For today, if no date-specific value exists, try to get the current value
      if (i == 0 && value == null) {
        final currentWater = box.get('water_intake');
        if (currentWater != null) {
          value = int.tryParse(currentWater);
        }
      }

      data.add(value?.toDouble() ?? 0);
    }

    return data;
  }

  List<String> _getLast7DaysIntake(Box box) {
    final List<String> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Try to get the date-specific value first
      var value = box.get('water_intake_$dateKey');

      // For today, if no date-specific value exists, try to get the current value
      if (i == 0 && value == null) {
        final currentWater = box.get('water_intake');
        if (currentWater != null) {
          value = int.tryParse(currentWater);
          // Save today's current value with date key
          box.put('water_intake_$dateKey', value);
        }
      }

      if (value != null) {
        data.add('$value ml');
      } else {
        data.add('No data');
      }
    }

    return data;
  }

  Color _getProgressColor(int intake, int goal) {
    final percentage = intake / goal;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('healthBox').listenable(),
        builder: (context, box, _) {
          final waterIntake = box.get('water_intake', defaultValue: '0');
          final waterGoal = box.get('water_goal', defaultValue: '2000');
          final waterData = _getLast7DaysData(box);
          final intakeHistory = _getLast7DaysIntake(box);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Daily Water Intake',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Water Intake',
                            suffixText: 'ml',
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(text: waterIntake),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              box.put('water_intake', value);
                              final dateKey = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now());
                              box.put(
                                  'water_intake_$dateKey', int.parse(value));
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Daily Goal',
                            suffixText: 'ml',
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(text: waterGoal),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              box.put('water_goal', value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final current = int.tryParse(waterIntake) ?? 0;
                    final newValue = (current + 250).toString();
                    box.put('water_intake', newValue);
                    final dateKey =
                        DateFormat('yyyy-MM-dd').format(DateTime.now());
                    box.put('water_intake_$dateKey', current + 250);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add 250ml'),
                ),
                const SizedBox(height: 24),
                HistoryChart(
                  data: waterData,
                  title: 'Water Intake History',
                  unit: 'ml',
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Intake History',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        if (intakeHistory
                            .every((intake) => intake == 'No data'))
                          const Center(
                            child: Text('No water intake data recorded yet'),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: intakeHistory.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final date = DateTime.now().subtract(
                                Duration(
                                    days: intakeHistory.length - 1 - index),
                              );
                              final intake = intakeHistory[index];
                              final intakeValue =
                                  int.tryParse(intake.replaceAll(' ml', '')) ??
                                      0;
                              final goalValue = int.tryParse(waterGoal) ?? 2000;

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
                                    color: intake == 'No data'
                                        ? Colors.grey
                                        : _getProgressColor(
                                            intakeValue, goalValue),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    intake,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
