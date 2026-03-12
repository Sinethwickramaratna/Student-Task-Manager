import 'package:flutter/material.dart';

class AppColors {
  // Midnight Backgrounds
  static const Color bgDark = Color(0xFF0B0D17);
  static const Color bgMedium = Color(0xFF1C1F2B);
  static const Color bgLight = Color(0xFF2D3241);
  
  // Neon Accents
  static const Color primaryNeon = Color(0xFF00F2FF);   // Cyan
  static const Color secondaryNeon = Color(0xFFB026FF); // Purple
  static const Color accentNeon = Color(0xFFFF00E5);    // Pink
  
  // States
  static const Color success = Color(0xFF00FF9D);
  static const Color error = Color(0xFFFF3131);
  static const Color warning = Color(0xFFFFD700);
  
  // Glassmorphism
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // Gradients
  static const LinearGradient mainGradient = LinearGradient(
    colors: [bgDark, bgMedium, bgLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [primaryNeon, secondaryNeon],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
