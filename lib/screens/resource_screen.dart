import 'package:flutter/material.dart';

class ResourceScreen extends StatelessWidget {
  const ResourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
      ),
      body: const Center(
        child: Text(
          'Work in progress',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
