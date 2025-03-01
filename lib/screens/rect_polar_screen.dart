import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  List<FlSpot> _rectSpots = [];
  static const double _maxValueGraph = 1000.0; // Graph cap at 1000

  void _updateGraphFromRect(String real, String imag) {
    if (real.isEmpty || imag.isEmpty) {
      setState(() => _rectSpots = []);
      return;
    }
    try {
      double x = double.parse(real);
      double y = double.parse(imag);
      if (x.isNaN || y.isNaN || x.isInfinite || y.isInfinite) {
        setState(() => _rectSpots = []);
        return;
      }
      double graphX = x.abs() > _maxValueGraph ? (_maxValueGraph * x.sign) : x;
      double graphY = y.abs() > _maxValueGraph ? (_maxValueGraph * y.sign) : y;
      _rectSpots = [FlSpot(graphX, graphY)];
      setState(() {});
    } catch (e) {
      setState(() => _rectSpots = []);
    }
  }

  void _updateGraphFromPolar(String magnitude, String angle) {
    if (magnitude.isEmpty || angle.isEmpty) {
      setState(() => _rectSpots = []);
      return;
    }
    try {
      double r = double.parse(magnitude);
      double thetaDeg = double.parse(angle);
      if (r < 0 || r.isNaN || thetaDeg.isNaN || r.isInfinite || thetaDeg.isInfinite) {
        setState(() => _rectSpots = []);
        return;
      }
      double graphR = min(r, _maxValueGraph);
      double thetaRad = thetaDeg * pi / 180;
      double x = graphR * cos(thetaRad);
      double y = graphR * sin(thetaRad);
      _rectSpots = [FlSpot(x, y)];
      setState(() {});
    } catch (e) {
      setState(() => _rectSpots = []);
    }
  }

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
                      ),
                      onChanged: (value) {
                        setState(() {
                          _polarResult = Conversions.rectToPolar(_realController.text, _imagController.text);
                          _magController.clear();
                          _angleController.clear();
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
                      ),
                      onChanged: (value) {
                        setState(() {
                          _polarResult = Conversions.rectToPolar(_realController.text, _imagController.text);
                          _magController.clear();
                          _angleController.clear();
                          _updateGraphFromRect(_realController.text, _imagController.text);
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
                      ),
                      onChanged: (value) {
                        setState(() {
                          _rectResult = Conversions.polarToRect(_magController.text, _angleController.text);
                          _realController.clear();
                          _imagController.clear();
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
                      ),
                      onChanged: (value) {
                        setState(() {
                          _rectResult = Conversions.polarToRect(_magController.text, _angleController.text);
                          _realController.clear();
                          _imagController.clear();
                          _updateGraphFromPolar(_magController.text, _angleController.text);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Result: $_rectResult', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_rectSpots.isNotEmpty) ...[
              SizedBox(
                height: 250,
                child: ScatterChart(
                  ScatterChartData(
                    scatterSpots: _rectSpots
                        .map((spot) => ScatterSpot(
                              spot.x,
                              spot.y,
                              dotPainter: FlDotCirclePainter(
                                radius: 8,
                                color: Theme.of(context).colorScheme.primary,
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
