import 'package:flutter/material.dart';
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
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text('Result: $_dbmResult', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
