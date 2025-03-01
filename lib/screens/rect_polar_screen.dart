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
        _updateGraphFromRect(realCached, imagCached);
      });
    }
    if (magCached != null && angleCached != null) {
      setState(() {
        _magController.text = magCached;
        _angleController.text = angleCached;
        _rectResult = Conversions.polarToRect(magCached, angleCached);
        _updateGraphFromPolar(magCached, angleCached);
      });
    }
  }

  void _updateGraphFromRect(String real, String imag) {
    if (real.isEmpty || imag.isEmpty) {
      setState(() => _rectSpots = []);
      _animationController.reverse();
      return;
    }
    try {
      double x = double.parse(real);
      double y = double.parse(imag);
      if (x.isNaN || y.isNaN || x.isInfinite || y.isInfinite) {
        setState(() => _rectSpots = []);
        _animationController.reverse();
        return;
      }
      double graphX = x.abs() > _maxValueGraph ? (_maxValueGraph * x.sign) : x;
      double graphY = y.abs() > _maxValueGraph ? (_maxValueGraph * y.sign) : y;
      setState(() {
        _prevRealValue = real;
        _prevImagValue = imag;
        _rectSpots = [FlSpot(graphX, graphY)];
        CacheManager.saveCache(CacheManager.realKey, real);
        CacheManager.saveCache(CacheManager.imagKey, imag);
        CacheManager.addToHistory('Rect to Polar: ($real, $imag) = $_polarResult');
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() => _rectSpots = []);
      _animationController.reverse();
    }
  }

  void _updateGraphFromPolar(String magnitude, String angle) {
    if (magnitude.isEmpty || angle.isEmpty) {
      setState(() => _rectSpots = []);
      _animationController.reverse();
      return;
    }
    try {
      double r = double.parse(magnitude);
      double thetaDeg = double.parse(angle);
      if (r < 0 || r.isNaN || thetaDeg.isNaN || r.isInfinite || thetaDeg.isInfinite) {
        setState(() => _rectSpots = []);
        _animationController.reverse();
        return;
      }
      double graphR = min(r, _maxValueGraph);
      double thetaRad = thetaDeg * pi / 180;
      double x = graphR * cos(thetaRad);
      double y = graphR * sin(thetaRad);
      setState(() {
        _prevMagValue = magnitude;
        _prevAngleValue = angle;
        _rectSpots = [FlSpot(x, y)];
        CacheManager.saveCache(CacheManager.magKey, magnitude);
        CacheManager.saveCache(CacheManager.angleKey, angle);
        CacheManager.addToHistory('Polar to Rect: ($magnitude, $angle°) = $_rectResult');
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() => _rectSpots = []);
      _animationController.reverse();
    }
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
        _updateGraphFromRect(_prevRealValue!, _prevImagValue!);
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
        _updateGraphFromPolar(_prevMagValue!, _prevAngleValue!);
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
                      'Shifts from rectangular (real, imaginary) to polar (magnitude, angle) form. It unveils the length and direction of a complex number’s journey.',
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
                              _rectSpots = [];
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _magController.clear();
                          _angleController.clear();
                          _rectResult = '';
                          _polarResult = Conversions.rectToPolar(_realController.text, _imagController.text);
                          _updateGraphFromRect(_realController.text, _imagController.text);
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
                              _rectSpots = [];
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _magController.clear();
                          _angleController.clear();
                          _rectResult = '';
                          _polarResult = Conversions.rectToPolar(_realController.text, _imagController.text);
                          _updateGraphFromRect(_realController.text, _imagController.text);
                        });
                      },
                    ),
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
                      'Maps polar (magnitude, angle) to rectangular (real, imaginary) coordinates. It traces the path of magnitude and angle back to the Cartesian plane.',
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
                              _rectSpots = [];
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _realController.clear();
                          _imagController.clear();
                          _polarResult = '';
                          _rectResult = Conversions.polarToRect(_magController.text, _angleController.text);
                          _updateGraphFromPolar(_magController.text, _angleController.text);
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
                              _rectSpots = [];
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _realController.clear();
                          _imagController.clear();
                          _polarResult = '';
                          _rectResult = Conversions.polarToRect(_magController.text, _angleController.text);
                          _updateGraphFromPolar(_magController.text, _angleController.text);
                        });
                      },
                    ),
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
                        minX: _rectSpots.first.x - 1,
                        maxX: _rectSpots.last.x + 1,
                        minY: _rectSpots.first.y - 1,
                        maxY: _rectSpots.last.y + 1,
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
                  'Caution: The plot pauses at a magnitude of 1000. Venture beyond, and it offers a modest echo of coordinates in tranquil bounds.',
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
