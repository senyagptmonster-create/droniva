import 'package:flutter/material.dart';
import '../app/brand.dart';
import '../app/theme.dart';

class DronivaMainScreen extends StatefulWidget {
  const DronivaMainScreen({super.key});
  @override
  State<DronivaMainScreen> createState() => _DronivaMainScreenState();
}

class _DronivaMainScreenState extends State<DronivaMainScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Droniva', style: AppTheme.display(cInk))),
      body: PageView(
        controller: _controller,
        children: const [
          MetronomePacerScreen(),
          StrideCalculatorScreen(),
          RunHistoryScreen(),
          TargetCadenceScreen(),
        ],
      ),
    );
  }
}

class MetronomePacerScreen extends StatelessWidget {
  const MetronomePacerScreen({super.key});
  @override
  Widget build(BuildContext context) { return Center(child: Text('Metronome Pacer', style: AppTheme.text(cInk))); }
}
class StrideCalculatorScreen extends StatelessWidget {
  const StrideCalculatorScreen({super.key});
  @override
  Widget build(BuildContext context) { return Center(child: Text('Stride Calculator', style: AppTheme.text(cInk))); }
}
class RunHistoryScreen extends StatelessWidget {
  const RunHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) { return Center(child: Text('Run History', style: AppTheme.text(cInk))); }
}
class TargetCadenceScreen extends StatelessWidget {
  const TargetCadenceScreen({super.key});
  @override
  Widget build(BuildContext context) { return Center(child: Text('Target Cadence', style: AppTheme.text(cInk))); }
}
