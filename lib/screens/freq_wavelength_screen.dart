import 'package:flutter/material.dart';
import '../utils/conversions.dart';

class FreqWavelengthScreen extends StatefulWidget {
  const FreqWavelengthScreen({super.key});

  @override
  _FreqWavelengthScreenState createState() => _FreqWavelengthScreenState();
}

class _FreqWavelengthScreenState extends State<FreqWavelengthScreen> {
  String _wavelengthResult = '';
  String _freqResult = '';
  final TextEditingController _freqController = TextEditingController();
  final TextEditingController _wavelengthController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequency ↔ Wavelength Converter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequency to Wavelength',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _freqController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Frequency (Hz)',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _wavelengthResult = Conversions.freqToWavelength(value);
                          _wavelengthController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Result: $_wavelengthResult', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wavelength to Frequency',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _wavelengthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Wavelength (m)',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _freqResult = Conversions.wavelengthToFreq(value);
                          _freqController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Result: $_freqResult', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
