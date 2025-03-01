import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/conversions.dart';
import '../utils/cache_manager.dart';

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
  List<FlSpot> _freqWavelengthSpots = [];
  static const double _maxFreqGraph = 1e12;
  static const double _maxWavelengthGraph = 1000.0;

  @override
  void initState() {
    super.initState();
    _loadCache();
  }

  Future<void> _loadCache() async {
    final freqCached = await CacheManager.loadCache(CacheManager.freqKey);
    final wavelengthCached = await CacheManager.loadCache(CacheManager.wavelengthKey);
    if (freqCached != null) {
      setState(() {
        _freqController.text = freqCached;
        _wavelengthResult = Conversions.freqToWavelength(freqCached);
        _updateGraphFromFreq(freqCached);
      });
    }
    if (wavelengthCached != null) {
      setState(() {
        _wavelengthController.text = wavelengthCached;
        _freqResult = Conversions.wavelengthToFreq(wavelengthCached);
        _updateGraphFromWavelength(wavelengthCached);
      });
    }
  }

  void _updateGraphFromFreq(String freq) {
    if (freq.isEmpty) {
      setState(() => _freqWavelengthSpots = []);
      return;
    }
    try {
      double freqValue = double.parse(freq);
      if (freqValue <= 0 || freqValue.isNaN || freqValue.isInfinite) {
        setState(() => _freqWavelengthSpots = []);
        return;
      }
      double graphFreq = min(freqValue, _maxFreqGraph);
      setState(() {
        _freqWavelengthSpots = List.generate(11, (index) {
          double x = graphFreq * (0.5 + index * 0.1);
          double y = 299792458 / x;
          return FlSpot(x / 1e6, y);
        });
        CacheManager.saveCache(CacheManager.freqKey, freq);
      });
    } catch (e) {
      setState(() => _freqWavelengthSpots = []);
    }
  }

  void _updateGraphFromWavelength(String wavelength) {
    if (wavelength.isEmpty) {
      setState(() => _freqWavelengthSpots = []);
      return;
    }
    try {
      double wavelengthValue = double.parse(wavelength);
      if (wavelengthValue <= 0 || wavelengthValue.isNaN || wavelengthValue.isInfinite) {
        setState(() => _freqWavelengthSpots = []);
        return;
      }
      double graphWavelength = min(wavelengthValue, _maxWavelengthGraph);
      setState(() {
        _freqWavelengthSpots = List.generate(11, (index) {
          double y = graphWavelength * (0.5 + index * 0.1);
          double x = 299792458 / y;
          return FlSpot(x / 1e6, y);
        });
        CacheManager.saveCache(CacheManager.wavelengthKey, wavelength);
      });
    } catch (e) {
      setState(() => _freqWavelengthSpots = []);
    }
  }

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
                    const SizedBox(height: 8),
                    Text(
                      'Translates frequency (Hz) to wavelength (m) using the speed of light (c ≈ 299,792,458 m/s). Higher frequencies mean shorter wavelengths.',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                          _updateGraphFromFreq(value);
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
                    const SizedBox(height: 8),
                    Text(
                      'Converts wavelength (m) to frequency (Hz) with the speed of light as the bridge. Longer wavelengths correspond to lower frequencies.',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                          _updateGraphFromWavelength(value);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Result: $_freqResult', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_freqWavelengthSpots.isNotEmpty) ...[
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          interval: max(1.0, (_freqWavelengthSpots.last.y - _freqWavelengthSpots.first.y) / 3),
                          getTitlesWidget: (value, meta) => SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              value.toStringAsExponential(1),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: max(1.0, (_freqWavelengthSpots.last.x - _freqWavelengthSpots.first.x) / 3),
                          getTitlesWidget: (value, meta) => SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toStringAsFixed(0)} MHz',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    minX: _freqWavelengthSpots.first.x,
                    maxX: _freqWavelengthSpots.last.x,
                    minY: _freqWavelengthSpots.first.y,
                    maxY: _freqWavelengthSpots.last.y,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _freqWavelengthSpots,
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Behold: The graph dances only up to 1 THz or 1000 m. Beyond these ethereal bounds, it sketches a humble tale of waves in serene restraint.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
