import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class BaseTrackerScreen extends StatefulWidget {
  final String title;
  final String metric;
  final String unit;

  const BaseTrackerScreen({
    super.key,
    required this.title,
    required this.metric,
    required this.unit,
  });
}

abstract class BaseTrackerState<T extends BaseTrackerScreen> extends State<T> {
  late final Box _healthBox;
  final TextEditingController valueController = TextEditingController();
  final TextEditingController goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _healthBox = Hive.box('healthBox');
  }

  void setGoal() {
    if (goalController.text.isNotEmpty) {
      _healthBox.put(
          '${widget.metric}_goal', double.parse(goalController.text));
      goalController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal updated!')),
      );
    }
  }

  Widget buildChart() {
    // Implement in subclass
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${widget.title} (${widget.unit})',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveValue,
              child: const Text('Save'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Set Goal (${widget.unit})',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: setGoal,
              child: const Text('Set Goal'),
            ),
            const SizedBox(height: 24),
            buildChart(),
          ],
        ),
      ),
    );
  }

  void saveValue();

  @override
  void dispose() {
    valueController.dispose();
    goalController.dispose();
    super.dispose();
  }
}
