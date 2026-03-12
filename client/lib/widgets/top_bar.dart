import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onSignOut;

  const TopBar({super.key, required this.onMenuPressed, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 35, color: Color.fromARGB(255, 255, 255, 255),),
            onPressed: onMenuPressed,
          ),
          Expanded(
            child: Center(
              child: Image.asset("assets/images/Logo2_white.png", height: 60),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 35, color: Color.fromARGB(255, 255, 255, 255),),
            onPressed: onSignOut,
          )
        ],
      ),
    );

  }
}
