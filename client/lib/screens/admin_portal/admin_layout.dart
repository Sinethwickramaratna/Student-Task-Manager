import 'package:flutter/material.dart';
import './admin_dashboard_page.dart';
import './admin_users_page.dart';
import './admin_teachers_page.dart';
import './admin_students_page.dart';
import './admin_tasks_page.dart';
import '../../widgets/animated_sidebar.dart';
import '../../widgets/top_bar.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';

class AdminLayout extends StatefulWidget{
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final _authService = AuthService();
  bool isSidebarOpen = false;
  int selectedIndex = 0;

  final Map<String, Widget> pages = {
    'Dashboard': AdminDashboardPage(),
    'Users': AdminUsersPage(),
    'Teachers': AdminTeachersPage(),
    'Students': AdminStudentsPage(),
    'Tasks': AdminTasksPage(),
  };

  final List<IconData> icons = [
    Icons.dashboard,
    Icons.people,
    Icons.school,
    Icons.person,
    Icons.task,
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