import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

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
          
          return Padding(
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
                              final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
                              box.put('calories_$dateKey', value);
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
                                box.put('calories', (current + 300).toString());
                              },
                              child: const Text('Breakfast +300'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final current = int.tryParse(calories) ?? 0;
                                box.put('calories', (current + 500).toString());
                              },
                              child: const Text('Lunch +500'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final current = int.tryParse(calories) ?? 0;
                                box.put('calories', (current + 700).toString());
                              },
                              child: const Text('Dinner +700'),
                            ),
                          ],
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
