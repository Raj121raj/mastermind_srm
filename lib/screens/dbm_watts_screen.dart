import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/conversions.dart';
import '../utils/cache_manager.dart';

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
  static const double _maxDbmGraph = 100.0;
  static const double _maxWattsGraph = 10000.0;
  String _dbmUnit = 'dBm'; // Fixed unit
  String _wattsUnit = 'W'; // Default unit
  String? _prevDbmValue; // Store previous dBm input
  String? _prevWattsValue; // Store previous Watts input

  @override
  void initState() {
    super.initState();
    _loadCache();
  }

  Future<void> _loadCache() async {
    final dbmCached = await CacheManager.loadCache(CacheManager.dbmKey);
    final wattsCached = await CacheManager.loadCache(CacheManager.wattsKey);
    if (dbmCached != null) {
      setState(() {
        _dbmController.text = dbmCached;
        _updateFromDbm(dbmCached);
      });
    }
    if (wattsCached != null) {
      setState(() {
        _wattsController.text = wattsCached;
        _updateFromWatts(wattsCached);
      });
    }
  }

  void _updateFromDbm(String dbm) {
    if (dbm.isEmpty) {
      setState(() {
        _wattsResult = '';
        _dbmWattsSpots = [];
      });
      return;
    }
    try {
      double dbmValue = double.parse(dbm); // Only dBm unit allowed
      if (dbmValue.isNaN || dbmValue.isInfinite) {
        setState(() {
          _wattsResult = '';
          _dbmWattsSpots = [];
        });
        return;
      }
      double graphDbm = min(dbmValue, _maxDbmGraph);
      setState(() {
        _prevDbmValue = _dbmController.text; // Store previous value
        _wattsResult = Conversions.dbmToWatts(dbmValue.toString());
        _dbmWattsSpots = List.generate(11, (index) {
          double x = graphDbm - 5 + index;
          double y = pow(10, (x - 30) / 10).toDouble();
          return FlSpot(x, y);
        });
        CacheManager.saveCache(CacheManager.dbmKey, dbm);
        CacheManager.addToHistory('dBm to Watts: $dbm $_dbmUnit = $_wattsResult');
      });
    } catch (e) {
      setState(() {
        _wattsResult = '';
        _dbmWattsSpots = [];
      });
    }
  }

  void _updateFromWatts(String watts) {
    if (watts.isEmpty) {
      setState(() {
        _dbmResult = '';
        _dbmWattsSpots = [];
      });
      return;
    }
    try {
      double wattsValue = double.parse(watts);
      if (_wattsUnit == 'mW') wattsValue /= 1000; // Convert mW to W
      if (wattsValue <= 0 || wattsValue.isNaN || wattsValue.isInfinite) {
        setState(() {
          _dbmResult = '';
          _dbmWattsSpots = [];
        });
        return;
      }
      double graphWatts = min(wattsValue, _maxWattsGraph);
      setState(() {
        _prevWattsValue = _wattsController.text; // Store previous value
        _dbmResult = Conversions.wattsToDbm(wattsValue.toString());
        _dbmWattsSpots = List.generate(11, (index) {
          double y = graphWatts * (0.5 + index * 0.1);
          double x = 10 * log(y * 1000) / ln10;
          return FlSpot(x, y);
        });
        CacheManager.saveCache(CacheManager.wattsKey, watts);
        CacheManager.addToHistory('Watts to dBm: $watts $_wattsUnit = $_dbmResult');
      });
    } catch (e) {
      setState(() {
        _dbmResult = '';
        _dbmWattsSpots = [];
      });
    }
  }

  void _undoDbm() {
    if (_prevDbmValue != null) {
      setState(() {
        _dbmController.text = _prevDbmValue!;
        _wattsController.clear();
        _wattsResult = '';
        _updateFromDbm(_prevDbmValue!);
      });
    }
  }

  void _undoWatts() {
    if (_prevWattsValue != null) {
      setState(() {
        _wattsController.text = _prevWattsValue!;
        _dbmController.clear();
        _dbmResult = '';
        _updateFromWatts(_prevWattsValue!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('dBm ↔ Watts Converter'),
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
                        labelText: 'Enter Power (dBm)',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _dbmController.clear();
                              _wattsController.clear();
                              _wattsResult = '';
                              _dbmResult = '';
                              _dbmWattsSpots = [];
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _wattsController.clear();
                          _wattsResult = '';
                          _updateFromDbm(value);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Result: $_wattsResult', style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: _undoDbm,
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
                      'Watts to dBm',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transforms power in watts (W) to decibel-milliwatts (dBm). It expresses power on a logarithmic scale, making large ranges easier to compare.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _wattsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Enter Power',
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceVariant,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _wattsController.clear();
                                    _dbmController.clear();
                                    _dbmResult = '';
                                    _wattsResult = '';
                                    _dbmWattsSpots = [];
                                  });
                                },
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _dbmController.clear();
                                _dbmResult = '';
                                _updateFromWatts(value);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _wattsUnit,
                          items: ['W', 'mW']
                              .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _wattsUnit = value!;
                              _dbmController.clear();
                              _dbmResult = '';
                              if (_wattsController.text.isNotEmpty) {
                                _updateFromWatts(_wattsController.text);
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
                          child: Text('Result: $_dbmResult', style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: _undoWatts,
                          tooltip: 'Undo',
                        ),
                      ],
                    ),
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
