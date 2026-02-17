import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onSignOut;

  const TopBar({super.key, required this.onMenuPressed, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 37, 0, 52),
        border: const Border(
          bottom: BorderSide(color: Color.fromARGB(255, 97, 54, 122), width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(173, 0, 0, 0),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
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
