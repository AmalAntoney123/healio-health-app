import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  List<Map<String, String>> _getLast7DaysMood(Box box) {
    final List<Map<String, String>> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Try to get the date-specific values first
      var mood = box.get('mood_$dateKey');
      var note = box.get('mood_note_$dateKey');

      // For today, if no date-specific value exists, try to get the current values
      if (i == 0) {
        if (mood == null) {
          final currentMood = box.get('mood');
          if (currentMood != null) {
            mood = currentMood;
            box.put('mood_$dateKey', currentMood);
          }
        }
        if (note == null) {
          final currentNote = box.get('mood_note');
          if (currentNote != null) {
            note = currentNote;
            box.put('mood_note_$dateKey', currentNote);
          }
        }
      }

      data.add({
        'mood': mood ?? 'No data',
        'note': note ?? '',
      });
    }

    return data;
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return Colors.green;
      case 'Excited':
        return Colors.orange;
      case 'Calm':
        return Colors.blue;
      case 'Tired':
        return Colors.purple;
      case 'Stressed':
        return Colors.red;
      case 'Sad':
        return Colors.grey.shade700;
      default:
        return Colors.grey;
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'Happy':
        return Icons.sentiment_very_satisfied;
      case 'Excited':
        return Icons.celebration;
      case 'Calm':
        return Icons.spa;
      case 'Tired':
        return Icons.bedtime;
      case 'Stressed':
        return Icons.warning_amber;
      case 'Sad':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('healthBox').listenable(),
        builder: (context, box, _) {
          final currentMood = box.get('mood', defaultValue: 'Happy');
          final moodNote = box.get('mood_note', defaultValue: '');
          final moodHistory = _getLast7DaysMood(box);

          return SingleChildScrollView(
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
                          'How are you feeling?',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        DropdownButton<String>(
                          value: currentMood,
                          isExpanded: true,
                          items: [
                            'Happy',
                            'Excited',
                            'Calm',
                            'Tired',
                            'Stressed',
                            'Sad'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Icon(_getMoodIcon(value),
                                      color: _getMoodColor(value)),
                                  const SizedBox(width: 8),
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              box.put('mood', newValue);
                              final dateKey = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now());
                              box.put('mood_$dateKey', newValue);
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
                          'Notes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'How was your day?',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          controller: TextEditingController(text: moodNote),
                          onSubmitted: (value) {
                            box.put('mood_note', value);
                            final dateKey =
                                DateFormat('yyyy-MM-dd').format(DateTime.now());
                            box.put('mood_note_$dateKey', value);
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
                          'Mood History',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        if (moodHistory
                            .every((day) => day['mood'] == 'No data'))
                          const Center(
                            child: Text('No mood data recorded yet'),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: moodHistory.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final date = DateTime.now().subtract(
                                Duration(days: moodHistory.length - 1 - index),
                              );
                              final dayMood = moodHistory[index]['mood']!;
                              final dayNote = moodHistory[index]['note']!;

                              return ListTile(
                                leading: Icon(
                                  _getMoodIcon(dayMood),
                                  color: _getMoodColor(dayMood),
                                  size: 28,
                                ),
                                title: Text(
                                  DateFormat('EEEE, MMM dd').format(date),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                subtitle: dayNote.isNotEmpty
                                    ? Text(
                                        dayNote,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getMoodColor(dayMood),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    dayMood,
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
