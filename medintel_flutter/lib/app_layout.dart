import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/health/health_questionnaire.dart';
import 'widgets/health_news_ticker.dart';
import 'widgets/chatbot_popup.dart';
import 'models/user.dart';
import 'providers/user_provider.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final String currentPageName;

  const AppLayout({Key? key, required this.child, required this.currentPageName})
      : super(key: key);

  @override
  _AppLayoutState createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    try {
      final user = await User.me(); // Your API call to fetch user
      Provider.of<UserProvider>(context, listen: false).setUser(user);
    } catch (e) {
      print("User not logged in");
    }
  }

  void handleLogout() async {
    await User.logout(); // Your logout API call
    Provider.of<UserProvider>(context, listen: false).clearUser();
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
            DrawerHeader(
              child: Text('MedIntel', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ...navigationItems.map((item) => ListTile(
                  leading: Icon(item['icon'] as IconData),
                  title: Text(item['title'] as String),
                  selected: widget.currentPageName == item['title'],
                  onTap: () {
                    Navigator.pushNamed(context, item['route'] as String);
                  },
                )),
            if (user != null)
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: handleLogout,
              ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Row(
          children: [
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
                  Text(user.fullName ?? '', style: TextStyle(fontSize: 14)),
                  Text(user.email ?? '', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          if (user == null)
            TextButton.icon(
              onPressed: () async {
                await User.loginWithRedirect();
              },
              icon: Icon(Icons.shield, color: Colors.white),
              label: Text('Login', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Stack(
        children: [
          widget.child,
          Align(
            alignment: Alignment.bottomCenter,
            child: HealthNewsTicker(), // your news ticker widget
          ),
          if (user != null) ChatbotPopup(user: user), // chatbot popup
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }
}
