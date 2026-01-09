import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../app_layout.dart';
import '../widgets/home_dashboard.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Three synthetic medical profiles
    final users = [
      User(
        id: 'u1',
        fullName: 'Alice Johnson',
        email: 'alice.johnson@example.com',
        age: 28,
        gender: 'Female',
        heightCm: 168,
        weightKg: 60,
        primaryGoal: 'Improve cardio fitness and manage stress',
        activityLevel: 'Moderately active',
        medicalHistory: {
          "conditions": [
            {
              "name": "Mild asthma",
              "since": "2015",
              "status": "well-controlled",
              "notes":
                  "Uses inhaler before intense exercise; no hospitalizations."
            }
          ],
          "allergies": [
            {"substance": "Penicillin", "reaction": "Rash"}
          ],
          "medications": [
            {
              "name": "Salbutamol inhaler",
              "dose": "100 mcg as needed",
              "schedule": "Before exercise or during symptoms"
            }
          ],
          "exercisePlan": {
            "weeklyTargetMinutes": 150,
            "preferredActivities": ["Jogging", "Yoga"],
            "constraints": ["Avoid very cold outdoor air"]
          },
          "dietPlan": {
            "pattern": "Mediterranean-style",
            "caloriesPerDay": 1900,
            "focus": ["More vegetables", "Healthy fats", "Whole grains"]
          },
          // New progress data for charts
          "progress": {
            "weightKgWeekly": [61.0, 60.7, 61.0, 60.5, 60.0],
            "stepsDaily": [6500, 8200, 9000, 7800, 10000, 9500, 8800],
            "activityMinutesWeekly": [150, 130, 160, 170]
          }
        },
      ),
      User(
        id: 'u2',
        fullName: 'Brian Lee',
        email: 'brian.lee@example.com',
        age: 45,
        gender: 'Male',
        heightCm: 178,
        weightKg: 92,
        primaryGoal: 'Weight loss and blood pressure control',
        activityLevel: 'Sedentary',
        medicalHistory: {
          "conditions": [
            {
              "name": "Hypertension",
              "since": "2020",
              "status": "suboptimally controlled",
              "latestBp": "145/92 mmHg"
            },
            {
              "name": "Prediabetes",
              "since": "2023",
              "status": "lifestyle management",
              "latestHba1c": "6.1%"
            }
          ],
          "allergies": [],
          "medications": [
            {
              "name": "Amlodipine",
              "dose": "5 mg",
              "schedule": "Once daily in the morning"
            }
          ],
          "exercisePlan": {
            "weeklyTargetMinutes": 180,
            "preferredActivities": ["Brisk walking", "Cycling"],
            "constraints": ["Start low intensity, monitor BP"]
          },
          "dietPlan": {
            "pattern": "DASH-style low-salt diet",
            "caloriesPerDay": 1800,
            "focus": [
              "Reduce sodium",
              "Limit sugary drinks",
              "Increase fruits and vegetables"
            ]
          },
          "progress": {
            "weightKgWeekly": [93.0, 92.5, 92.0, 91.4, 91.0],
            "stepsDaily": [4200, 5000, 6300, 5800, 7000, 7600, 6900],
            "activityMinutesWeekly": [60, 80, 95, 110]
          }
        },
      ),
      User(
        id: 'u3',
        fullName: 'Dr. Chen',
        email: 'dr.chen@example.com',
        age: 60,
        gender: 'Female',
        heightCm: 160,
        weightKg: 70,
        primaryGoal: 'Maintain joint health and energy',
        activityLevel: 'Lightly active',
        medicalHistory: {
          "conditions": [
            {
              "name": "Osteoarthritis of knees",
              "since": "2018",
              "status": "stable",
              "notes": "Pain after long walks or stairs."
            },
            {
              "name": "Hyperlipidemia",
              "since": "2016",
              "status": "on statin therapy",
              "latestLipidPanel": "LDL 95 mg/dL"
            }
          ],
          "allergies": [
            {"substance": "Shellfish", "reaction": "Hives"}
          ],
          "medications": [
            {
              "name": "Atorvastatin",
              "dose": "20 mg",
              "schedule": "Once nightly"
            },
            {
              "name": "Paracetamol",
              "dose": "500 mg",
              "schedule": "As needed for knee pain"
            }
          ],
          "exercisePlan": {
            "weeklyTargetMinutes": 150,
            "preferredActivities": [
              "Swimming",
              "Stationary bike",
              "Physio exercises"
            ],
            "constraints": ["Avoid high-impact running and deep squats"]
          },
          "dietPlan": {
            "pattern": "Heart-healthy, low-saturated-fat diet",
            "caloriesPerDay": 1700,
            "focus": [
              "More fish and fiber",
              "Less fried and processed food"
            ]
          },
          "progress": {
            "weightKgWeekly": [70.5, 70.3, 70.5, 70.8, 70.4],
            "stepsDaily": [5200, 6000, 6400, 6100, 6800, 7200, 7000],
            "activityMinutesWeekly": [145, 150, 155, 160]
          }
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MedIntel Login'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.fullName),
              // no subtitle here – details only on dashboard/profile
              trailing: const Icon(Icons.login),
              onTap: () {
                context.read<UserProvider>().setUser(user);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppLayout(
                      currentPageName: 'Home',
                      child: HomeDashboard(),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
