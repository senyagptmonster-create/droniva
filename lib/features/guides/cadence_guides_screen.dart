import 'package:flutter/material.dart';
import '../../core/pacer_colors.dart';

class CadenceGuidesScreen extends StatefulWidget {
  const CadenceGuidesScreen({super.key});

  @override
  State<CadenceGuidesScreen> createState() => _CadenceGuidesScreenState();
}

class _CadenceGuidesScreenState extends State<CadenceGuidesScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ['All Guides', 'Biomechanics', 'Injury Prevention', 'Drills'];

  // Interactive Quiz State
  int _quizStep = 0;
  int _quizScore = 0;
  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'question': 'Do your shins or knees ache after downhill or tempo runs?',
      'options': [
        {'text': 'Rarely or never', 'points': 2},
        {'text': 'Sometimes after long runs', 'points': 1},
        {'text': 'Frequently, knees feel pounded', 'points': 0},
      ],
    },
    {
      'question': 'Where does your foot land relative to your hips when running?',
      'options': [
        {'text': 'Directly under my center of gravity', 'points': 2},
        {'text': 'Slightly in front with midfoot strike', 'points': 1},
        {'text': 'Far out in front with heavy heel strike', 'points': 0},
      ],
    },
    {
      'question': 'What is your current baseline running cadence?',
      'options': [
        {'text': '175 - 185 SPM (High turnover)', 'points': 2},
        {'text': '165 - 174 SPM (Moderate)', 'points': 1},
        {'text': 'Under 160 SPM (Low turnover bounding)', 'points': 0},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.menu_book_rounded, color: DronivaColors.neonLime),
            SizedBox(width: 8),
            Text('Cadence Science & Guides'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Category filter pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_categories.length, (index) {
                final isSelected = _selectedCategory == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_categories[index]),
                    selected: isSelected,
                    selectedColor: DronivaColors.neonLime,
                    backgroundColor: DronivaColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : DronivaColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected ? DronivaColors.neonLime : DronivaColors.border,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = index),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Featured Knowledge Card
          if (_selectedCategory == 0 || _selectedCategory == 1) ...[
            _buildGuideCard(
              icon: Icons.bolt_rounded,
              iconColor: DronivaColors.neonLime,
              tag: 'BIOMECHANICS',
              title: 'Why 180 SPM Matters',
              summary:
                  'Popularized by legendary coach Jack Daniels at the 1984 Olympics. Nearly all elite distance runners took 180+ steps per minute regardless of height or race distance.',
              details:
                  'A higher step rate shortens each stride without slowing speed. This brings your footfall directly under your center of mass, transforming braking forces into elastic spring energy through the Achilles tendon and plantar fascia.',
            ),
            const SizedBox(height: 12),
          ],

          if (_selectedCategory == 0 || _selectedCategory == 2) ...[
            _buildGuideCard(
              icon: Icons.shield_outlined,
              iconColor: DronivaColors.neonCyan,
              tag: 'INJURY PREVENTION',
              title: '20% Less Stress on Knee Joints',
              summary:
                  'Research demonstrates that increasing cadence by just 5% to 10% drastically reduces vertical oscillation and patellofemoral peak loads.',
              details:
                  'Lower step rates cause higher vertical bouncing. Every extra centimeter of vertical oscillation translates to thousands of kilograms of cumulative shock loading through your tibia, knee cartilage, and lumbar spine over a 10k run.',
            ),
            const SizedBox(height: 12),
          ],

          if (_selectedCategory == 0 || _selectedCategory == 3) ...[
            _buildGuideCard(
              icon: Icons.tune_rounded,
              iconColor: DronivaColors.neonAmber,
              tag: 'TRAINING PROTOCOL',
              title: 'The +5% Gradual Rule',
              summary:
                  'Never jump abruptly from 155 SPM to 180 SPM overnight. Increase your metronome target by 5% increments weekly.',
              details:
                  'Week 1: Measure baseline (e.g. 160 SPM).\nWeek 2: Run with metronome set to 168 SPM for 5-minute intervals.\nWeek 3: Extend to 174 SPM.\nWeek 4: Consolidate at 180 SPM during continuous runs.',
            ),
            const SizedBox(height: 12),
            _buildGuideCard(
              icon: Icons.hearing_rounded,
              iconColor: DronivaColors.neonCoral,
              tag: 'DRILLS',
              title: 'Audio Pacer Drill on Treadmill',
              summary:
                  'Using audio metronomes on a stationary surface helps wire neuromuscular motor pathways without traffic disruptions.',
              details:
                  'Set treadmill speed to a conversational pace. Switch on the Droniva Cadence Pacer at 180 BPM. Focus on light, quick taps rather than pushing hard into the belt. Your cadence should feel like cycling in an easy gear.',
            ),
            const SizedBox(height: 20),
          ],

          // Interactive Overstride Assessment Box
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: DronivaColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DronivaColors.neonLime.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.quiz_rounded, color: DronivaColors.neonLime),
                    SizedBox(width: 8),
                    Text(
                      'Cadence Health Check',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DronivaColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_quizStep < _quizQuestions.length) ...[
                  Text(
                    'Question ${_quizStep + 1} of ${_quizQuestions.length}',
                    style: const TextStyle(fontSize: 12, color: DronivaColors.neonCyan),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _quizQuestions[_quizStep]['question'] as String,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DronivaColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ...(_quizQuestions[_quizStep]['options'] as List<Map<String, dynamic>>).map((opt) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          side: const BorderSide(color: DronivaColors.border),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() {
                            _quizScore += opt['points'] as int;
                            _quizStep++;
                          });
                        },
                        child: Text(
                          opt['text'] as String,
                          style: const TextStyle(color: DronivaColors.textPrimary, fontSize: 13),
                        ),
                      ),
                    );
                  }),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: DronivaColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _quizScore >= 5
                              ? 'Superb Cadence Biomechanics!'
                              : _quizScore >= 3
                                  ? 'Good Form with Room for Rhythm Optimization'
                                  : 'Elevated Overstriding & Joint Impact Risk',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _quizScore >= 5
                                ? DronivaColors.neonLime
                                : _quizScore >= 3
                                    ? DronivaColors.neonAmber
                                    : DronivaColors.neonCoral,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _quizScore >= 5
                              ? 'Your rhythm is nimble and safe. Continue maintaining 180 SPM during long tempo sessions.'
                              : 'We recommend utilizing the Cadence Pacer at 176-180 SPM to bring your ground contact time under 230ms.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: DronivaColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => setState(() {
                        _quizStep = 0;
                        _quizScore = 0;
                      }),
                      icon: const Icon(Icons.refresh_rounded, color: DronivaColors.neonLime),
                      label: const Text('Retake Assessment', style: TextStyle(color: DronivaColors.neonLime)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGuideCard({
    required IconData icon,
    required Color iconColor,
    required String tag,
    required String title,
    required String summary,
    required String details,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DronivaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DronivaColors.border),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tag,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: DronivaColors.textPrimary,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              summary,
              style: const TextStyle(fontSize: 12, color: DronivaColors.textSecondary),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DronivaColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                details,
                style: const TextStyle(
                  fontSize: 13,
                  color: DronivaColors.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
