import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/droniva_theme.dart';
import '../painters/cadence_pulse_painter.dart';

class CadenceStudioScreen extends StatefulWidget {
  const CadenceStudioScreen({super.key});

  @override
  State<CadenceStudioScreen> createState() => _CadenceStudioScreenState();
}

class _CadenceStudioScreenState extends State<CadenceStudioScreen>
    with SingleTickerProviderStateMixin {
  int _bpm = 180;
  bool _isRunning = false;
  Timer? _tickerTimer;
  bool _beatFlash = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (60000 / _bpm).round()),
    );
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _togglePacer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimer();
      } else {
        _tickerTimer?.cancel();
        _animController.stop();
        _beatFlash = false;
      }
    });
  }

  void _startTimer() {
    _tickerTimer?.cancel();
    final intervalMs = (60000 / _bpm).round();
    _animController.duration = Duration(milliseconds: intervalMs);
    _animController.repeat();

    _tickerTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (mounted) {
        setState(() => _beatFlash = true);
        Future.delayed(const Duration(milliseconds: 90), () {
          if (mounted) setState(() => _beatFlash = false);
        });
      }
    });
  }

  void _setBpm(int newBpm) {
    setState(() {
      _bpm = newBpm.clamp(130, 210);
      if (_isRunning) {
        _startTimer();
      }
    });
  }

  void _showStrideCalculatorSheet() {
    double runnerHeightCm = 175;
    showModalBottomSheet(
      context: context,
      backgroundColor: DronivaTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final estimatedStrideM = (runnerHeightCm * 0.415) / 100;
          final speedKmh = (_bpm * estimatedStrideM * 60) / 1000;
          final paceMinKm = speedKmh > 0 ? (60 / speedKmh) : 0;
          final paceMinutes = paceMinKm.floor();
          final paceSeconds = ((paceMinKm - paceMinutes) * 60).round();

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stride & Pace Estimator',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Text('Runner Height: ${runnerHeightCm.round()} cm'),
                Slider(
                  value: runnerHeightCm,
                  min: 140,
                  max: 210,
                  activeColor: DronivaTheme.accent,
                  onChanged: (val) => setSheetState(() => runnerHeightCm = val),
                ),
                const Divider(color: DronivaTheme.edge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated Stride:'),
                    Text('${estimatedStrideM.toStringAsFixed(2)} m',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Target Pace:'),
                    Text('$paceMinutes:${paceSeconds.toString().padLeft(2, '0')} min/km',
                        style: const TextStyle(
                            color: DronivaTheme.accent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DronivaTheme.accent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Apply Target Cadence'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showIntervalSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: DronivaTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cadence Interval Workouts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _intervalCard('Base Aerobic Pacing', '165 SPM • 25 minutes', () {
              _setBpm(165);
              Navigator.pop(ctx);
            }),
            _intervalCard('Optimal Cadence Drill', '180 SPM • 15 minutes', () {
              _setBpm(180);
              Navigator.pop(ctx);
            }),
            _intervalCard('Speed Sprint Bursts', '195 SPM • 40s x 6 reps', () {
              _setBpm(195);
              Navigator.pop(ctx);
            }),
          ],
        ),
      ),
    );
  }

  Widget _intervalCard(String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: DronivaTheme.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DronivaTheme.edge),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: DronivaTheme.muted, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: DronivaTheme.accent),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DRONIVA PACER', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Beat indicator badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _beatFlash ? DronivaTheme.accent : DronivaTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DronivaTheme.accent.withValues(alpha: 0.5)),
              ),
              child: Text(
                _isRunning ? 'BEAT ACTIVE' : 'PACER IDLE',
                style: TextStyle(
                  color: _beatFlash ? Colors.black : DronivaTheme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Spacer(),
            // Central pulsating dial
            Center(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: CadencePulsePainter(
                      animationValue: _animController.value,
                      isRunning: _isRunning,
                      bpm: _bpm,
                    ),
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_bpm',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: DronivaTheme.ink,
                              letterSpacing: -1,
                            ),
                          ),
                          const Text(
                            'STEPS / MIN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: DronivaTheme.accent,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            // BPM Step Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filledTonal(
                    onPressed: () => _setBpm(_bpm - 5),
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(backgroundColor: DronivaTheme.surface),
                  ),
                  Slider(
                    value: _bpm.toDouble(),
                    min: 140,
                    max: 210,
                    activeColor: DronivaTheme.accent,
                    inactiveColor: DronivaTheme.edge,
                    onChanged: (val) => _setBpm(val.round()),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _setBpm(_bpm + 5),
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(backgroundColor: DronivaTheme.surface),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Play / Pause Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? Colors.redAccent : DronivaTheme.accent,
                    foregroundColor: _isRunning ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _togglePacer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(
                    _isRunning ? 'HALT METRONOME' : 'ENGAGE RUNNER CADENCE',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Bottom Action Sheets Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: const BoxDecoration(
                color: DronivaTheme.surface,
                border: Border(top: BorderSide(color: DronivaTheme.edge)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: _showStrideCalculatorSheet,
                    icon: const Icon(Icons.straighten, color: DronivaTheme.accentLight, size: 18),
                    label: const Text('Stride Calc', style: TextStyle(color: DronivaTheme.ink)),
                  ),
                  TextButton.icon(
                    onPressed: _showIntervalSheet,
                    icon: const Icon(Icons.timer_outlined, color: DronivaTheme.accentLight, size: 18),
                    label: const Text('Intervals', style: TextStyle(color: DronivaTheme.ink)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
