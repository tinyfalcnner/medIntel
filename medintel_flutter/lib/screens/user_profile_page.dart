import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/user_provider.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final history = user?.medicalHistory ?? {};
    final conditions = (history['conditions'] as List?) ?? [];
    final medications = (history['medications'] as List?) ?? [];
    final allergies = (history['allergies'] as List?) ?? [];
    final progress = (history['progress'] as Map<String, dynamic>?) ?? {};

    if (user == null) {
      return const Center(child: Text('No user selected.'));
    }

    final theme = Theme.of(context);
    final weightPoints = _buildWeightPoints(progress);
    final stepBars = _buildStepBars(progress);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            user.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.age} yrs • ${user.gender}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            'Height: ${user.heightCm} cm   Weight: ${user.weightKg} kg',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Primary goal: ${user.primaryGoal}',
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 24),

          // Overview + weight chart
          _SectionCard(
            title: 'Overview & Weight Trend',
            children: [
              _QuickStatsRow(user: user),
              const SizedBox(height: 16),
              if (weightPoints.isNotEmpty)
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('W${value.toInt()}',
                                  style: const TextStyle(fontSize: 10)),
                            ),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: weightPoints,
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Text(
                  'No weight history available.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Steps chart
          _SectionCard(
            title: 'Daily Steps (recent)',
            children: [
              if (stepBars.isNotEmpty)
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= stepBars.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'D${index + 1}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: stepBars,
                    ),
                  ),
                )
              else
                const Text(
                  'No step history available.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Conditions
          _SectionCard(
            title: 'Medical Conditions',
            children: conditions.isEmpty
                ? const [Text('None recorded.')]
                : conditions
                    .map<Widget>(
                      (c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (c['status'] != null)
                              Text(
                                'Status: ${c['status']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            if (c['notes'] != null)
                              Text(
                                c['notes'],
                                style: const TextStyle(fontSize: 13),
                              ),
                            if (c['latestBp'] != null)
                              Text(
                                'Latest BP: ${c['latestBp']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            if (c['latestHba1c'] != null)
                              Text(
                                'Latest HbA1c: ${c['latestHba1c']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            if (c['latestLipidPanel'] != null)
                              Text(
                                'Lipid panel: ${c['latestLipidPanel']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),

          const SizedBox(height: 16),

          // Medications
          _SectionCard(
            title: 'Medications',
            children: medications.isEmpty
                ? const [Text('No regular medications.')]
                : medications
                    .map<Widget>(
                      (m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Expanded(
                              child: Text(
                                '${m['name']} – ${m['dose']} (${m['schedule']})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),

          const SizedBox(height: 16),

          // Allergies
          _SectionCard(
            title: 'Allergies',
            children: allergies.isEmpty
                ? const [Text('No known allergies.')]
                : allergies
                    .map<Widget>(
                      (a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '${a['substance']} – ${a['reaction']}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _buildWeightPoints(Map<String, dynamic> progress) {
    final weights = (progress['weightKgWeekly'] as List?)?.cast<num>();
    if (weights == null || weights.isEmpty) return [];
    final spots = <FlSpot>[];
    for (var i = 0; i < weights.length; i++) {
      spots.add(FlSpot((i + 1).toDouble(), weights[i].toDouble()));
    }
    return spots;
  }

  List<BarChartGroupData> _buildStepBars(Map<String, dynamic> progress) {
    final steps = (progress['stepsDaily'] as List?)?.cast<num>();
    if (steps == null || steps.isEmpty) return [];
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < steps.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: steps[i].toDouble(),
              width: 10,
            ),
          ],
        ),
      );
    }
    return groups;
  }
}

class _QuickStatsRow extends StatelessWidget {
  final dynamic user;

  const _QuickStatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final heightM = user.heightCm / 100.0;
    final bmi = user.weightKg / (heightM * heightM);

    String bmiLabel;
    if (bmi < 18.5) {
      bmiLabel = 'Underweight';
    } else if (bmi < 25) {
      bmiLabel = 'Healthy';
    } else if (bmi < 30) {
      bmiLabel = 'Overweight';
    } else {
      bmiLabel = 'Obese';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatChip(label: 'Age', value: '${user.age} yrs'),
        _StatChip(label: 'BMI', value: bmi.toStringAsFixed(1)),
        _StatChip(label: 'Category', value: bmiLabel),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white.withValues(alpha: 0.98),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
