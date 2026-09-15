import 'package:flutter/material.dart';
import 'theme/droniva_theme.dart';
import 'screens/cadence_studio_screen.dart';

void main() {
  runApp(const DronivaApp());
}

class DronivaApp extends StatelessWidget {
  const DronivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Droniva Cadence',
      debugShowCheckedModeBanner: false,
      theme: DronivaTheme.themeData,
      home: const CadenceStudioScreen(),
    );
  }
}
