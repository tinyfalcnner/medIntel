import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'providers/user_provider.dart';
import 'widgets/health_news_ticker.dart';
import 'widgets/chatbot_popup.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final String currentPageName;

  const AppLayout({
    super.key,
    required this.child,
    required this.currentPageName,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // This function fetches the current user and updates provider.
  void loadUser() async {
    try {
      final user = await User.me(); // Static async method from your User model
      if (!mounted) return; // satisfies use_build_context_synchronously
      Provider.of<UserProvider>(context, listen: false).setUser(user);
    } catch (e) {
      debugPrint("User not logged in"); // satisfies avoid_print
    }
  }

  void handleLogout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.user?.logout();
    userProvider.clearUser();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final navigationItems = [
      {'title': 'Home', 'icon': Icons.home, 'route': '/home'},
      {'title': 'Health Topics', 'icon': Icons.article, 'route': '/health_topics'},
      {'title': 'User Profile', 'icon': Icons.person, 'route': '/user_profile'},
      {'title': 'Exercise & Diet', 'icon': Icons.fitness_center, 'route': '/exercise_diet'},
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Text(
                'MedIntel',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ...navigationItems.map(
              (item) => ListTile(
                leading: Icon(item['icon'] as IconData),
                title: Text(item['title'] as String),
                selected: widget.currentPageName == item['title'],
                onTap: () {
                  Navigator.pushNamed(context, item['route'] as String);
                },
              ),
            ),
            if (user != null)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: handleLogout,
              ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.favorite, color: Colors.white),
            SizedBox(width: 8),
            Text('MedIntel', style: TextStyle(fontSize: 20)),
          ],
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(user.fullName, style: const TextStyle(fontSize: 14)),
                  Text(user.email, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          if (user == null)
            TextButton.icon(
              onPressed: () async {
                await User.loginWithRedirect();
              },
              icon: const Icon(Icons.shield, color: Colors.white),
              label: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Stack(
        children: [
          widget.child,
          Align(
            alignment: Alignment.bottomCenter,
            child: HealthNewsTicker(userId: user?.id),
          ),
          if (user != null) ChatbotPopup(user: user),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }
}
