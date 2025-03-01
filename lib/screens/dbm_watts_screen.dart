import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/conversions.dart';

class DbmWattsScreen extends StatefulWidget {
  const DbmWattsScreen({super.key});

  @override
  _DbmWattsScreenState createState() => _DbmWattsScreenState();
}

class _DbmWattsScreenState extends State<DbmWattsScreen> {
  String _wattsResult = '';
  String _dbmResult = '';
  final TextEditingController _dbmController = TextEditingController();
  final TextEditingController _wattsController = TextEditingController();
  List<FlSpot> _dbmWattsSpots = [];
  static const double _maxDbmGraph = 100.0; // Graph cap at 100 dBm
  static const double _maxWattsGraph = 10000.0; // Graph cap at 10 kW

  void _updateGraphFromDbm(String dbm) {
    if (dbm.isEmpty) {
      setState(() => _dbmWattsSpots = []);
      return;
    }
    try {
      double dbmValue = double.parse(dbm);
      if (dbmValue.isNaN || dbmValue.isInfinite) {
        setState(() => _dbmWattsSpots = []);
        return;
      }
      double graphDbm = min(dbmValue, _maxDbmGraph);
      _dbmWattsSpots = List.generate(11, (index) {
        double x = graphDbm - 5 + index;
        double y = pow(10, (x - 30) / 10).toDouble();
        return FlSpot(x, y);
      });
      setState(() {});
    } catch (e) {
      setState(() => _dbmWattsSpots = []);
    }
  }

  void _updateGraphFromWatts(String watts) {
    if (watts.isEmpty) {
      setState(() => _dbmWattsSpots = []);
      return;
    }
    try {
      double wattsValue = double.parse(watts);
      if (wattsValue <= 0 || wattsValue.isNaN || wattsValue.isInfinite) {
        setState(() => _dbmWattsSpots = []);
        return;
      }
      double graphWatts = min(wattsValue, _maxWattsGraph);
      _dbmWattsSpots = List.generate(11, (index) {
        double y = graphWatts * (0.5 + index * 0.1);
        double x = 10 * log(y * 1000) / ln10;
        return FlSpot(x, y);
      });
      setState(() {});
    } catch (e) {
      setState(() => _dbmWattsSpots = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('dBm ↔ Watts Converter'),
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
                      'dBm to Watts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Converts power from decibel-milliwatts (dBm) to watts (W). This logarithmic scale measures power relative to 1 milliwatt, where 0 dBm equals 0.001 W.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dbmController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter dBm',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _wattsResult = Conversions.dbmToWatts(value);
                          _wattsController.clear();
                          _updateGraphFromDbm(value);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Result: $_wattsResult', style: Theme.of(context).textTheme.bodyLarge),
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
                      'Watts to dBm',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transforms power in watts (W) to decibel-milliwatts (dBm). It expresses power on a logarithmic scale, making large ranges easier to compare.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _wattsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Watts',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _dbmResult = Conversions.wattsToDbm(value);
                          _dbmController.clear();
                          _updateGraphFromWatts(value);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Result: $_dbmResult', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_dbmWattsSpots.isNotEmpty) ...[
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
                          interval: max(1.0, (_dbmWattsSpots.last.y - _dbmWattsSpots.first.y) / 3),
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
                          interval: max(1.0, (_dbmWattsSpots.last.x - _dbmWattsSpots.first.x) / 3),
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
                    minX: _dbmWattsSpots.first.x,
                    maxX: _dbmWattsSpots.last.x,
                    minY: _dbmWattsSpots.first.y,
                    maxY: _dbmWattsSpots.last.y,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _dbmWattsSpots,
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
                  'Note: The graph whispers its limits at 100 dBm or 10,000 W. Beyond these horizons, it paints a gentle, generic curve of power’s dance.',
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
