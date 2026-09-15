import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/cadence_manager.dart';
import '../../core/pacer_colors.dart';

class PacerScreen extends StatefulWidget {
  const PacerScreen({super.key});

  @override
  State<PacerScreen> createState() => _PacerScreenState();
}

class _PacerScreenState extends State<PacerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 333), // ~180 bpm default
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _updateAnimationDuration(int bpm) {
    final ms = (60000 / bpm / 2).round();
    _pulseController.duration = Duration(milliseconds: ms);
    if (_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<CadenceManager>();
    _updateAnimationDuration(manager.targetBpm);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.directions_run_rounded, color: DronivaColors.neonLime),
            SizedBox(width: 8),
            Text('Cadence Pacer'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: DronivaColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DronivaColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: manager.isPlaying
                        ? DronivaColors.neonLime
                        : DronivaColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  manager.isPlaying ? 'ACTIVE' : 'IDLE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: manager.isPlaying
                        ? DronivaColors.neonLime
                        : DronivaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Status bar info
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'TIME',
                    value: _formatDuration(manager.activeSeconds),
                    icon: Icons.timer_outlined,
                    color: DronivaColors.neonCyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'STEPS',
                    value: '${manager.activeSteps}',
                    icon: Icons.speed_rounded,
                    color: DronivaColors.neonLime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Animated Cadence Visualizer Dial
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = manager.isPlaying ? _pulseAnimation.value : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DronivaColors.surface,
                        border: Border.all(
                          color: manager.isPlaying
                              ? DronivaColors.neonLime
                              : DronivaColors.border,
                          width: manager.isPlaying ? 3 : 1.5,
                        ),
                        boxShadow: manager.isPlaying
                            ? [
                                BoxShadow(
                                  color: DronivaColors.neonLime.withValues(alpha: 0.25),
                                  blurRadius: 36,
                                  spreadRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 4-beat rhythm indicators
                          ...List.generate(4, (index) {
                            final angle = (index * 90) * (math.pi / 180);
                            final isActiveBeat =
                                manager.isPlaying && manager.currentBeat == index;
                            return Transform.translate(
                              offset: Offset(80 * math.cos(angle), 80 * math.sin(angle)),
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActiveBeat
                                      ? DronivaColors.neonCyan
                                      : DronivaColors.surfaceElevated,
                                  border: Border.all(
                                    color: isActiveBeat
                                        ? Colors.white
                                        : DronivaColors.border,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            );
                          }),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${manager.targetBpm}',
                                style: const TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.w900,
                                  color: DronivaColors.textPrimary,
                                  letterSpacing: -2,
                                ),
                              ),
                              const Text(
                                'STEPS / MIN',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: DronivaColors.neonLime,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getCadenceZone(manager.targetBpm),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: DronivaColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // BPM Slider Dial Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: DronivaColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DronivaColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () {
                          if (manager.targetBpm > 150) {
                            manager.setTargetBpm(manager.targetBpm - 2);
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        'Adjust Target Cadence',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DronivaColors.textSecondary,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          if (manager.targetBpm < 200) {
                            manager.setTargetBpm(manager.targetBpm + 2);
                          }
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  Slider(
                    value: manager.targetBpm.toDouble(),
                    min: 150,
                    max: 200,
                    divisions: 50,
                    activeColor: DronivaColors.neonLime,
                    inactiveColor: DronivaColors.surfaceElevated,
                    onChanged: (val) => manager.setTargetBpm(val.round()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('150 SPM (Jog)', style: TextStyle(fontSize: 11, color: DronivaColors.textMuted)),
                      Text('180 SPM (Gold)', style: TextStyle(fontSize: 11, color: DronivaColors.neonLime)),
                      Text('200 SPM (Sprint)', style: TextStyle(fontSize: 11, color: DronivaColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Preset Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildPresetChip(context, manager, 160, 'Easy Recovery'),
                _buildPresetChip(context, manager, 172, 'Endurance'),
                _buildPresetChip(context, manager, 180, 'Optimal 180'),
                _buildPresetChip(context, manager, 188, 'Tempo Pace'),
                _buildPresetChip(context, manager, 196, 'Sprint Drill'),
              ],
            ),
            const SizedBox(height: 28),

            // Main Play / Stop Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: manager.isPlaying
                      ? DronivaColors.neonCoral
                      : DronivaColors.neonLime,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                onPressed: () => manager.togglePacing(),
                icon: Icon(
                  manager.isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 28,
                ),
                label: Text(
                  manager.isPlaying ? 'STOP PACER & SAVE' : 'START CADENCE PACER',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(
    BuildContext context,
    CadenceManager manager,
    int bpm,
    String label,
  ) {
    final isSelected = manager.targetBpm == bpm;
    return ChoiceChip(
      label: Text('$bpm • $label'),
      selected: isSelected,
      selectedColor: DronivaColors.neonLime,
      backgroundColor: DronivaColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : DronivaColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? DronivaColors.neonLime : DronivaColors.border,
      ),
      onSelected: (_) => manager.setTargetBpm(bpm),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DronivaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DronivaColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: DronivaColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: DronivaColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCadenceZone(int bpm) {
    if (bpm < 165) return 'Zone 1: Aerobic Recovery';
    if (bpm < 175) return 'Zone 2: Steady Distance';
    if (bpm <= 185) return 'Zone 3: Optimal Efficiency';
    return 'Zone 4: Fast Intervals';
  }
}
