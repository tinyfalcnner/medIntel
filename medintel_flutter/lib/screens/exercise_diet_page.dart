import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ExerciseDietPage extends StatelessWidget {
  const ExerciseDietPage({super.key});

  double _activityFactor(String level) {
    switch (level.toLowerCase()) {
      case 'sedentary':
        return 1.2;
      case 'lightly active':
        return 1.375;
      case 'moderately active':
        return 1.55;
      default:
        return 1.3;
    }
  }

  Map<String, dynamic> _dietRecommendation(dynamic user, Map<String, dynamic> dietPlan) {
    if (user == null) {
      return {
        'pattern': dietPlan['pattern']?.toString() ?? '-',
        'maintenance': '-',
        'targetCalories': dietPlan['caloriesPerDay']?.toString() ?? '-',
        'foods': <String>[],
      };
    }

    final isMale = user.gender.toString().toLowerCase().startsWith('m');
    final bmr = (10 * user.weightKg) +
        (6.25 * user.heightCm) -
        (5 * user.age) +
        (isMale ? 5 : -161); // Mifflin–St Jeor[web:128]

    final maintenance = bmr * _activityFactor(user.activityLevel);
    double targetCalories = maintenance;
    List<String> foods;

    final goal = user.primaryGoal.toString().toLowerCase();

    if (goal.contains('weight')) {
      targetCalories = maintenance - 450;
      foods = [
        'High‑fiber vegetables (broccoli, leafy greens)',
        'Lean proteins (chicken, fish, lentils)',
        'Whole grains; avoid sugary drinks and sweets',
      ];
    } else if (goal.contains('blood pressure')) {
      targetCalories = maintenance - 300;
      foods = [
        'Low‑salt, home‑cooked meals',
        'Fruits and vegetables rich in potassium',
        'Limit processed, canned, and fast foods',
      ];
    } else if (goal.contains('joint')) {
      foods = [
        'Fatty fish (rich in omega‑3)',
        'Olive oil, nuts, and seeds',
        'Colorful vegetables; limit fried and processed foods',
      ];
    } else {
      foods = [
        'Balanced mix of carbs, protein, and healthy fats',
        'Plenty of fruits and vegetables',
        'Limit ultra‑processed snacks',
      ];
    }

    return {
      'pattern': dietPlan['pattern']?.toString() ?? 'Personalized plan',
      'maintenance': maintenance.round().toString(),
      'targetCalories': targetCalories.round().toString(),
      'foods': foods,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final history = user?.medicalHistory ?? {};
    final exercisePlan =
        history['exercisePlan'] as Map<String, dynamic>? ?? {};
    final dietPlan = history['dietPlan'] as Map<String, dynamic>? ?? {};

    final theme = Theme.of(context);

    final dietRec = _dietRecommendation(user, dietPlan);
    final pattern = dietRec['pattern'] as String;
    final maintenance = dietRec['maintenance'] as String;
    final targetCalories = dietRec['targetCalories'] as String;
    final foods = (dietRec['foods'] as List).cast<String>();

    return Container(
      color: const Color(0xFFF6F0FF), // soft background
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        (user?.fullName ?? 'U')[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'No user selected',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          if (user != null)
                            Text(
                              '${user.age} yrs • ${user.gender} • '
                              '${user.heightCm.toStringAsFixed(0)} cm, '
                              '${user.weightKg.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          if (user != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                user.primaryGoal,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Exercise + weekly progress card
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ExerciseCard(
                    weeklyTarget:
                        exercisePlan['weeklyTargetMinutes']?.toString() ?? '-',
                    activities:
                        (exercisePlan['preferredActivities'] as List?)
                                ?.cast<String>() ??
                            const [],
                    constraints:
                        (exercisePlan['constraints'] as List?)
                                ?.cast<String>() ??
                            const [],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryStatsCard(user: user),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Diet card (now personalized)
            _DietCard(
              pattern: pattern,
              maintenanceCalories: maintenance,
              targetCalories: targetCalories,
              focus: foods,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String weeklyTarget;
  final List<String> activities;
  final List<String> constraints;

  const _ExerciseCard({
    required this.weeklyTarget,
    required this.activities,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center,
                    color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Exercise Plan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Weekly target: $weeklyTarget minutes',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Preferred activities',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: activities
                  .map(
                    (a) => Chip(
                      label: Text(a),
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (constraints.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Important precautions',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent),
              ),
              const SizedBox(height: 4),
              ...constraints.map(
                (c) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(color: Colors.redAccent)),
                    Expanded(
                      child: Text(
                        c,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryStatsCard extends StatelessWidget {
  final dynamic user;

  const _SummaryStatsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const SizedBox.shrink();
    }

    // very rough BMI just for display
    final heightM = user.heightCm / 100.0;
    final bmi = user.weightKg / (heightM * heightM);

    Color bmiColor;
    String bmiLabel;
    if (bmi < 18.5) {
      bmiColor = Colors.orange;
      bmiLabel = 'Underweight';
    } else if (bmi < 25) {
      bmiColor = Colors.green;
      bmiLabel = 'Healthy';
    } else if (bmi < 30) {
      bmiColor = Colors.orange;
      bmiLabel = 'Overweight';
    } else {
      bmiColor = Colors.redAccent;
      bmiLabel = 'Obese';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _StatRow(
              label: 'Height',
              value: '${user.heightCm.toStringAsFixed(0)} cm',
            ),
            _StatRow(
              label: 'Weight',
              value: '${user.weightKg.toStringAsFixed(1)} kg',
            ),
            const SizedBox(height: 8),
            const Text(
              'BMI (approx.)',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  bmi.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: bmiColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  bmiLabel,
                  style: TextStyle(fontSize: 13, color: bmiColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 13, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _DietCard extends StatelessWidget {
  final String pattern;
  final String maintenanceCalories;
  final String targetCalories;
  final List<String> focus;

  const _DietCard({
    required this.pattern,
    required this.maintenanceCalories,
    required this.targetCalories,
    required this.focus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu,
                    color: theme.colorScheme.secondary, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Diet Plan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Pattern: $pattern'),
            if (maintenanceCalories != '-')
              Text('Estimated maintenance: $maintenanceCalories kcal/day'),
            Text('Suggested target: $targetCalories kcal/day'),
            if (focus.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Key focus areas',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: focus
                    .map(
                      (f) => Chip(
                        label: Text(f),
                        backgroundColor: theme.colorScheme.secondary
                            .withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
