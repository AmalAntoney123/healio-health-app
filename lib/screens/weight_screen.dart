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
      final value = _healthBox.get('weight_$dateKey');
      data.add(value?.toDouble() ?? 0);
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            ValueListenableBuilder(
              valueListenable: _healthBox.listenable(),
              builder: (context, box, _) {
                return Text(
                  'Current Weight: ${box.get('weight', defaultValue: 'No data')} kg',
                  style: Theme.of(context).textTheme.titleLarge,
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
    weightController.dispose();
    super.dispose();
  }
}
