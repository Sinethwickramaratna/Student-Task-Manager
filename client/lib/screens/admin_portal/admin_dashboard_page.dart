import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/pie_chart_widget.dart';
import '../../widgets/bar_chart_widget.dart';
import '../../widgets/section_header.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  late Future<Map<String, dynamic>?> dashboardFuture;
  late final AnimationController _introController;
  late final AnimationController _floatController;
  late final Animation<double> _floatYOne;
  late final Animation<double> _floatYTwo;

  @override
  void initState() {
    super.initState();
    dashboardFuture = ApiService.getAdminDashboard();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _floatYOne = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _floatYTwo = Tween<double>(begin: 12, end: -12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Widget _staggered({
    required Widget child,
    required double start,
    required double end,
  }) {
    final fade = CurvedAnimation(
      parent: _introController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _introController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 245, 226, 255), Color.fromARGB(255, 231, 171, 255)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: AnimatedBuilder(
              animation: _floatYOne,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _floatYOne.value),
                child: child,
              ),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(42, 87, 3, 190),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -30,
            child: AnimatedBuilder(
              animation: _floatYTwo,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _floatYTwo.value),
                child: child,
              ),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(128, 189, 131, 244),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 200,
            child: AnimatedBuilder(
              animation: _floatYTwo,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _floatYTwo.value),
                child: child,
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(128, 155, 73, 255),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 100,
            child: AnimatedBuilder(
              animation: _floatYTwo,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _floatYTwo.value),
                child: child,
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(128, 85, 19, 146),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 20),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: dashboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                dashboardFuture = ApiService.getAdminDashboard();
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('No data available'));
                  }

                  final data = snapshot.data!;
                  final stats = data['stats'] ?? {};
                  final usersByRole =
                      (data['usersByRole'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                  final studentsByGrade =
                      (data['studentsByGrade'] as List?)?.cast<Map<String, dynamic>>() ?? [];

                  final cards = [
                    _StatCardData(
                      title: 'Total Users',
                      value: (stats['total_users'] ?? 0).toString(),
                      icon: Icons.groups_rounded,
                      accent: const Color(0xFF2563EB),
                      background: const Color.fromARGB(150, 232, 241, 255),
                    ),
                    _StatCardData(
                      title: 'Total Tasks',
                      value: (stats['total_tasks'] ?? 0).toString(),
                      icon: Icons.checklist_rounded,
                      accent: const Color(0xFF16A34A),
                      background: const Color.fromARGB(150, 231, 247, 236),
                    ),
                    _StatCardData(
                      title: 'Completed Tasks',
                      value: (stats['completed_tasks'] ?? 0).toString(),
                      icon: Icons.task_alt_rounded,
                      accent: const Color(0xFFF59E0B),
                      background: const Color.fromARGB(150, 255, 242, 217),
                    ),
                    _StatCardData(
                      title: 'Total Students',
                      value: (stats['total_students'] ?? 0).toString(),
                      icon: Icons.school_rounded,
                      accent: const Color(0xFF0EA5E9),
                      background: const Color.fromARGB(150, 229, 247, 255),
                    ),
                    _StatCardData(
                      title: 'Total Teachers',
                      value: (stats['total_teachers'] ?? 0).toString(),
                      icon: Icons.person_pin_rounded,
                      accent: const Color(0xFF8B5CF6),
                      background: const Color.fromARGB(150, 241, 233, 255),
                    ),
                    _StatCardData(
                      title: 'Total Classes',
                      value: (stats['total_classes'] ?? 0).toString(),
                      icon: Icons.dashboard_customize_rounded,
                      accent: const Color(0xFFEC4899),
                      background: const Color.fromARGB(150, 255, 230, 240),
                    ),
                    _StatCardData(
                      title: 'Active Users',
                      value: (stats['active_users'] ?? 0).toString(),
                      icon: Icons.wifi_tethering_rounded,
                      accent: const Color(0xFF0F766E),
                      background: const Color.fromARGB(150, 227, 243, 241),
                    ),
                  ];

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _staggered(
                          start: 0.0,
                          end: 0.3,
                          child: const SectionHeader(
                            title: 'Admin Overview',
                            subtitle: 'Live metrics across your platform',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _staggered(
                          start: 0.1,
                          end: 0.55,
                          child: _StatGrid(cards: cards),
                        ),
                        const SizedBox(height: 28),
                        _staggered(
                          start: 0.35,
                          end: 0.7,
                          child: const SectionHeader(
                            title: 'Insights',
                            subtitle: 'Role distribution and class performance',
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 900;
                            final panelWidth = isWide
                                ? (constraints.maxWidth - 16) / 2
                                : constraints.maxWidth;

                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: panelWidth,
                                  child: _staggered(
                                    start: 0.55,
                                    end: 0.9,
                                    child: _DashboardPanel(
                                      title: 'Users by Role',
                                      child: usersByRole.isNotEmpty
                                          ? PieChartWidget(usersByRole)
                                          : const Center(
                                              child: Text('No user role data available'),
                                            ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: panelWidth,
                                  child: _staggered(
                                    start: 0.65,
                                    end: 1.0,
                                    child: _DashboardPanel(
                                      title: 'Students by Grade',
                                      child: studentsByGrade.isNotEmpty
                                          ? BarChartWidget(studentsByGrade)
                                          : const Center(
                                              child: Text('No grade data available'),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final List<_StatCardData> cards;

  const _StatGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200
            ? 4
            : width >= 900
                ? 3
                : width >= 560
                    ? 2
                    : 1;
        final cardWidth = (width - (columns - 1) * 16) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    title: card.title,
                    value: card.value,
                    icon: card.icon,
                    bgColor: card.background,
                    accentColor: card.accent,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}


class _DashboardPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _DashboardPanel({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(180, 255, 255, 255),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(29, 0, 0, 0),
            blurRadius: 15,
            offset: const Offset(5, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final Color background;

  _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.background,
  });
}