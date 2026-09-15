import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/cadence_manager.dart';
import '../../core/pacer_colors.dart';

class StrideCalcScreen extends StatefulWidget {
  const StrideCalcScreen({super.key});

  @override
  State<StrideCalcScreen> createState() => _StrideCalcScreenState();
}

class _StrideCalcScreenState extends State<StrideCalcScreen> {
  late double _heightCm;
  late double _paceMinKm;

  @override
  void initState() {
    super.initState();
    final manager = context.read<CadenceManager>();
    _heightCm = manager.runnerHeightCm;
    _paceMinKm = manager.runnerPaceMinPerKm;
  }

  String _formatPace(double pace) {
    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<CadenceManager>();

    // Calculate mechanics
    // Speed in m/s: 1000m / (paceMinKm * 60s)
    final speedMps = 1000.0 / (_paceMinKm * 60.0);
    // Speed in km/h
    final speedKmh = 60.0 / _paceMinKm;

    // Recommended target cadence
    final recommendedSPM = manager.recommendedCadence;
    // Optimal stride length = (speedMps * 60) / recommendedSPM
    final strideLengthMeters = (speedMps * 60.0) / recommendedSPM;
    final strideRatioToHeight = strideLengthMeters / (_heightCm / 100.0);

    // Overstride risk analysis
    final isOverstrideRisk = strideRatioToHeight > 0.85;
    final groundContactTimeMs = (280 - (recommendedSPM - 150) * 1.8).clamp(180, 300).round();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.straighten_rounded, color: DronivaColors.neonLime),
            SizedBox(width: 8),
            Text('Stride & Cadence Lab'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Runner Height Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: DronivaColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DronivaColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Runner Height',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DronivaColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DronivaColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_heightCm.round()} cm (${(_heightCm / 2.54 / 12).floor()}\'${(_heightCm / 2.54 % 12).round()}")',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: DronivaColors.neonCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _heightCm,
                    min: 140,
                    max: 210,
                    divisions: 70,
                    activeColor: DronivaColors.neonCyan,
                    inactiveColor: DronivaColors.surfaceElevated,
                    onChanged: (val) {
                      setState(() => _heightCm = val);
                      manager.setRunnerHeight(val);
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('140 cm', style: TextStyle(fontSize: 11, color: DronivaColors.textMuted)),
                      Text('175 cm', style: TextStyle(fontSize: 11, color: DronivaColors.textMuted)),
                      Text('210 cm', style: TextStyle(fontSize: 11, color: DronivaColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Target Training Pace Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: DronivaColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DronivaColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Current Training Pace',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DronivaColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: DronivaColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatPace(_paceMinKm),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: DronivaColors.neonLime,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _paceMinKm,
                    min: 3.5,
                    max: 8.0,
                    divisions: 45,
                    activeColor: DronivaColors.neonLime,
                    inactiveColor: DronivaColors.surfaceElevated,
                    onChanged: (val) {
                      setState(() => _paceMinKm = val);
                      manager.setRunnerPace(val);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('3:30 /km (Elite)', style: TextStyle(fontSize: 11, color: DronivaColors.textMuted)),
                      Text('${speedKmh.toStringAsFixed(1)} km/h',
                          style: const TextStyle(fontSize: 12, color: DronivaColors.neonLime, fontWeight: FontWeight.bold)),
                      const Text('8:00 /km (Easy)', style: TextStyle(fontSize: 11, color: DronivaColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Results Heading
            const Text(
              'BIOMECHANICAL TARGETS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: DronivaColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),

            // Stride and Cadence Computed Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DronivaColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: DronivaColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OPTIMAL STRIDE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: DronivaColors.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${strideLengthMeters.toStringAsFixed(2)} m',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: DronivaColors.neonCyan,
                          ),
                        ),
                        Text(
                          '${(strideRatioToHeight * 100).round()}% of height',
                          style: const TextStyle(
                            fontSize: 11,
                            color: DronivaColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DronivaColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: DronivaColors.neonLime.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TARGET CADENCE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: DronivaColors.neonLime,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$recommendedSPM SPM',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: DronivaColors.textPrimary,
                          ),
                        ),
                        const Text(
                          'Golden efficiency ratio',
                          style: TextStyle(
                            fontSize: 11,
                            color: DronivaColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Diagnostic indicators
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOverstrideRisk
                    ? DronivaColors.neonCoral.withValues(alpha: 0.1)
                    : DronivaColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOverstrideRisk ? DronivaColors.neonCoral : DronivaColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverstrideRisk ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                    color: isOverstrideRisk ? DronivaColors.neonCoral : DronivaColors.neonLime,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOverstrideRisk ? 'High Overstriding Risk' : 'Optimal Impact Mechanics',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isOverstrideRisk ? DronivaColors.neonCoral : DronivaColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOverstrideRisk
                              ? 'At this pace and cadence, your stride may be too long, causing braking friction and knee shock.'
                              : 'Estimated Ground Contact: ~${groundContactTimeMs}ms. Clean spring recovery.',
                          style: const TextStyle(fontSize: 12, color: DronivaColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: DronivaColors.neonLime,
                  side: const BorderSide(color: DronivaColors.neonLime, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  manager.setTargetBpm(recommendedSPM);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: DronivaColors.surfaceElevated,
                      content: Text(
                        'Target updated to $recommendedSPM SPM in Metronome Pacer!',
                        style: const TextStyle(color: DronivaColors.neonLime),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.sync_rounded),
                label: Text('APPLY $recommendedSPM SPM TO METRONOME'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
