import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/cadence_manager.dart';
import 'core/pacer_colors.dart';
import 'features/guides/cadence_guides_screen.dart';
import 'features/history/run_history_screen.dart';
import 'features/metronome/pacer_screen.dart';
import 'features/stride/stride_calc_screen.dart';

class DronivaCadenceApp extends StatelessWidget {
  const DronivaCadenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CadenceManager>(
      create: (_) => CadenceManager(),
      child: MaterialApp(
        title: 'Droniva Cadence Pacer',
        debugShowCheckedModeBanner: false,
        theme: DronivaColors.themeData(),
        home: const _DronivaMainShell(),
      ),
    );
  }
}

class _DronivaMainShell extends StatefulWidget {
  const _DronivaMainShell();

  @override
  State<_DronivaMainShell> createState() => _DronivaMainShellState();
}

class _DronivaMainShellState extends State<_DronivaMainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PacerScreen(),
    StrideCalcScreen(),
    RunHistoryScreen(),
    CadenceGuidesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer_rounded),
            label: 'Pacer',
          ),
          NavigationDestination(
            icon: Icon(Icons.straighten_outlined),
            selectedIcon: Icon(Icons.straighten_rounded),
            label: 'Stride Lab',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Logs',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Science',
          ),
        ],
      ),
    );
  }
}
