class User {
  final String id;
  final String fullName;
  final String email;

  User({
    required this.id,
    required this.fullName,
    required this.email,
  });

  // Simulate fetching current user asynchronously
  static Future<User> me() async {
    // Replace with actual fetch logic or API call
    await Future.delayed(const Duration(milliseconds: 200));
    return User(
      id: 'u123',
      fullName: 'Test User',
      email: 'test@example.com',
    );
  }

  Future<void> logout() async {
    // Add logout logic here, e.g., call API, clear tokens
    await Future.delayed(const Duration(milliseconds: 200));
  }

  static Future<void> loginWithRedirect() async {
    // Add login logic here, e.g., navigate to login screen
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
