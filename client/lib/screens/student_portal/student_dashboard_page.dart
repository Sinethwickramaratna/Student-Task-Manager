import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class StudentDashboardPage extends StatelessWidget{
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        gradient: AppColors.mainGradient,
      ),
      child: const Center(
        child: Text('Student Dashboard'),
      ),
    );
  }
}