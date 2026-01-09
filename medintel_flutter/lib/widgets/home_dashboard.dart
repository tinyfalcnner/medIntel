import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            user != null ? 'Welcome, ${user.fullName}' : 'Welcome to MedIntel',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            user != null
                ? 'Here is your personalized health overview.'
                : 'Sign in to see your personalized health insights.',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),

          const SizedBox(height: 24),

          // Summary cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _DashboardCard(
                title: 'Health Assessments',
                subtitle: 'View your recent results',
                icon: Icons.analytics,
              ),
              _DashboardCard(
                title: 'Exercise & Diet',
                subtitle: 'Your latest recommendations',
                icon: Icons.fitness_center,
              ),
              _DashboardCard(
                title: 'Health Topics',
                subtitle: 'Curated articles for you',
                icon: Icons.article,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Placeholder for recent activity / news
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              user != null
                  ? 'No recent activity yet. Complete a health questionnaire to get started.'
                  : 'Log in to see your recent assessments and chatbot conversations.',
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
