import 'package:flutter/material.dart';

class StudentDashboardPage extends StatelessWidget{
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7F2EA), Color(0xFFE7F1F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text('Student Dashboard'),
      ),
    );
  }
}