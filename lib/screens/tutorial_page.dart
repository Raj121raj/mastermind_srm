import 'package:flutter/material.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use RF Calculator'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'dBm ↔ Watts Converter'),
          _buildSectionContent(
            context,
            'This converter switches between dBm (decibel-milliwatts) and Watts.\n\n'
            '- **dBm to Watts**: Enter a dBm value (e.g., 30) and see the power in Watts (0.001 W). '
            'The graph shows power variation.\n'
            '- **Watts to dBm**: Enter a Watts value (e.g., 1) and select W or mW, get dBm (30 dBm). '
            'Use the dropdown to switch units.\n\n'
            'Buttons:\n'
            '- Clear (X): Resets all fields.\n'
            '- Undo: Restores the last input.\n'
            '- Formula (?): Shows the conversion formula.',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Frequency ↔ Wavelength Converter'),
          _buildSectionContent(
            context,
            'This converter translates between frequency (Hz) and wavelength (m).\n\n'
            '- **Frequency to Wavelength**: Enter a frequency (e.g., 300 MHz) and select a unit '
            '(Hz, kHz, MHz, GHz, THz), get wavelength (1 m). Graph shows the curve.\n'
            '- **Wavelength to Frequency**: Enter a wavelength (e.g., 1 m) and select a unit '
            '(m, cm, mm), get frequency (299792458 Hz).\n\n'
            'Buttons work the same as above.',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Rectangular ↔ Polar Converter'),
          _buildSectionContent(
            context,
            'This converter switches between rectangular (x, y) and polar (r, θ) coordinates.\n\n'
            '- **Rectangular to Polar**: Enter x and y (e.g., 3, 4), tap "Add Point" to plot and '
            'get r and θ (5, 53.13°). Add multiple points to see them on the scatter graph.\n'
            '- **Polar to Rectangular**: Enter r and θ (e.g., 5, 45°), tap "Add Point" to plot and '
            'get x and y (3.54, 3.54).\n\n'
            '- Delete (trash): Removes a point from the list.\n'
            '- Clear and Undo work similarly.',
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got It!'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSectionContent(BuildContext context, String content) {
    return Text(
      content,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
