import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/conversions.dart';
import '../utils/cache_manager.dart';
import 'tutorial_page.dart';

class DbmWattsScreen extends StatefulWidget {
  const DbmWattsScreen({super.key});

  @override
  _DbmWattsScreenState createState() => _DbmWattsScreenState();
}

class _DbmWattsScreenState extends State<DbmWattsScreen> with SingleTickerProviderStateMixin {
  String _wattsResult = '';
  String _dbmResult = '';
  final TextEditingController _dbmController = TextEditingController();
  final TextEditingController _wattsController = TextEditingController();
  List<FlSpot> _dbmWattsSpots = [];
  static const double _maxDbmGraph = 100.0;
  static const double _maxWattsGraph = 10000.0;
  String _dbmUnit = 'dBm';
  String _wattsUnit = 'W';
  String? _prevDbmValue;
  String? _prevWattsValue;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showDbmFormula = false;
  bool _showWattsFormula = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _loadCache();
    _checkFirstRun();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dbmController.dispose();
    _wattsController.dispose();
    _overlayEntry?.remove();
    super.dispose();
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

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('firstRunDbmWatts') ?? true;
    if (isFirstRun && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFirstRunOverlay();
        prefs.setBool('firstRunDbmWatts', false);
      });
    }
  }

  void _showFirstRunOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome to RF Calculator!',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Convert dBm to Watts and more. Tap "?" for a tutorial!',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                    },
                    child: const Text('Got It'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateFromDbm(String dbm) {
    if (dbm.isEmpty) {
      setState(() {
        _wattsResult = '';
        _dbmWattsSpots = [];
      });
      _animationController.reverse();
      return;
    }
    try {
      double dbmValue = double.parse(dbm);
      if (dbmValue.isNaN || dbmValue.isInfinite) {
        setState(() {
          _wattsResult = '';
          _dbmWattsSpots = [];
        });
        _animationController.reverse();
        return;
      }
      double graphDbm = min(dbmValue, _maxDbmGraph);
      setState(() {
        _prevDbmValue = _dbmController.text;
        _wattsResult = Conversions.dbmToWatts(dbmValue.toString());
        _dbmWattsSpots = List.generate(11, (index) {
          double x = graphDbm - 5 + index;
          double y = pow(10, (x - 30) / 10).toDouble();
          return FlSpot(x, y);
        });
        CacheManager.saveCache(CacheManager.dbmKey, dbm);
        CacheManager.addToHistory('dBm to Watts: $dbm $_dbmUnit = $_wattsResult');
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() {
        _wattsResult = '';
        _dbmWattsSpots = [];
      });
      _animationController.reverse();
    }
  }

  void _updateFromWatts(String watts) {
    if (watts.isEmpty) {
      setState(() {
        _dbmResult = '';
        _dbmWattsSpots = [];
      });
      _animationController.reverse();
      return;
    }
    try {
      double wattsValue = double.parse(watts);
      if (_wattsUnit == 'mW') wattsValue /= 1000;
      if (wattsValue <= 0 || wattsValue.isNaN || wattsValue.isInfinite) {
        setState(() {
          _dbmResult = '';
          _dbmWattsSpots = [];
        });
        _animationController.reverse();
        return;
      }
      double graphWatts = min(wattsValue, _maxWattsGraph);
      setState(() {
        _prevWattsValue = _wattsController.text;
        _dbmResult = Conversions.wattsToDbm(wattsValue.toString());
        _dbmWattsSpots = List.generate(11, (index) {
          double y = graphWatts * (0.5 + index * 0.1);
          double x = 10 * log(y * 1000) / ln10;
          return FlSpot(x, y);
        });
        CacheManager.saveCache(CacheManager.wattsKey, watts);
        CacheManager.addToHistory('Watts to dBm: $watts $_wattsUnit = $_dbmResult');
      });
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() {
        _dbmResult = '';
        _dbmWattsSpots = [];
      });
      _animationController.reverse();
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

  void _applyDbmPreset(String preset) {
    setState(() {
      _dbmController.text = preset.split(': ')[1].replaceAll(' dBm', '');
      _wattsController.clear();
      _wattsResult = '';
      _updateFromDbm(_dbmController.text);
    });
  }

  void _applyWattsPreset(String preset) {
    final parts = preset.split(': ');
    final valueUnit = parts[1].split(' ');
    setState(() {
      _wattsController.text = valueUnit[0];
      _wattsUnit = valueUnit[1];
      _dbmController.clear();
      _dbmResult = '';
      _updateFromWatts(_wattsController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('dBm ↔ Watts Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TutorialPage()),
              );
            },
            tooltip: 'Tutorial',
          ),
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
                    DropdownButton<String>(
                      hint: const Text('Select Example'),
                      value: null,
                      items: [
                        'Wi-Fi: 20 dBm',
                        'Bluetooth: 0 dBm',
                        'High Power: 50 dBm',
                      ].map((preset) => DropdownMenuItem(value: preset, child: Text(preset))).toList(),
                      onChanged: (value) {
                        if (value != null) _applyDbmPreset(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'Result: $_wattsResult',
                              key: ValueKey(_wattsResult),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: _undoDbm,
                          tooltip: 'Undo',
                        ),
                        IconButton(
                          icon: Icon(_showDbmFormula ? Icons.close : Icons.functions),
                          onPressed: () {
                            setState(() {
                              _showDbmFormula = !_showDbmFormula;
                            });
                          },
                          tooltip: 'Show Formula',
                        ),
                      ],
                    ),
                    if (_showDbmFormula) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Formula: P(W) = 10^((P(dBm) - 30) / 10)',
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
                    DropdownButton<String>(
                      hint: const Text('Select Example'),
                      value: null,
                      items: [
                        'Wi-Fi: 0.1 W',
                        'Bluetooth: 1 mW',
                        'High Power: 100 W',
                      ].map((preset) => DropdownMenuItem(value: preset, child: Text(preset))).toList(),
                      onChanged: (value) {
                        if (value != null) _applyWattsPreset(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'Result: $_dbmResult',
                              key: ValueKey(_dbmResult),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo),
                          onPressed: _undoWatts,
                          tooltip: 'Undo',
                        ),
                        IconButton(
                          icon: Icon(_showWattsFormula ? Icons.close : Icons.functions),
                          onPressed: () {
                            setState(() {
                              _showWattsFormula = !_showWattsFormula;
                            });
                          },
                          tooltip: 'Show Formula',
                        ),
                      ],
                    ),
                    if (_showWattsFormula) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Formula: P(dBm) = 10 * log10(P(W) * 1000)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_dbmWattsSpots.isNotEmpty) ...[
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
