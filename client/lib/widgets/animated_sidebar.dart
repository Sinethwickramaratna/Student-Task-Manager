import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AnimatedSidebar extends StatelessWidget {
  final bool isOpen;
  final int selectedIndex;
  final Function(int) onMenuItemSelected;
  final List<String> pages;
  final List<IconData> icons;
  final VoidCallback onClose;

  const AnimatedSidebar({
    super.key,
    required this.isOpen,
    required this.selectedIndex,
    required this.onMenuItemSelected,
    required this.pages,
    required this.icons,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final int itemCount = pages.length < icons.length ? pages.length : icons.length;

    return SizedBox(
      width: 220,
      child: Container(
        color: AppColors.bgDark,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
                tooltip: 'Close sidebar',
              ),
            ),
            for (int i = 0; i < itemCount; i++)
              _buildMenuItem(icons[i], pages[i], i),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index){
    final bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        onMenuItemSelected(index);
        onClose();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNeon.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppColors.primaryNeon.withOpacity(0.5)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            if(isOpen) ...[
              const SizedBox(width: 16),
              Text(title, 
              style: const TextStyle(color: Colors.white, fontSize: 16)
              ),
            ]
          ],
          ),
      ),
    );
  }
}

