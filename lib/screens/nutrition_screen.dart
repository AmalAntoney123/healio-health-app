import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/history_chart.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  List<double> _getLast7DaysData(Box box) {
    final List<double> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Try to get the date-specific value first
      var value = box.get('calories_$dateKey');

      // For today, if no date-specific value exists, try to get the current value
      if (i == 0 && value == null) {
        final currentCalories = box.get('calories');
        if (currentCalories != null) {
          value = int.tryParse(currentCalories);
          // Save today's current value with date key
          box.put('calories_$dateKey', value);
        }
      }

      data.add(value?.toDouble() ?? 0);
    }

    return data;
  }

  Color _getProgressColor(int calories, int goal) {
    if (goal == 0) return Colors.grey;
    final percentage = calories / goal;
    if (percentage > 1.1) {
      return Colors.red; // Over target
    } else if (percentage >= 0.9 && percentage <= 1.1) {
      return Colors.green; // On target
    } else if (percentage >= 0.7) {
      return Colors.orange; // Getting close
    } else {
      return Colors.blue; // Under target
    }
  }

  String _getProgressMessage(int calories, int goal) {
    if (goal == 0) return 'No goal set';
    final percentage = calories / goal;
    if (percentage > 1.1) {
      return 'Over target';
    } else if (percentage >= 0.9 && percentage <= 1.1) {
      return 'On target';
    } else if (percentage >= 0.7) {
      return 'Getting close';
    } else {
      return 'Under target';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('healthBox').listenable(),
        builder: (context, box, _) {
          final calories = box.get('calories', defaultValue: '0');
          final calorieGoal = box.get('calorie_goal', defaultValue: '2000');
          final caloriesData = _getLast7DaysData(box);

          return SingleChildScrollView(
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
                          'Calorie Tracking',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Calories Consumed',
                            suffixText: 'kcal',
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(text: calories),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              box.put('calories', value);
                              final dateKey = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now());
                              box.put('calories_$dateKey', int.parse(value));
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Daily Calorie Goal',
                            suffixText: 'kcal',
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(text: calorieGoal),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              box.put('calorie_goal', value);
                            }
                          },
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
                          'Quick Add Meal',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                final current = int.tryParse(calories) ?? 0;
                                final newValue = (current + 300).toString();
                                box.put('calories', newValue);
                                final dateKey = DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now());
                                box.put('calories_$dateKey', current + 300);
                              },
                              child: const Text('Breakfast +300'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final current = int.tryParse(calories) ?? 0;
                                final newValue = (current + 500).toString();
                                box.put('calories', newValue);
                                final dateKey = DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now());
                                box.put('calories_$dateKey', current + 500);
                              },
                              child: const Text('Lunch +500'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final current = int.tryParse(calories) ?? 0;
                                final newValue = (current + 700).toString();
                                box.put('calories', newValue);
                                final dateKey = DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now());
                                box.put('calories_$dateKey', current + 700);
                              },
                              child: const Text('Dinner +700'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                HistoryChart(
                  data: caloriesData,
                  title: 'Calorie History',
                  unit: 'kcal',
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
                          'Nutrition History',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        if (caloriesData.every((calories) => calories == 0))
                          const Center(
                            child: Text('No calorie data recorded yet'),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: caloriesData.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final date = DateTime.now().subtract(
                                Duration(days: caloriesData.length - 1 - index),
                              );
                              final dayCalories = caloriesData[index].toInt();
                              final goal = int.tryParse(calorieGoal) ?? 2000;

                              return ListTile(
                                title: Text(
                                  DateFormat('EEEE, MMM dd').format(date),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                subtitle: Text(
                                  _getProgressMessage(dayCalories, goal),
                                  style: TextStyle(
                                    color: _getProgressColor(dayCalories, goal),
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getProgressColor(dayCalories, goal),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    dayCalories == 0
                                        ? 'No data'
                                        : '$dayCalories kcal',
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
