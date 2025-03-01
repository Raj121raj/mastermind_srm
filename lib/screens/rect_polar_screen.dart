import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/conversions.dart';
import '../utils/cache_manager.dart';

class RectPolarScreen extends StatefulWidget {
  const RectPolarScreen({super.key});

  @override
  _RectPolarScreenState createState() => _RectPolarScreenState();
}

class _RectPolarScreenState extends State<RectPolarScreen> with SingleTickerProviderStateMixin {
  String _polarResult = '';
  String _rectResult = '';
  final TextEditingController _realController = TextEditingController();
  final TextEditingController _imagController = TextEditingController();
  final TextEditingController _magController = TextEditingController();
  final TextEditingController _angleController = TextEditingController();
  List<FlSpot> _rectSpots = [];
  List<Map<String, String>> _rectPoints = []; // Store (x, y) pairs
  List<Map<String, String>> _polarPoints = []; // Store (r, θ) pairs
  static const double _maxValueGraph = 1000.0;
  String? _prevRealValue;
  String? _prevImagValue;
  String? _prevMagValue;
  String? _prevAngleValue;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _realController.dispose();
    _imagController.dispose();
    _magController.dispose();
    _angleController.dispose();
    super.dispose();
  }

  Future<void> _loadCache() async {
    final realCached = await CacheManager.loadCache(CacheManager.realKey);
    final imagCached = await CacheManager.loadCache(CacheManager.imagKey);
    final magCached = await CacheManager.loadCache(CacheManager.magKey);
    final angleCached = await CacheManager.loadCache(CacheManager.angleKey);
    if (realCached != null && imagCached != null) {
      setState(() {
        _realController.text = realCached;
        _imagController.text = imagCached;
        _polarResult = Conversions.rectToPolar(realCached, imagCached);
        _rectPoints.add({'real': realCached, 'imag': imagCached});
        _updateGraphFromRect();
      });
    }
    if (magCached != null && angleCached != null) {
      setState(() {
        _magController.text = magCached;
        _angleController.text = angleCached;
        _rectResult = Conversions.polarToRect(magCached, angleCached);
        _polarPoints.add({'mag': magCached, 'angle': angleCached});
        _updateGraphFromPolar();
      });
    }
  }

  void _addRectPoint() {
    final real = _realController.text;
    final imag = _imagController.text;
    if (real.isNotEmpty && imag.isNotEmpty) {
      try {
        double.parse(real);
        double.parse(imag);
        setState(() {
          _prevRealValue = real;
          _prevImagValue = imag;
          _rectPoints.add({'real': real, 'imag': imag});
          _polarPoints.clear(); // Clear opposite list
          _polarResult = Conversions.rectToPolar(real, imag);
          _magController.clear();
          _angleController.clear();
          _rectResult = '';
          _updateGraphFromRect();
        });
      } catch (e) {
        // Ignore invalid inputs
      }
    }
  }

  void _addPolarPoint() {
    final mag = _magController.text;
    final angle = _angleController.text;
    if (mag.isNotEmpty && angle.isNotEmpty) {
      try {
        double.parse(mag);
        double.parse(angle);
        setState(() {
          _prevMagValue = mag;
          _prevAngleValue = angle;
          _polarPoints.add({'mag': mag, 'angle': angle});
          _rectPoints.clear(); // Clear opposite list
          _rectResult = Conversions.polarToRect(mag, angle);
          _realController.clear();
          _imagController.clear();
          _polarResult = '';
          _updateGraphFromPolar();
        });
      } catch (e) {
        // Ignore invalid inputs
      }
    }
  }

  void _updateGraphFromRect() {
    setState(() {
      _rectSpots = _rectPoints.map((point) {
        double x = double.parse(point['real']!);
        double y = double.parse(point['imag']!);
        double graphX = x.abs() > _maxValueGraph ? (_maxValueGraph * x.sign) : x;
        double graphY = y.abs() > _maxValueGraph ? (_maxValueGraph * y.sign) : y;
        return FlSpot(graphX, graphY);
      }).toList();
    });
    _animationController.forward(from: 0);
  }

  void _updateGraphFromPolar() {
    setState(() {
      _rectSpots = _polarPoints.map((point) {
        double r = double.parse(point['mag']!);
        double thetaDeg = double.parse(point['angle']!);
        double graphR = min(r, _maxValueGraph);
        double thetaRad = thetaDeg * pi / 180;
        double x = graphR * cos(thetaRad);
        double y = graphR * sin(thetaRad);
        return FlSpot(x, y);
      }).toList();
    });
    _animationController.forward(from: 0);
  }

  void _deleteRectPoint(int index) {
    setState(() {
      _rectPoints.removeAt(index);
      _polarResult = '';
      _rectResult = '';
      if (_rectPoints.isNotEmpty) {
        _polarResult = Conversions.rectToPolar(_rectPoints.last['real']!, _rectPoints.last['imag']!);
      }
      _updateGraphFromRect();
    });
  }

  void _deletePolarPoint(int index) {
    setState(() {
      _polarPoints.removeAt(index);
      _polarResult = '';
      _rectResult = '';
      if (_polarPoints.isNotEmpty) {
        _rectResult = Conversions.polarToRect(_polarPoints.last['mag']!, _polarPoints.last['angle']!);
      }
      _updateGraphFromPolar();
    });
  }

  void _undoRect() {
    if (_prevRealValue != null && _prevImagValue != null) {
      setState(() {
        _realController.text = _prevRealValue!;
        _imagController.text = _prevImagValue!;
        _magController.clear();
        _angleController.clear();
        _rectResult = '';
        _polarResult = Conversions.rectToPolar(_prevRealValue!, _prevImagValue!);
        _rectPoints.add({'real': _prevRealValue!, 'imag': _prevImagValue!});
        _polarPoints.clear();
        _updateGraphFromRect();
      });
    }
  }

  void _undoPolar() {
    if (_prevMagValue != null && _prevAngleValue != null) {
      setState(() {
        _magController.text = _prevMagValue!;
        _angleController.text = _prevAngleValue!;
        _realController.clear();
        _imagController.clear();
        _polarResult = '';
        _rectResult = Conversions.polarToRect(_prevMagValue!, _prevAngleValue!);
        _polarPoints.add({'mag': _prevMagValue!, 'angle': _prevAngleValue!});
        _rectPoints.clear();
        _updateGraphFromPolar();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rectangular ↔ Polar Converter'),
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
                      'Rectangular to Polar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shifts from rectangular (real, imaginary) to polar (magnitude, angle) form. Add multiple points to plot.',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _realController.clear();
                              _imagController.clear();
                              _magController.clear();
                              _angleController.clear();
                              _polarResult = '';
                              _rectResult = '';
                              _rectPoints.clear();
                              _polarPoints.clear();
                              _rectSpots = [];
                            });
                          },
                        ),
                      ),
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
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _addRectPoint,
                      child: const Text('Add Point'),
                    ),
                    const SizedBox(height: 12),
                    if (_rectPoints.isNotEmpty) ...[
                      Text(
                        'Points:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      ..._rectPoints.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, String> point = entry.value;
                        return ListTile(
                          title: Text('(${point['real']}, ${point['imag']})'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteRectPoint(index),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'Result: $_polarResult',
                              key: ValueKey(_polarResult),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: _undoRect,
                          tooltip: 'Undo',
                        ),
                      ],
                    ),
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
                      'Polar to Rectangular',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Maps polar (magnitude, angle) to rectangular (real, imaginary) coordinates. Add multiple points to plot.',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _magController.clear();
                              _angleController.clear();
                              _realController.clear();
                              _imagController.clear();
                              _polarResult = '';
                              _rectResult = '';
                              _rectPoints.clear();
                              _polarPoints.clear();
                              _rectSpots = [];
                            });
                          },
                        ),
                      ),
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
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _addPolarPoint,
                      child: const Text('Add Point'),
                    ),
                    const SizedBox(height: 12),
                    if (_polarPoints.isNotEmpty) ...[
                      Text(
                        'Points:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      ..._polarPoints.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, String> point = entry.value;
                        return ListTile(
                          title: Text('(${point['mag']}, ${point['angle']}°)'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deletePolarPoint(index),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'Result: $_rectResult',
                              key: ValueKey(_rectResult),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: _undoPolar,
                          tooltip: 'Undo',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_rectSpots.isNotEmpty) ...[
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    height: 250,
                    child: ScatterChart(
                      ScatterChartData(
                        scatterSpots: _rectSpots
                            .map((spot) => ScatterSpot(
                                  spot.x,
                                  spot.y,
                                  dotPainter: FlDotCirclePainter(
                                    radius: 8 + (sqrt(spot.x * spot.x + spot.y * spot.y) / _maxValueGraph * 4),
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                  ),
                                ))
                            .toList(),
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              interval: max(1.0, (_rectSpots.last.y - _rectSpots.first.y).abs() / 3),
                              getTitlesWidget: (value, meta) => SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  value.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: max(1.0, (_rectSpots.last.x - _rectSpots.first.x).abs() / 3),
                              getTitlesWidget: (value, meta) => SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  value.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        minX: _rectSpots.map((spot) => spot.x).reduce(min) - 1,
                        maxX: _rectSpots.map((spot) => spot.x).reduce(max) + 1,
                        minY: _rectSpots.map((spot) => spot.y).reduce(min) - 1,
                        maxY: _rectSpots.map((spot) => spot.y).reduce(max) + 1,
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
                  'Caution: The plot caps at a magnitude of 1000. Points beyond are scaled down.',
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
