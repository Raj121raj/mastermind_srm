import 'package:flutter/material.dart';
import '../utils/conversions.dart';

class RectPolarScreen extends StatefulWidget {
  const RectPolarScreen({super.key});

  @override
  _RectPolarScreenState createState() => _RectPolarScreenState();
}

class _RectPolarScreenState extends State<RectPolarScreen> {
  String _polarResult = '';
  String _rectResult = '';
  final TextEditingController _realController = TextEditingController();
  final TextEditingController _imagController = TextEditingController();
  final TextEditingController _magController = TextEditingController();
  final TextEditingController _angleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rectangular ↔ Polar Converter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rectangular to Polar
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rectangular to Polar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _realController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Real Part (x)',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _polarResult = Conversions.rectToPolar(_realController.text, _imagController.text);
                          _magController.clear();
                          _angleController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _imagController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Imaginary Part (y)',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _polarResult = Conversions.rectToPolar(_realController.text, _imagController.text);
                          _magController.clear();
                          _angleController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Result: $_polarResult', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Polar to Rectangular
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Polar to Rectangular',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _magController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Magnitude (r)',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _rectResult = Conversions.polarToRect(_magController.text, _angleController.text);
                          _realController.clear();
                          _imagController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _angleController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Angle (degrees)',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _rectResult = Conversions.polarToRect(_magController.text, _angleController.text);
                          _realController.clear();
                          _imagController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Result: $_rectResult', style: Theme.of(context).textTheme.bodyLarge),
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
