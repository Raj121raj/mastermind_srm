import 'package:flutter/material.dart';
import '../utils/conversions.dart';
import '../widgets/conversion_card.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  _ConverterScreenState createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  String _wattsResult = '';
  String _wavelengthResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('dBm & Frequency Converter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConversionCard(
              title: 'dBm to Watts',
              labelText: 'Enter dBm',
              onChanged: (value) {
                setState(() {
                  _wattsResult = Conversions.dbmToWatts(value);
                });
              },
              result: _wattsResult,
            ),
            const SizedBox(height: 24),
            ConversionCard(
              title: 'Frequency to Wavelength',
              labelText: 'Enter Frequency (Hz)',
              onChanged: (value) {
                setState(() {
                  _wavelengthResult = Conversions.freqToWavelength(value);
                });
              },
              result: _wavelengthResult,
            ),
          ],
        ),
      ),
    );
  }
}
