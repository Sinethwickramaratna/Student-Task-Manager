import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final Color? bgColor;
  final Color? accentColor;
  final IconData? icon;

  const StatCard({
    required this.title,
    required this.value,
    this.bgColor,
    this.accentColor,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.bgColor ?? AppColors.bgMedium;
    final accent = widget.accentColor ?? AppColors.primaryNeon;
    final scale = _isPressed
        ? 0.97
        : _isHovered
            ? 1.05
            : 1.0;
    final shadowOpacity = _isPressed
        ? 0.05
        : _isHovered
            ? 0.12
            : 0.08;
    final shadowOffset = _isPressed
        ? const Offset(0, 4)
        : _isHovered
            ? const Offset(0, 10)
            : const Offset(0, 8);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 120),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  base.withOpacity(0.8),
                  AppColors.bgLight.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(shadowOpacity),
                  blurRadius: _isHovered ? 20 : 16,
                  offset: shadowOffset,
                ),
              ],
              border: Border.all(
                color: _isHovered ? AppColors.primaryNeon.withOpacity(0.5) : AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon ?? Icons.analytics_outlined,
                          color: accent,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNeon.withOpacity(0.9),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.value,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}