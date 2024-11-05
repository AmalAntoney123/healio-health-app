import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('healthBox').listenable(),
        builder: (context, box, _) {
          final sleepHours = box.get('sleep_hours', defaultValue: '8');
          final sleepQuality = box.get('sleep_quality', defaultValue: 'Good');
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Hours of Sleep',
                            suffixText: 'hours',
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(text: sleepHours),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              box.put('sleep_hours', value);
                              final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
                              box.put('sleep_hours_$dateKey', value);
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
                          'Sleep Quality',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
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
                              final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
                              box.put('sleep_quality_$dateKey', newValue);
                            }
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