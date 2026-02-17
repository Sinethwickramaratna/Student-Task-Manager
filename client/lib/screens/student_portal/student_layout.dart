import 'package:flutter/material.dart';
import '../../widgets/animated_sidebar.dart';
import '../../widgets/top_bar.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';
import 'student_dashboard_page.dart';

class StudentLayout extends StatefulWidget {
  const StudentLayout({super.key});

  @override
  State<StudentLayout> createState() => _StudentLayoutState();
}

class _StudentLayoutState extends State<StudentLayout> {
  final _authService = AuthService();
  bool isSidebarOpen = false;
  int selectedIndex = 0;

  final Map<String, Widget> pages = {
    'Dashboard': const StudentDashboardPage(),
    'My Tasks': const _PlaceholderPage(title: 'My Tasks'),
    'My Class': const _PlaceholderPage(title: 'My Class'),
    'Profile': const _PlaceholderPage(title: 'Profile'),
  };

  final List<IconData> icons = [
    Icons.dashboard,
    Icons.task_alt,
    Icons.groups,
    Icons.person,
  ];

  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  void closeSidebar() {
    if (!isSidebarOpen) {
      return;
    }

    setState(() {
      isSidebarOpen = false;
    });
  }

  void onMenuSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> handleSignOut() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                TopBar(onMenuPressed: toggleSidebar, onSignOut: handleSignOut),
                Expanded(child: pages[pages.keys.toList()[selectedIndex]]!),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !isSidebarOpen,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSidebarOpen ? 0.35 : 0,
                child: GestureDetector(
                  onTap: closeSidebar,
                  child: Container(color: Colors.black),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -220,
            child: AnimatedSidebar(
              isOpen: isSidebarOpen,
              selectedIndex: selectedIndex,
              onMenuItemSelected: onMenuSelected,
              pages: pages.keys.toList(),
              icons: icons,
              onClose: closeSidebar,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7F2EA), Color(0xFFE7F1F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
