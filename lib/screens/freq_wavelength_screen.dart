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

class _FreqWavelengthScreenState extends State<FreqWavelengthScreen> with SingleTickerProviderStateMixin {
  String _wavelengthResult = '';
  String _freqResult = '';
  final TextEditingController _freqController = TextEditingController();
  final TextEditingController _wavelengthController = TextEditingController();
  List<FlSpot> _freqWavelengthSpots = [];
  static const double _maxFreqGraph = 1e12;
  static const double _maxWavelengthGraph = 1000.0;
  String _freqUnit = 'Hz';
  String _wavelengthUnit = 'm';
  String? _prevFreqValue;
  String? _prevWavelengthValue;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showFreqFormula = false;
  bool _showWavelengthFormula = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _loadCache();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _freqController.dispose();
    _wavelengthController.dispose();
    super.dispose();
  }

  Future<void> _loadCache() async {
    final freqCached = await CacheManager.loadCache(CacheManager.freqKey);
    final wavelengthCached = await CacheManager.loadCache(CacheManager.wavelengthKey);
    if (freqCached != null) {
      setState(() {
        _freqController.text = freqCached;
        _updateFromFreq(freqCached);
      });
    }
    if (wavelengthCached != null) {
      setState(() {
        _wavelengthController.text = wavelengthCached;
        _updateFromWavelength(wavelengthCached);
      });
    }
  }

  void _updateFromFreq(String freq) {
    if (freq.isEmpty) {
      setState(() {
        _wavelengthResult = '';
        _freqWavelengthSpots = [];
      });
      _animationController.reverse();
      return;
    }
    try {
      double freqValue = double.parse(freq);
      if (_freqUnit == 'kHz') freqValue *= 1e3;
      else if (_freqUnit == 'MHz') freqValue *= 1e6;
      else if (_freqUnit == 'GHz') freqValue *= 1e9;
      else if (_freqUnit == 'THz') freqValue *= 1e12;
      if (freqValue <= 0 || freqValue.isNaN || freqValue.isInfinite) {
        setState(() {
          _wavelengthResult = '';
          _freqWavelengthSpots = [];
        });
        _animationController.reverse();
        return;
      }
      double graphFreq = min(freqValue, _maxFreqGraph);
      setState(() {
        _prevFreqValue = _freqController.text;
        _wavelengthResult = Conversions.freqToWavelength(freqValue.toString());
        _freqWavelengthSpots = List.generate(11, (index) {
          double x = graphFreq * (0.5 + index * 0.1);
          double y = 299792458 / x;
          return FlSpot(x / 1e6, y);
        });
        CacheManager.saveCache(CacheManager.freqKey, freq);
        CacheManager.addToHistory('Freq to Wavelength: $freq $_freqUnit = $_wavelengthResult');
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() {
        _wavelengthResult = '';
        _freqWavelengthSpots = [];
      });
      _animationController.reverse();
    }
  }

  void _updateFromWavelength(String wavelength) {
    if (wavelength.isEmpty) {
      setState(() {
        _freqResult = '';
        _freqWavelengthSpots = [];
      });
      _animationController.reverse();
      return;
    }
    try {
      double wavelengthValue = double.parse(wavelength);
      if (_wavelengthUnit == 'cm') wavelengthValue /= 100;
      else if (_wavelengthUnit == 'mm') wavelengthValue /= 1000;
      if (wavelengthValue <= 0 || wavelengthValue.isNaN || wavelengthValue.isInfinite) {
        setState(() {
          _freqResult = '';
          _freqWavelengthSpots = [];
        });
        _animationController.reverse();
        return;
      }
      double graphWavelength = min(wavelengthValue, _maxWavelengthGraph);
      setState(() {
        _prevWavelengthValue = _wavelengthController.text;
        _freqResult = Conversions.wavelengthToFreq(wavelengthValue.toString());
        _freqWavelengthSpots = List.generate(11, (index) {
          double y = graphWavelength * (0.5 + index * 0.1);
          double x = 299792458 / y;
          return FlSpot(x / 1e6, y);
        });
        CacheManager.saveCache(CacheManager.wavelengthKey, wavelength);
        CacheManager.addToHistory('Wavelength to Freq: $wavelength $_wavelengthUnit = $_freqResult');
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() {
        _freqResult = '';
        _freqWavelengthSpots = [];
      });
      _animationController.reverse();
    }
  }

  void _undoFreq() {
    if (_prevFreqValue != null) {
      setState(() {
        _freqController.text = _prevFreqValue!;
        _wavelengthController.clear();
        _freqResult = '';
        _updateFromFreq(_prevFreqValue!);
      });
    }
  }

  void _undoWavelength() {
    if (_prevWavelengthValue != null) {
      setState(() {
        _wavelengthController.text = _prevWavelengthValue!;
        _freqController.clear();
        _wavelengthResult = '';
        _updateFromWavelength(_prevWavelengthValue!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequency ↔ Wavelength Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              final history = await CacheManager.getHistory();
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Calculation History'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: history.map((entry) => ListTile(title: Text(entry))).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'View History',
          ),
        ],
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _freqController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Enter Frequency',
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _freqController.clear();
                                    _wavelengthController.clear();
                                    _wavelengthResult = '';
                                    _freqResult = '';
                                    _freqWavelengthSpots = [];
                                  });
                                },
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _wavelengthController.clear();
                                _wavelengthResult = '';
                                _updateFromFreq(value);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _freqUnit,
                          items: ['Hz', 'kHz', 'MHz', 'GHz', 'THz']
                              .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _freqUnit = value!;
                              _wavelengthController.clear();
                              _wavelengthResult = '';
                              if (_freqController.text.isNotEmpty) {
                                _updateFromFreq(_freqController.text);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'Result: $_wavelengthResult',
                              key: ValueKey(_wavelengthResult),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: _undoFreq,
                          tooltip: 'Undo',
                        ),
                        IconButton(
                          icon: Icon(_showFreqFormula ? Icons.close : Icons.functions),
                          onPressed: () {
                            setState(() {
                              _showFreqFormula = !_showFreqFormula;
                            });
                          },
                          tooltip: 'Show Formula',
                        ),
                      ],
                    ),
                    if (_showFreqFormula) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Formula: λ(m) = c / f(Hz), where c = 299792458 m/s',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _wavelengthController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Enter Wavelength',
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _wavelengthController.clear();
                                    _freqController.clear();
                                    _freqResult = '';
                                    _wavelengthResult = '';
                                    _freqWavelengthSpots = [];
                                  });
                                },
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _freqController.clear();
                                _freqResult = '';
                                _updateFromWavelength(value);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _wavelengthUnit,
                          items: ['m', 'cm', 'mm']
                              .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _wavelengthUnit = value!;
                              _freqController.clear();
                              _freqResult = '';
                              if (_wavelengthController.text.isNotEmpty) {
                                _updateFromWavelength(_wavelengthController.text);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'Result: $_freqResult',
                              key: ValueKey(_freqResult),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: _undoWavelength,
                          tooltip: 'Undo',
                        ),
                        IconButton(
                          icon: Icon(_showWavelengthFormula ? Icons.close : Icons.functions),
                          onPressed: () {
                            setState(() {
                              _showWavelengthFormula = !_showWavelengthFormula;
                            });
                          },
                          tooltip: 'Show Formula',
                        ),
                      ],
                    ),
                    if (_showWavelengthFormula) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Formula: f(Hz) = c / λ(m), where c = 299792458 m/s',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_freqWavelengthSpots.isNotEmpty) ...[
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
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
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
