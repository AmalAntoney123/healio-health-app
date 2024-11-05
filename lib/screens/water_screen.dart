import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

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
          
          return Padding(
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
                              final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
                              box.put('water_intake_$dateKey', value);
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
                    box.put('water_intake', (current + 250).toString());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add 250ml'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 