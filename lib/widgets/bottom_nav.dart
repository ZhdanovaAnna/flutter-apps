import 'package:flutter/material.dart';

import '../core/constants.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 58,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(child: _item(0, Icons.calculate_outlined, 'Калькулятор')),
            Expanded(child: _item(1, Icons.person_outline, 'Профиль')),
          ],
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final selected = selectedIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.green : AppColors.muted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: selected ? AppColors.green : AppColors.muted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
