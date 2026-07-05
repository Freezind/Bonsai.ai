import 'package:flutter/material.dart';

void main() {
  runApp(const BonsaiApp());
}

/// Root widget. Replaced with router + prefs boot in later phases.
class BonsaiApp extends StatelessWidget {
  const BonsaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Bonsai',
      home: Scaffold(body: Center(child: Text('Bonsai'))),
    );
  }
}
