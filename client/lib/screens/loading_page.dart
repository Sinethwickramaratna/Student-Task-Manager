import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/jwt_helper.dart';
import 'get_started_page.dart';
import 'login_page.dart';
import 'admin_portal/admin_layout.dart';
import 'teacher_portal/teacher_layout.dart';
import 'student_portal/student_layout.dart';

class LoadingPage extends StatefulWidget{
  final bool isFirstTime;
  const LoadingPage({super.key, required this.isFirstTime});

  @override
  State<LoadingPage> createState() => _LoadingPageState(isFirstTime: isFirstTime);
}

class _LoadingPageState extends State<LoadingPage> with SingleTickerProviderStateMixin{

  final bool isFirstTime;
  _LoadingPageState({required this.isFirstTime});

  final _storage = const FlutterSecureStorage();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState(){
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);

    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    // Wait for a minimum time for the splash screen (e.g. 3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GetStartedPage()),
      );
      return;
    }

    try {
      String? token = await _storage.read(key: 'jwt'); // Clear token on loading page for security

      if (token != null && !JwtHelper.isExpired(token)) {
        String role = JwtHelper.getRoleName(token);
        
        if (!mounted) return;

        Widget layout;
        if (role == 'Admin') {
          layout = AdminLayout();
        } else if (role == 'Teacher') {
          layout  = const TeacherLayout();
        } else if (role == 'Student') {
          layout = const StudentLayout();
        } else {
           layout = const LoginPage();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => layout),
        );
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      // If error reading storage or decoding, default to login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 20, 0, 38), Color.fromARGB(255, 100, 0, 123)],
            begin: Alignment(0,0),
            end: Alignment(1.0, 2),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/Logo1_white.png',
                  width:350,
                  height: 350,
                ),
              ),
              const SizedBox(height: 20),
              Lottie.asset(
                'assets/Loading Dots Blue.json',
                width: 150,
                repeat: true,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(
                      const ['**'],
                      value: const Color.fromARGB(255, 239, 145, 255)
                    ),
                  ],
                ),
              ),
            ]
          ),
        ),
      )
    );
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
}
