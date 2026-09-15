import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/cadence_manager.dart';
import '../../core/pacer_colors.dart';

class RunHistoryScreen extends StatelessWidget {
  const RunHistoryScreen({super.key});

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final remM = m % 60;
      return '${h}h ${remM}m';
    }
    return '${m}m ${s}s';
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $hour:$minute';
  }

  void _showAddSessionDialog(BuildContext context) {
    final manager = context.read<CadenceManager>();
    final minutesController = TextEditingController(text: '20');
    final bpmController = TextEditingController(text: '${manager.targetBpm}');
    final notesController = TextEditingController(text: 'Outdoor tempo pace drill');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: DronivaColors.surface,
          title: const Text('Log Cadence Session', style: TextStyle(color: DronivaColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (Minutes)',
                    labelStyle: TextStyle(color: DronivaColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: DronivaColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bpmController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cadence (SPM)',
                    labelStyle: TextStyle(color: DronivaColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: DronivaColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Session Notes',
                    labelStyle: TextStyle(color: DronivaColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: DronivaColors.border),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: DronivaColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DronivaColors.neonLime,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final mins = int.tryParse(minutesController.text.trim()) ?? 15;
                final bpm = int.tryParse(bpmController.text.trim()) ?? 180;
                final durSec = mins * 60;
                final totalSteps = ((durSec / 60) * bpm).round();

                final session = RunCadenceSession(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  timestamp: DateTime.now(),
                  durationSeconds: durSec,
                  targetBpm: bpm,
                  totalSteps: totalSteps,
                  note: notesController.text.trim(),
                );

                manager.addCustomSession(session);
                Navigator.pop(ctx);
              },
              child: const Text('Save Log'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<CadenceManager>();
    final sessions = manager.sessions;

    final totalSeconds = sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    final totalSteps = sessions.fold<int>(0, (sum, s) => sum + s.totalSteps);
    final avgBpm = sessions.isEmpty
        ? 0
        : (sessions.fold<int>(0, (sum, s) => sum + s.targetBpm) / sessions.length).round();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.history_rounded, color: DronivaColors.neonLime),
            SizedBox(width: 8),
            Text('Session Logs'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddSessionDialog(context),
            icon: const Icon(Icons.add_circle_outline_rounded, color: DronivaColors.neonLime),
            tooltip: 'Log Manual Run',
          ),
        ],
      ),
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_run_rounded, size: 64, color: DronivaColors.textMuted),
                  const SizedBox(height: 16),
                  const Text(
                    'No cadence sessions recorded yet',
                    style: TextStyle(fontSize: 16, color: DronivaColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddSessionDialog(context),
                    icon: const Icon(Icons.add, color: DronivaColors.neonLime),
                    label: const Text('Add your first session log', style: TextStyle(color: DronivaColors.neonLime)),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Summary cards row
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryBox(
                        title: 'TOTAL TIME',
                        value: _formatDuration(totalSeconds),
                        color: DronivaColors.neonCyan,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryBox(
                        title: 'TOTAL STEPS',
                        value: '$totalSteps',
                        color: DronivaColors.neonLime,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryBox(
                        title: 'AVG CADENCE',
                        value: avgBpm > 0 ? '$avgBpm SPM' : '--',
                        color: DronivaColors.neonAmber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'RECENT DRILLS & RUNS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: DronivaColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                ...sessions.map((s) => _buildSessionTile(context, s, manager)),
              ],
            ),
    );
  }

  Widget _buildSummaryBox({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: DronivaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DronivaColors.border),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: DronivaColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(
    BuildContext context,
    RunCadenceSession session,
    CadenceManager manager,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: DronivaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DronivaColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: DronivaColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DronivaColors.neonLime.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${session.targetBpm}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: DronivaColors.neonLime,
                ),
              ),
              const Text(
                'SPM',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: DronivaColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          session.note.isNotEmpty ? session.note : 'Cadence Drill',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: DronivaColors.textPrimary,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: DronivaColors.textMuted),
                const SizedBox(width: 4),
                Text(_formatDuration(session.durationSeconds),
                    style: const TextStyle(fontSize: 12, color: DronivaColors.textSecondary)),
                const SizedBox(width: 12),
                const Icon(Icons.pin_drop_outlined, size: 14, color: DronivaColors.textMuted),
                const SizedBox(width: 4),
                Text('${session.totalSteps} steps',
                    style: const TextStyle(fontSize: 12, color: DronivaColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(session.timestamp),
              style: const TextStyle(fontSize: 11, color: DronivaColors.textMuted),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: DronivaColors.textMuted),
          onPressed: () {
            manager.deleteSession(session.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session log removed'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}
