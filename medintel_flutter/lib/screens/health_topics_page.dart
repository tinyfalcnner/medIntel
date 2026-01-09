import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HealthTopicsPage extends StatelessWidget {
  const HealthTopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final goal = user?.primaryGoal ?? 'General health';

    final topics = _topicsForUser(
      goal: goal,
      age: user?.age,
      activityLevel: user?.activityLevel,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Topics for ${user?.fullName ?? 'You'}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            goal,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: topics
                .map(
                  (t) => _TopicCard(
                    title: t['title'] as String,
                    subtitle: t['subtitle'] as String,
                    icon: t['icon'] as IconData,
                    tag: t['tag'] as String,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  List<Map<String, Object>> _topicsForUser({
    required String goal,
    int? age,
    String? activityLevel,
  }) {
    final g = goal.toLowerCase();

    if (g.contains('weight')) {
      return [
        {
          'title': 'Daily Routine Tweaks',
          'subtitle':
              'Add a 10–15 minute brisk walk after two meals, replace one sugary drink with water or unsweetened tea each day.',
          'icon': Icons.directions_walk,
          'tag': 'Movement',
        },
        {
          'title': 'Portion & Snacking Habits',
          'subtitle':
              'Use a smaller plate at dinner, keep fruit or nuts as your default snack, and keep chips/sweets out of sight at home.',
          'icon': Icons.restaurant,
          'tag': 'Eating habits',
        },
        {
          'title': 'Screen Time vs Sleep',
          'subtitle':
              'Set a “screens off” time 30 minutes before bed and use that slot for stretching or light reading to support recovery.',
          'icon': Icons.bedtime,
          'tag': 'Recovery',
        },
      ];
    } else if (g.contains('blood pressure')) {
      return [
        {
          'title': 'Salt & Processed Foods',
          'subtitle':
              'Limit adding table salt, avoid instant noodles and packaged soups, and choose fresh or frozen vegetables over canned ones.',
          'icon': Icons.water_drop,
          'tag': 'Sodium control',
        },
        {
          'title': 'Daily BP‑Friendly Routine',
          'subtitle':
              'Include at least 20 minutes of relaxed walking most days, practice 5 minutes of slow breathing when feeling stressed.',
          'icon': Icons.monitor_heart,
          'tag': 'Daily routine',
        },
        {
          'title': 'Home BP Monitoring',
          'subtitle':
              'Measure at the same time each day, seated for 5 minutes, arm supported at heart level; log values for your doctor.',
          'icon': Icons.fact_check,
          'tag': 'Self‑monitoring',
        },
      ];
    } else if (g.contains('joint')) {
      return [
        {
          'title': 'Joint‑Friendly Movement',
          'subtitle':
              'Swap long walks on hard surfaces for cycling, swimming, or elliptical; add 5–10 minutes of physio exercises daily.',
          'icon': Icons.accessibility_new,
          'tag': 'Low‑impact',
        },
        {
          'title': 'Micro‑breaks & Posture',
          'subtitle':
              'If sitting a lot, stand and move gently for 2–3 minutes every 30–45 minutes to reduce stiffness and joint load.',
          'icon': Icons.chair_alt,
          'tag': 'Ergonomics',
        },
        {
          'title': 'Everyday Inflammation',
          'subtitle':
              'Use olive oil instead of butter, add a serving of colorful vegetables to lunch and dinner, keep fried foods to once a week.',
          'icon': Icons.spa,
          'tag': 'Diet pattern',
        },
      ];
    } else {
      // General health / stress / cardio fitness
      return [
        {
          'title': 'Movement “Minimums”',
          'subtitle':
              'Aim for at least 5 days/week of 20–30 minutes of moderate activity; break it into 3×10 minutes if your schedule is busy.',
          'icon': Icons.directions_run,
          'tag': 'Activity',
        },
        {
          'title': 'Sleep & Wind‑Down',
          'subtitle':
              'Keep a fixed wake time, avoid heavy meals and screens in the last hour before bed, and create a short wind‑down ritual.',
          'icon': Icons.bedtime,
          'tag': 'Sleep hygiene',
        },
        {
          'title': 'Stress Micro‑breaks',
          'subtitle':
              'Insert 2–3 short pauses during the day with deep breathing or a brief walk instead of scrolling on your phone.',
          'icon': Icons.self_improvement,
          'tag': 'Stress',
        },
      ];
    }
  }
}

class _TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String tag;

  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 320,
      child: Card(
        elevation: 2,
        color: Colors.white.withValues(alpha: 0.98),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon,
                      color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
