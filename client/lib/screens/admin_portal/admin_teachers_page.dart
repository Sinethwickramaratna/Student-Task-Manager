import 'package:flutter/material.dart';
import '../../models/teacher_model.dart';
import '../../services/admin_teacher_service.dart';
import '../../widgets/section_header.dart';
import '../../widgets/teacher_card.dart';

class AdminTeachersPage extends StatefulWidget {
  const AdminTeachersPage({super.key});

  @override
  State<AdminTeachersPage> createState() => _AdminTeachersPageState();
}

class _AdminTeachersPageState extends State<AdminTeachersPage>
    with TickerProviderStateMixin {
  final AdminTeacherService _service = AdminTeacherService();

  List<TeacherModel> teachers = [];
  int currentPage = 0;
  int totalTeachers = 0;
  bool isLoading = false;
  String? errorMessage;

  String sortBy = "id";
  String direction = "asc";
  String searchQuery = "";

  final TextEditingController _searchController = TextEditingController();

  late final AnimationController _introController;
  late final AnimationController _floatController;
  late final Animation<double> _floatYOne;
  late final Animation<double> _floatYTwo;

  @override
  void initState() {
    super.initState();

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

    loadTeachers();
  }

  @override
  void dispose() {
    _introController.dispose();
    _floatController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadTeachers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _service.fetchTeachers(
        page: currentPage,
        sortBy: sortBy,
        direction: direction,
        search: searchQuery,
      );

      if (mounted) {
        setState(() {
          teachers = data['teachers'] ?? [];
          totalTeachers = data['total'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error loading teachers: $e';
        });
      }
      print('Error in loadTeachers: $e');
    }
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
    int totalPages = totalTeachers > 0 ? (totalTeachers / 10).ceil() : 1;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 245, 226, 255),
            Color.fromARGB(255, 231, 171, 255)
          ],
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
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: const SectionHeader(
                        title: "Teachers Management",
                        subtitle: "Manage your teachers effectively",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 139, 37, 235)
                                  .withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              currentPage = 0;
                            });
                            loadTeachers();
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by name or user ID...',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 14, right: 8),
                              child: Icon(
                                Icons.search_rounded,
                                color: Colors.grey.shade600,
                                size: 22,
                              ),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          searchQuery = '';
                                          currentPage = 0;
                                        });
                                        loadTeachers();
                                      },
                                    ),
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 230, 220, 240),
                                  width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 230, 220, 240),
                                  width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 139, 37, 235),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 16),
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black87),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 560;
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 255, 252, 255),
                                  Color.fromARGB(255, 246, 238, 255),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 139, 37, 235)
                                      .withOpacity(0.2),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(
                                color: const Color.fromARGB(255, 230, 220, 240),
                                width: 1,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 14 : 20,
                              vertical: isCompact ? 14 : 18,
                            ),
                            child: Wrap(
                              spacing: isCompact ? 10 : 16,
                              runSpacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.tune_rounded,
                                      color: Color.fromARGB(255, 139, 37, 235),
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Sort",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 82, 26, 138),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: isCompact ? constraints.maxWidth : 220,
                                  child: DropdownButtonFormField<String>(
                                    value: sortBy,
                                    decoration: InputDecoration(
                                      labelText: "Field",
                                      prefixIcon:
                                          const Icon(Icons.sort_rounded, size: 18),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 230, 220, 240),
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 230, 220, 240),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 139, 37, 235),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "id",
                                        child: Text("ID"),
                                      ),
                                      DropdownMenuItem(
                                        value: "first_name",
                                        child: Text("First Name"),
                                      ),
                                      DropdownMenuItem(
                                        value: "last_name",
                                        child: Text("Last Name"),
                                      ),
                                      DropdownMenuItem(
                                        value: "gender",
                                        child: Text("Gender"),
                                      ),
                                      DropdownMenuItem(
                                        value: "birth_date",
                                        child: Text("Birthdate"),
                                      ),
                                      DropdownMenuItem(
                                        value: "user_id",
                                        child: Text("User ID"),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        sortBy = value!;
                                        currentPage = 0;
                                        loadTeachers();
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: isCompact ? constraints.maxWidth : 200,
                                  child: DropdownButtonFormField<String>(
                                    value: direction,
                                    decoration: InputDecoration(
                                      labelText: "Order",
                                      prefixIcon: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        transitionBuilder: (child, animation) =>
                                            ScaleTransition(
                                          scale: animation,
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        ),
                                        child: Icon(
                                          direction == "asc"
                                              ? Icons.trending_up_rounded
                                              : Icons.trending_down_rounded,
                                          key: ValueKey<String>(direction),
                                          size: 18,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 230, 220, 240),
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 230, 220, 240),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 139, 37, 235),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "asc",
                                        child: Text("Ascending"),
                                      ),
                                      DropdownMenuItem(
                                        value: "desc",
                                        child: Text("Descending"),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        direction = value!;
                                        currentPage = 0;
                                        loadTeachers();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(child: Text(errorMessage!)),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    errorMessage = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    else if (teachers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          "No teachers found",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: teachers.length,
                          itemBuilder: (context, index) {
                            final teacher = teachers[index];
                            final colors = [
                              {
                                'accent': const Color(0xFF2563EB),
                                'bg': const Color.fromARGB(150, 232, 241, 255),
                              },
                              {
                                'accent': const Color(0xFF16A34A),
                                'bg': const Color.fromARGB(150, 231, 247, 236),
                              },
                              {
                                'accent': const Color(0xFFF59E0B),
                                'bg': const Color.fromARGB(150, 255, 242, 217),
                              },
                              {
                                'accent': const Color(0xFF0EA5E9),
                                'bg': const Color.fromARGB(150, 229, 247, 255),
                              },
                            ];

                            final colorScheme = colors[index % colors.length];

                            return _staggered(
                              start: (index * 0.05).clamp(0.0, 0.85),
                              end: ((index + 1) * 0.05).clamp(0.0, 1.0),
                              child: TeacherCard(
                                teacher: teacher,
                                primaryColor: colorScheme['accent'] as Color,
                                backgroundColor: colorScheme['bg'] as Color,
                                onTap: () {
                                  // Add teacher details action here
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    if (teachers.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 520;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 248, 244, 255),
                                    Color.fromARGB(255, 238, 226, 255),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 139, 37, 235)
                                        .withOpacity(0.12),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                                border: Border.all(
                                  color: const Color.fromARGB(255, 139, 37, 235)
                                      .withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 14 : 22,
                                vertical: isCompact ? 16 : 20,
                              ),
                              child: Wrap(
                                spacing: isCompact ? 10 : 16,
                                runSpacing: isCompact ? 12 : 14,
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  SizedBox(
                                    width: isCompact ? constraints.maxWidth : null,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: currentPage > 0
                                            ? () {
                                                setState(() {
                                                  currentPage--;
                                                  loadTeachers();
                                                });
                                              }
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            gradient: currentPage > 0
                                                ? const LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(255, 153, 37, 235),
                                                      Color.fromARGB(255, 139, 37, 235),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : null,
                                            color: currentPage > 0
                                                ? null
                                                : Colors.grey.shade300,
                                            boxShadow: currentPage > 0
                                                ? [
                                                    BoxShadow(
                                                      color: const Color.fromARGB(255, 139, 37, 235)
                                                          .withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 4),
                                                    )
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.arrow_back_ios_rounded,
                                                color: currentPage > 0
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Previous',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: currentPage > 0
                                                      ? Colors.white
                                                      : Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: isCompact ? constraints.maxWidth : 220,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Page ${currentPage + 1} / $totalPages',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color.fromARGB(255, 100, 30, 150),
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 4,
                                          width: isCompact ? constraints.maxWidth : 160,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(2),
                                            color: Colors.grey.shade300,
                                          ),
                                          child: FractionallySizedBox(
                                            widthFactor: totalPages > 0
                                                ? (currentPage + 1) / totalPages
                                                : 0,
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(2),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color.fromARGB(255, 186, 14, 233),
                                                    Color.fromARGB(255, 153, 37, 235),
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: isCompact ? constraints.maxWidth : null,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: currentPage < totalPages - 1
                                            ? () {
                                                setState(() {
                                                  currentPage++;
                                                  loadTeachers();
                                                });
                                              }
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            gradient: currentPage < totalPages - 1
                                                ? const LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(255, 139, 37, 235),
                                                      Color.fromARGB(255, 153, 37, 235),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : null,
                                            color: currentPage < totalPages - 1
                                                ? null
                                                : Colors.grey.shade300,
                                            boxShadow: currentPage < totalPages - 1
                                                ? [
                                                    BoxShadow(
                                                      color: const Color.fromARGB(255, 139, 37, 235)
                                                          .withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 4),
                                                    )
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Next',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: currentPage < totalPages - 1
                                                      ? Colors.white
                                                      : Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                color: currentPage < totalPages - 1
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}