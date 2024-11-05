import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HealthAssessmentScreen extends StatefulWidget {
  const HealthAssessmentScreen({super.key});

  @override
  State<HealthAssessmentScreen> createState() => _HealthAssessmentScreenState();
}

class _HealthAssessmentScreenState extends State<HealthAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form values
  final _formData = {
    'age': 0,
    'bmi': 0.0,
    'glucose': 0,
    'blood_pressure': 0,
    'insulin': 0,
    'exercise': 0,
    'family_history': 0,
  };

  List<Step> get _formSteps => [
        Step(
          title: const Text('Age'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter your age'),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter your age';
              final age = int.tryParse(value);
              if (age == null || age < 0 || age > 120)
                return 'Please enter a valid age';
              return null;
            },
            onSaved: (value) => _formData['age'] = int.parse(value!),
          ),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('BMI'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter your BMI'),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter your BMI';
              final bmi = double.tryParse(value);
              if (bmi == null || bmi < 10 || bmi > 50)
                return 'Please enter a valid BMI';
              return null;
            },
            onSaved: (value) => _formData['bmi'] = double.parse(value!),
          ),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text('Blood Glucose'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter your blood glucose level (mg/dL)',
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter your glucose level';
              final glucose = int.tryParse(value);
              if (glucose == null || glucose < 0)
                return 'Please enter a valid glucose level';
              return null;
            },
            onSaved: (value) => _formData['glucose'] = int.parse(value!),
          ),
          isActive: _currentStep >= 2,
        ),
        Step(
          title: const Text('Blood Pressure'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter your systolic blood pressure',
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter your blood pressure';
              final bp = int.tryParse(value);
              if (bp == null || bp < 0)
                return 'Please enter a valid blood pressure';
              return null;
            },
            onSaved: (value) => _formData['blood_pressure'] = int.parse(value!),
          ),
          isActive: _currentStep >= 3,
        ),
        Step(
          title: const Text('Insulin'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter your insulin level',
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter your insulin level';
              final insulin = int.tryParse(value);
              if (insulin == null || insulin < 0)
                return 'Please enter a valid insulin level';
              return null;
            },
            onSaved: (value) => _formData['insulin'] = int.parse(value!),
          ),
          isActive: _currentStep >= 4,
        ),
        Step(
          title: const Text('Exercise'),
          content: DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Weekly exercise frequency',
            ),
            items: const [
              DropdownMenuItem(value: 0, child: Text('None')),
              DropdownMenuItem(value: 1, child: Text('1-2 times')),
              DropdownMenuItem(value: 2, child: Text('3-4 times')),
              DropdownMenuItem(value: 3, child: Text('5+ times')),
            ],
            validator: (value) {
              if (value == null) return 'Please select exercise frequency';
              return null;
            },
            onSaved: (value) => _formData['exercise'] = value!,
            onChanged: (value) =>
                setState(() => _formData['exercise'] = value!),
          ),
          isActive: _currentStep >= 5,
        ),
        Step(
          title: const Text('Family History'),
          content: DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              labelText: 'Family history of diabetes',
            ),
            items: const [
              DropdownMenuItem(value: 0, child: Text('No')),
              DropdownMenuItem(value: 1, child: Text('Yes')),
            ],
            validator: (value) {
              if (value == null) return 'Please select family history';
              return null;
            },
            onSaved: (value) => _formData['family_history'] = value!,
            onChanged: (value) =>
                setState(() => _formData['family_history'] = value!),
          ),
          isActive: _currentStep >= 6,
        ),
      ];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://ml-health-analysis-api.onrender.com/health/predict'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'age': _formData['age'],
          'bmi': _formData['bmi'],
          'glucose': _formData['glucose'],
          'blood_pressure': _formData['blood_pressure'],
          'insulin': _formData['insulin'],
          'exercise': _formData['exercise'],
          'family_history': _formData['family_history'],
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _showResults(result);
      } else {
        throw Exception('Failed to get prediction');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showResults(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Risk Assessment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Level: ${result['risk_level']}'),
            Text('Confidence: ${result['confidence']}%'),
            const SizedBox(height: 16),
            const Text('Recommendations:'),
            const SizedBox(height: 8),
            ...List<Widget>.from(
              (result['recommendations'] as List).map((r) => Text('• $r')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Assessment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _isLoading
              ? null
              : () {
                  if (_currentStep < _formSteps.length - 1) {
                    setState(() => _currentStep++);
                  } else {
                    _submitForm();
                  }
                },
          onStepCancel: _isLoading
              ? null
              : () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  }
                },
          controlsBuilder: (context, details) {
            final bool isLastStep = _currentStep == _formSteps.length - 1;
            return Container(
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else ...[
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(isLastStep ? 'Submit' : 'Continue'),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
          steps: _formSteps,
        ),
      ),
    );
  }
}
