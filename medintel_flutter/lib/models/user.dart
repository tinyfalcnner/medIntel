class User {
  final String id;
  final String fullName;
  final String email;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String primaryGoal;
  final String activityLevel;
  final Map<String, dynamic> medicalHistory;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.primaryGoal,
    required this.activityLevel,
    required this.medicalHistory,
  });

  Future<void> logout() async {
    // Add real logout later if needed
  }

  static Future<void> loginWithRedirect() async {
    // Not used now; kept for future if you add real auth
  }
}
